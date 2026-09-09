import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:segunda_opinion_app/controllers/private_documents_controller.dart';
import 'package:segunda_opinion_app/controllers/document_selection_controller.dart';
import 'package:segunda_opinion_app/domain/private_document.dart';
import 'package:segunda_opinion_app/domain/pending_document.dart';
import 'package:segunda_opinion_app/widgets/private_documents_panel.dart';
import 'package:segunda_opinion_app/widgets/document_selection_panel.dart';
import 'form_inputs_test.dart' show FakeSelection;
import 'consultation_steps_test.dart' show app;

class FakePrivateDocuments implements PrivateDocumentRepository {
  int uploads = 0;
  int deletes = 0;
  int? failAt;
  Completer<void>? wait;
  List<PrivateDocument> records = [];
  @override
  Future<List<PrivateDocument>> list(String draftId) async => records;
  @override
  Future<PrivateDocument> upload(
    String draftId,
    PendingDocument document, {
    required bool accepted,
    required TransferCancellation cancellation,
    required void Function(double) onProgress,
  }) async {
    uploads++;
    onProgress(0.5);
    cancellation.bind(() {
      if (wait != null && !wait!.isCompleted) wait!.complete();
    });
    if (wait != null) await wait!.future;
    cancellation.check();
    if (failAt == uploads) {
      throw const DocumentFailure(DocumentIssue.unavailable);
    }
    final result = PrivateDocument(
      id: '$uploads',
      draftId: draftId,
      title: document.title,
      fileName: document.fileName,
      size: document.bytes.length,
      state: PrivateDocumentState.stored,
    );
    records = [...records, result];
    return result;
  }

  @override
  Future<Uint8List> read(String draftId, String documentId) async =>
      Uint8List(0);
  @override
  Future<void> delete(String draftId, String documentId) async {
    deletes++;
    records = [];
  }
}

PendingDocument sample() => PendingDocument(
  title: 'Ficticio',
  fileName: 'ficticio.pdf',
  bytes: Uint8List(4),
);
void main() {
  testWidgets('linked files expose neither upload nor deletion controls', (
    tester,
  ) async {
    final repository = FakePrivateDocuments()
      ..records = [
        const PrivateDocument(
          id: 'file',
          draftId: 'draft',
          title: 'Ficticio',
          fileName: 'prueba.pdf',
          size: 4,
          state: PrivateDocumentState.stored,
        ),
      ];
    final controller = PrivateDocumentsController(repository);
    final selection = DocumentSelectionController(FakeSelection());
    addTearDown(controller.dispose);
    addTearDown(selection.dispose);
    await controller.load('draft');
    await tester.pumpWidget(
      app(
        Scaffold(
          body: SingleChildScrollView(
            child: PrivateDocumentsPanel(
              controller: controller,
              selection: selection,
              readOnly: true,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(CheckboxListTile), findsNothing);
    expect(find.byType(FilledButton), findsNothing);
    expect(find.textContaining('Adjuntos vinculados'), findsOneWidget);
    expect(find.text('Ficticio'), findsOneWidget);
    expect(repository.deletes, 0);
    expect(tester.takeException(), isNull);
  });
  test('no upload without saved draft or explicit separate consent', () async {
    final repository = FakePrivateDocuments();
    final controller = PrivateDocumentsController(repository);
    addTearDown(controller.dispose);
    await controller.upload([sample()], accepted: true, onUploaded: (_) {});
    expect(repository.uploads, 0);
    await controller.load('draft');
    await controller.upload([sample()], accepted: false, onUploaded: (_) {});
    expect(repository.uploads, 0);
  });
  test(
    'partial batch keeps confirmed files and never acknowledges a failed file',
    () async {
      final repository = FakePrivateDocuments()..failAt = 2;
      final controller = PrivateDocumentsController(repository);
      addTearDown(controller.dispose);
      await controller.load('draft');
      var acknowledged = 0;
      await controller.upload(
        [sample(), sample(), sample()],
        accepted: true,
        onUploaded: (_) => acknowledged++,
      );
      expect(repository.uploads, 2);
      expect(acknowledged, 1);
      expect(controller.documents.length, 1);
      expect(controller.issue, DocumentIssue.unavailable);
      expect(controller.busy, isFalse);
    },
  );
  test(
    'cancel and disposal abort transfer without publishing late patient data',
    () async {
      final repository = FakePrivateDocuments()..wait = Completer<void>();
      final controller = PrivateDocumentsController(repository);
      await controller.load('draft');
      var acknowledged = 0;
      final upload = controller.upload(
        [sample()],
        accepted: true,
        onUploaded: (_) => acknowledged++,
      );
      expect(controller.transferring, isTrue);
      controller.dispose();
      await upload;
      expect(acknowledged, 0);
      expect(controller.documents, isEmpty);
    },
  );
  test(
    'token invokes handler even if cancellation happened before transport started',
    () {
      final cancellation = TransferCancellation()..cancel();
      var calls = 0;
      cancellation.bind(() => calls++);
      expect(calls, 1);
      expect(cancellation.check, throwsA(isA<DocumentFailure>()));
    },
  );
  test('cancel keeps pending selection and lets the user retry', () async {
    final repository = FakePrivateDocuments()..wait = Completer<void>();
    final controller = PrivateDocumentsController(repository);
    addTearDown(controller.dispose);
    await controller.load('draft');
    var acknowledged = 0;
    final upload = controller.upload(
      [sample()],
      accepted: true,
      onUploaded: (_) => acknowledged++,
    );
    controller.cancel();
    await upload;
    expect(controller.issue, DocumentIssue.cancelled);
    expect(controller.transferring, isFalse);
    expect(acknowledged, 0);
    repository.wait = null;
    await controller.upload(
      [sample()],
      accepted: true,
      onUploaded: (_) => acknowledged++,
    );
    expect(acknowledged, 1);
    expect(controller.issue, isNull);
    await controller.delete(controller.documents.single);
    expect(repository.deletes, 1);
    expect(controller.documents, isEmpty);
  });
  testWidgets('emulator selection explains the separate upload action', (
    tester,
  ) async {
    final selection = DocumentSelectionController(FakeSelection());
    addTearDown(selection.dispose);
    await tester.pumpWidget(
      app(
        Scaffold(
          body: SingleChildScrollView(
            child: DocumentSelectionPanel(
              controller: selection,
              localUploadsEnabled: true,
            ),
          ),
        ),
      ),
    );
    expect(find.textContaining('En Revisión podrás subirlos'), findsOneWidget);
    expect(find.textContaining('todavía no está habilitada'), findsNothing);
  });
  for (final width in [320.0, 1440.0]) {
    testWidgets('explicit local upload and confirmed list at $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final repository = FakePrivateDocuments();
      final controller = PrivateDocumentsController(repository);
      addTearDown(controller.dispose);
      final selection = DocumentSelectionController(FakeSelection());
      addTearDown(selection.dispose);
      await selection.select();
      await controller.load('draft');
      await tester.pumpWidget(
        app(
          Scaffold(
            body: SingleChildScrollView(
              child: PrivateDocumentsPanel(
                controller: controller,
                selection: selection,
              ),
            ),
          ),
        ),
      );
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('SUBIR ARCHIVOS PRIVADOS'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('SUBIR ARCHIVOS PRIVADOS'));
      await tester.pumpAndSettle();
      expect(selection.documents, isEmpty);
      expect(
        find.text('Archivo guardado · Sin revisión médica'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
