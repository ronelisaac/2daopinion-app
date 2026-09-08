import 'dart:async';
import 'dart:typed_data';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:segunda_opinion_app/domain/attachment_policy.dart';
import 'package:segunda_opinion_app/domain/form_limits.dart';
import 'package:segunda_opinion_app/domain/pending_document.dart';
import 'package:segunda_opinion_app/controllers/document_selection_controller.dart';
import 'package:segunda_opinion_app/repositories/local_document_selection_repository.dart';
import 'package:segunda_opinion_app/widgets/document_selection_panel.dart';
import 'package:segunda_opinion_app/core/app_theme.dart';
import 'package:segunda_opinion_app/l10n/app_localizations.dart';
import 'form_inputs_test.dart' show FakeSelection;

PendingDocument video({Duration duration = const Duration(seconds: 30)}) =>
    PendingDocument(
      title: 'Video ficticio',
      fileName: 'prueba.mp4',
      bytes: Uint8List(8),
      duration: duration,
    );

void main() {
  for (final extension in AttachmentPolicy.documentExtensions) {
    test(
      'document format $extension accepted case insensitively at size limit',
      () {
        expect(
          AttachmentPolicy.valid(
            'prueba.${extension.toUpperCase()}',
            FormLimits.documentBytes,
            null,
          ),
          isTrue,
        );
        expect(
          AttachmentPolicy.valid(
            'prueba.$extension',
            FormLimits.documentBytes + 1,
            null,
          ),
          isFalse,
        );
      },
    );
  }
  test(
    'other formats, misleading suffixes, empty and long names fail closed',
    () {
      for (final name in [
        'file.docx',
        'file.xlsx',
        'file.gif',
        'file.svg',
        'file.exe',
        'file.pdf.exe',
        'file',
        '${'x' * 255}.pdf',
      ]) {
        expect(AttachmentPolicy.valid(name, 4, null), isFalse, reason: name);
      }
      expect(AttachmentPolicy.valid('file.pdf', 0, null), isFalse);
      expect(
        AttachmentPolicy.valid('file.pdf', 4, const Duration(seconds: 1)),
        isFalse,
      );
    },
  );
  test(
    'video needs measured positive duration, at most 30 seconds and 20 MiB',
    () {
      for (final name in ['sample.MP4', 'sample.mov']) {
        expect(
          AttachmentPolicy.valid(
            name,
            FormLimits.videoBytes,
            const Duration(seconds: 30),
          ),
          isTrue,
        );
        for (final duration in [
          null,
          Duration.zero,
          const Duration(microseconds: -1),
          const Duration(milliseconds: 30001),
        ]) {
          expect(AttachmentPolicy.valid(name, 4, duration), isFalse);
        }
        expect(
          AttachmentPolicy.valid(
            name,
            FormLimits.videoBytes + 1,
            const Duration(seconds: 1),
          ),
          isFalse,
        );
      }
    },
  );
  test(
    'adapter checks actual decoded duration and preserves it with bytes',
    () async {
      final repository = LocalDocumentSelectionRepository(
        picker: (isVideo) async => [
          XFile.fromData(Uint8List(8), name: 'prueba.mp4', path: 'prueba.mp4'),
        ],
        videoDuration: (_) async => const Duration(seconds: 30),
      );
      final result = await repository.select(
        maxFiles: 1,
        maxTotalBytes: 100,
        video: true,
      );
      expect(result.single.duration, const Duration(seconds: 30));
    },
  );
  test('adapter rejects undecodable and overlong video', () async {
    for (final duration in [const Duration(seconds: 31), Duration.zero, null]) {
      final repository = LocalDocumentSelectionRepository(
        picker: (_) async => [
          XFile.fromData(Uint8List(8), name: 'prueba.mp4', path: 'prueba.mp4'),
        ],
        videoDuration: (_) async =>
            duration ?? (throw StateError('unreadable')),
      );
      await expectLater(
        repository.select(maxFiles: 1, maxTotalBytes: 100, video: true),
        throwsA(
          isA<DocumentSelectionFailure>().having(
            (error) => error.issue,
            'issue',
            DocumentSelectionIssue.videoInvalid,
          ),
        ),
      );
    }
  });
  test('document picker never accepts video or unlisted extensions', () async {
    for (final name in ['sample.mp4', 'sample.docx', 'sample.pdf.exe']) {
      final repository = LocalDocumentSelectionRepository(
        picker: (_) async => [
          XFile.fromData(Uint8List(8), name: name, path: name),
        ],
      );
      await expectLater(
        repository.select(maxFiles: 20, maxTotalBytes: 100),
        throwsA(isA<DocumentSelectionFailure>()),
      );
    }
  });
  test(
    'video is optional, separate from studies, limited to one and cleared with session',
    () async {
      final repository = FakeSelection();
      final controller = DocumentSelectionController(repository);
      addTearDown(controller.dispose);
      await controller.select();
      expect(controller.videos, isEmpty);
      repository.pending = Completer<List<PendingDocument>>()
        ..complete([video()]);
      expect(await controller.select(video: true), isTrue);
      expect(controller.studies.length, 1);
      expect(controller.videos.length, 1);
      expect(await controller.select(video: true), isFalse);
      expect(controller.issue, DocumentSelectionIssue.videoLimit);
      controller.rename(controller.videos.single, 'Explicación ficticia');
      expect(controller.videos.single.duration, const Duration(seconds: 30));
      controller.clear();
      expect(controller.documents, isEmpty);
    },
  );
  test('video shares the total budget and cannot arrive after clear', () async {
    final repository = FakeSelection();
    final controller = DocumentSelectionController(repository);
    addTearDown(controller.dispose);
    repository.pending = Completer<List<PendingDocument>>()
      ..complete(
        List.generate(
          10,
          (_) => PendingDocument(
            title: 'Ficticio',
            fileName: 'test.pdf',
            bytes: Uint8List(FormLimits.documentBytes),
          ),
        ),
      );
    await controller.select();
    repository.pending = Completer<List<PendingDocument>>()
      ..complete([video()]);
    expect(await controller.select(video: true), isFalse);
    expect(controller.issue, DocumentSelectionIssue.totalSize);
    controller.clear();
    repository.pending = Completer<List<PendingDocument>>();
    final selection = controller.select(video: true);
    controller.clear();
    repository.pending!.complete([video()]);
    expect(await selection, isFalse);
    expect(controller.documents, isEmpty);
  });
  for (final width in [320.0, 1440.0]) {
    testWidgets('optional video selection and removal at $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final repository = FakeSelection();
      final controller = DocumentSelectionController(repository);
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routes: {
            '/record-video': (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.pop(context, video()),
                child: const Text('Confirm fixture'),
              ),
            ),
          },
          home: Scaffold(
            body: SingleChildScrollView(
              child: DocumentSelectionPanel(controller: controller),
            ),
          ),
        ),
      );
      await tester.ensureVisible(find.text('GRABAR VIDEO OPCIONAL'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('GRABAR VIDEO OPCIONAL'));
      await tester.pumpAndSettle();
      expect(controller.videos, isEmpty);
      await tester.tap(find.text('Confirm fixture'));
      await tester.pumpAndSettle();
      expect(find.text('30 segundos · Video opcional'), findsOneWidget);
      expect(find.text('0 de 20 archivos seleccionados'), findsOneWidget);
      await tester.ensureVisible(find.text('Quitar video'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Quitar video'));
      await tester.pumpAndSettle();
      expect(controller.videos, isEmpty);
      expect(tester.takeException(), isNull);
    });
  }
}
