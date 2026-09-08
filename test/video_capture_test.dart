import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:segunda_opinion_app/controllers/video_capture_controller.dart';
import 'package:segunda_opinion_app/controllers/document_selection_controller.dart';
import 'package:segunda_opinion_app/domain/pending_document.dart';
import 'package:segunda_opinion_app/domain/repositories/video_capture_repository.dart';
import 'package:segunda_opinion_app/views/video_recording_screen.dart';
import 'consultation_steps_test.dart' show app;
import 'form_inputs_test.dart' show FakeSelection;

PendingDocument sample({int seconds = 2}) => PendingDocument(
  title: 'synthetic.mp4',
  fileName: 'synthetic.mp4',
  bytes: Uint8List(12),
  duration: Duration(seconds: seconds),
);

class FakeCapture implements VideoCaptureRepository {
  int preparations = 0;
  int recordings = 0;
  int stops = 0;
  bool disposed = false;
  VideoCaptureIssue? failure;
  Completer<void>? pendingPrepare;
  Completer<PendingDocument> pendingRecording = Completer<PendingDocument>();
  @override
  Future<void> prepare() async {
    preparations++;
    if (failure != null) throw VideoCaptureFailure(failure!);
    await pendingPrepare?.future;
  }

  @override
  Future<PendingDocument> record() {
    recordings++;
    return pendingRecording.future;
  }

  @override
  void stop() {
    stops++;
  }

  @override
  void dispose() {
    disposed = true;
  }
}

void main() {
  test(
    'capture is explicit and review does not submit; repeat discards previous video',
    () async {
      final repository = FakeCapture();
      final controller = VideoCaptureController(repository);
      addTearDown(controller.dispose);
      expect(repository.preparations, 0);
      await controller.start();
      expect(repository.recordings, 0);
      await controller.prepare();
      expect(controller.phase, VideoCapturePhase.ready);
      final recording = controller.start();
      await controller.start();
      expect(repository.recordings, 1);
      controller.stop();
      controller.stop();
      expect(repository.stops, 1);
      repository.pendingRecording.complete(sample());
      await recording;
      expect(controller.phase, VideoCapturePhase.review);
      expect(controller.video, isNotNull);
      await controller.prepare();
      expect(controller.video, isNull);
    },
  );
  test('denied access remains optional and retry is possible', () async {
    final repository = FakeCapture()..failure = VideoCaptureIssue.permission;
    final controller = VideoCaptureController(repository);
    addTearDown(controller.dispose);
    await controller.prepare();
    expect(controller.issue, VideoCaptureIssue.permission);
    expect(controller.video, isNull);
    repository.failure = null;
    await controller.prepare();
    expect(controller.phase, VideoCapturePhase.ready);
  });
  test('invalid duration never becomes a usable video', () async {
    final repository = FakeCapture();
    final controller = VideoCaptureController(repository);
    addTearDown(controller.dispose);
    await controller.prepare();
    final recording = controller.start();
    repository.pendingRecording.complete(sample(seconds: 31));
    await recording;
    expect(controller.issue, VideoCaptureIssue.invalid);
    expect(controller.video, isNull);
  });
  test(
    'late permission and recording results are ignored after interruption',
    () async {
      final repository = FakeCapture()..pendingPrepare = Completer<void>();
      final controller = VideoCaptureController(repository);
      addTearDown(controller.dispose);
      final preparing = controller.prepare();
      controller.interrupt();
      repository.pendingPrepare!.complete();
      await preparing;
      expect(controller.issue, VideoCaptureIssue.interrupted);
      expect(controller.phase, VideoCapturePhase.failed);
      expect(repository.disposed, isTrue);
      await controller.prepare();
      expect(repository.preparations, 1);
    },
  );
  test(
    'session cleanup rejects a late confirmed video; cancel adds nothing',
    () async {
      final controller = DocumentSelectionController(FakeSelection());
      addTearDown(controller.dispose);
      expect(await controller.record(() async => null), isFalse);
      expect(controller.documents, isEmpty);
      final pending = Completer<PendingDocument?>();
      final capturing = controller.record(() => pending.future);
      controller.clear();
      pending.complete(sample());
      expect(await capturing, isFalse);
      expect(controller.videos, isEmpty);
      expect(await controller.record(() async => sample()), isTrue);
      expect(await controller.record(() async => sample()), isFalse);
      expect(controller.issue, DocumentSelectionIssue.videoLimit);
    },
  );
  testWidgets('deadline stops at 30 seconds even without a manual stop', (
    tester,
  ) async {
    final repository = FakeCapture();
    final controller = VideoCaptureController(repository);
    addTearDown(controller.dispose);
    await controller.prepare();
    final recording = controller.start();
    await tester.pump(const Duration(seconds: 30));
    expect(repository.stops, 1);
    expect(controller.phase, VideoCapturePhase.finishing);
    repository.pendingRecording.complete(sample());
    await recording;
  });
  for (final width in [320.0, 768.0, 1440.0]) {
    testWidgets('explicit permissions, preview and cancellation at $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final repository = FakeCapture();
      final controller = VideoCaptureController(repository);
      await tester.pumpWidget(
        app(
          VideoRecordingScreen(
            controller: controller,
            preview: (_) => const ColoredBox(color: Colors.black),
          ),
        ),
      );
      expect(repository.preparations, 0);
      await tester.tap(find.text('ACTIVAR CÁMARA Y MICRÓFONO'));
      await tester.pumpAndSettle();
      expect(repository.preparations, 1);
      await tester.ensureVisible(find.text('INICIAR GRABACIÓN'));
      await tester.tap(find.text('INICIAR GRABACIÓN'));
      await tester.pump();
      repository.pendingRecording.complete(sample());
      await tester.pumpAndSettle();
      expect(find.text('USAR ESTE VIDEO'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      expect(repository.disposed, isTrue);
    });
  }
}
