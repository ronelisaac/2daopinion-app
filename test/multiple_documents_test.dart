import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:segunda_opinion_app/controllers/document_selection_controller.dart';
import 'package:segunda_opinion_app/domain/form_limits.dart';
import 'package:segunda_opinion_app/domain/pending_document.dart';
import 'package:segunda_opinion_app/widgets/document_selection_panel.dart';
import 'consultation_steps_test.dart' show app;
import 'form_inputs_test.dart' show FakeSelection;

void main() {
  test(
    'batch append preserves earlier selections and rejects over-count without partial append',
    () async {
      final repository = FakeSelection()..batchSize = 3;
      final controller = DocumentSelectionController(repository);
      addTearDown(controller.dispose);
      expect(await controller.select(), isTrue);
      final first = controller.documents.first;
      expect(await controller.select(), isTrue);
      expect(controller.documents.length, 6);
      expect(identical(controller.documents.first, first), isTrue);
      repository.batchSize = 15;
      expect(await controller.select(), isFalse);
      expect(controller.documents.length, 6);
      expect(controller.issue, DocumentSelectionIssue.limit);
    },
  );
  test(
    'total byte budget rejects batch atomically independently of individual file limits',
    () async {
      final repository = FakeSelection();
      final controller = DocumentSelectionController(repository);
      addTearDown(controller.dispose);
      await controller.select();
      repository.pending = Completer<List<PendingDocument>>();
      final selecting = controller.select();
      final bytes = Uint8List(FormLimits.documentBytes);
      repository.pending!.complete(
        List.generate(
          11,
          (index) => PendingDocument(
            title: 'Prueba $index',
            fileName: 'ficticio.pdf',
            bytes: bytes,
          ),
        ),
      );
      expect(await selecting, isFalse);
      expect(controller.documents.length, 1);
      expect(controller.issue, DocumentSelectionIssue.totalSize);
    },
  );
  test(
    'renaming validates title and cannot edit a file cleared during a dialog',
    () async {
      final controller = DocumentSelectionController(FakeSelection());
      addTearDown(controller.dispose);
      await controller.select();
      final document = controller.documents.single;
      expect(controller.rename(document, ''), isFalse);
      expect(controller.rename(document, 'x' * 121), isFalse);
      expect(controller.rename(document, 'Informe ficticio'), isTrue);
      expect(
        identical(controller.documents.single.bytes, document.bytes),
        isTrue,
      );
      controller.clear();
      expect(controller.rename(document, 'Otra edición'), isFalse);
    },
  );
  for (final width in [320.0, 1440.0]) {
    testWidgets(
      'multiple attachment UI adds batches, edits each title and removes one at $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final controller = DocumentSelectionController(
          FakeSelection()..batchSize = 2,
        );
        addTearDown(controller.dispose);
        await tester.pumpWidget(
          app(
            Scaffold(
              body: SingleChildScrollView(
                child: DocumentSelectionPanel(controller: controller),
              ),
            ),
          ),
        );
        await tester.tap(find.text('SELECCIONAR VARIOS ARCHIVOS'));
        await tester.pumpAndSettle();
        expect(find.text('2 de 20 archivos seleccionados'), findsOneWidget);
        expect(find.text('AGREGAR MÁS ARCHIVOS'), findsOneWidget);
        await tester.tap(find.text('AGREGAR MÁS ARCHIVOS'));
        await tester.pumpAndSettle();
        expect(controller.documents.length, 4);
        await tester.ensureVisible(find.text('Editar título').first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Editar título').first);
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextFormField), 'Informe ficticio');
        await tester.pumpAndSettle();
        await tester.tap(find.text('APLICAR TÍTULO'));
        await tester.pumpAndSettle();
        expect(controller.documents.first.title, 'Informe ficticio');
        await tester.ensureVisible(find.text('Quitar elemento').first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Quitar elemento').first);
        await tester.pumpAndSettle();
        expect(controller.documents.length, 3);
        expect(controller.documents.first.title, 'Estudio ficticio 1');
        expect(tester.takeException(), isNull);
      },
    );
  }
}
