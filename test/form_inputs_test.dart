import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:segunda_opinion_app/controllers/chip_input_controller.dart';
import 'package:segunda_opinion_app/controllers/document_selection_controller.dart';
import 'package:segunda_opinion_app/domain/birth_date.dart';
import 'package:segunda_opinion_app/domain/clinical_context.dart';
import 'package:segunda_opinion_app/domain/form_limits.dart';
import 'package:segunda_opinion_app/domain/pending_document.dart';
import 'package:segunda_opinion_app/domain/repositories/document_selection_repository.dart';
import 'package:segunda_opinion_app/repositories/clinical_context_mapper.dart';
import 'package:segunda_opinion_app/widgets/chip_request_field.dart';
import 'package:segunda_opinion_app/widgets/document_selection_panel.dart';
import 'package:segunda_opinion_app/widgets/birth_date_field.dart';
import 'package:segunda_opinion_app/widgets/request_field.dart';
import 'package:segunda_opinion_app/widgets/text_limit_formatter.dart';
import 'consultation_steps_test.dart' show app;

class FakeSelection implements DocumentSelectionRepository {
  int calls = 0;
  Completer<List<PendingDocument>>? pending;
  int batchSize = 1;
  bool cancel = false;
  @override
  Future<List<PendingDocument>> select({
    required int maxFiles,
    required int maxTotalBytes,
    bool video = false,
  }) async {
    calls++;
    return pending != null
        ? pending!.future
        : cancel
        ? []
        : List.generate(
            batchSize,
            (index) => PendingDocument(
              title: 'Estudio ficticio $index',
              fileName: 'ficticio.pdf',
              bytes: Uint8List.fromList([37, 80, 68, 70]),
            ),
          );
  }
}

void main() {
  test(
    'chips split pasted delimiters, retain pending, remove and enforce aggregate UTF16 budget',
    () {
      final controller = ChipInputController('');
      addTearDown(controller.dispose);
      controller.edit('Uno, Dos, ,Tres');
      expect(controller.items, ['Uno', 'Dos']);
      expect(controller.value, 'Uno\nDos\nTres');
      controller.edit(controller.pending, commit: true);
      expect(controller.items, ['Uno', 'Dos', 'Tres']);
      controller.remove(1);
      expect(controller.value, 'Uno\nTres');
      controller.restore('😀' * 2000);
      expect(controller.edit('extra'), isFalse);
      expect(controller.value.length, 4000);
      controller.remove(0);
      expect(controller.edit('Nuevo,'), isTrue);
    },
  );
  test('legacy free text is not split by existing commas or discarded', () {
    final controller = ChipInputController('Texto previo, con comas');
    expect(controller.items, ['Texto previo, con comas']);
    expect(controller.value, 'Texto previo, con comas');
    controller.dispose();
  });
  test(
    'birth date validates calendar, future, lower bound and mapper compatibility',
    () {
      final today = DateTime.utc(2026, 9, 8);
      expect(const BirthDate(2000, 2, 29).validAt(today), isTrue);
      for (final date in [
        const BirthDate(2001, 2, 29),
        const BirthDate(2026, 9, 9),
        const BirthDate(1899, 1, 1),
        const BirthDate(2000, 13, 1),
      ]) {
        expect(date.validAt(today), isFalse);
      }
      final encoded = ClinicalContextMapper.encode(
        const ClinicalContext(birthDate: BirthDate(2000, 2, 29)),
      );
      expect(ClinicalContextMapper.decode(encoded).birthDate!.day, 29);
      encoded.remove('birthDate');
      expect(ClinicalContextMapper.decode(encoded).birthDate, isNull);
    },
  );
  test(
    'text formatter rejects overflow including combined Unicode without truncating paste',
    () {
      const formatter = TextLimitFormatter(FormLimits.text);
      const previous = TextEditingValue(text: 'Previo');
      expect(
        formatter.formatEditUpdate(
          previous,
          TextEditingValue(text: 'a' * 4001),
        ),
        previous,
      );
      expect(
        formatter.formatEditUpdate(
          previous,
          TextEditingValue(text: '👩‍⚕️' * 1000),
        ),
        previous,
      );
      expect(
        formatter
            .formatEditUpdate(previous, TextEditingValue(text: 'a' * 4000))
            .text
            .length,
        4000,
      );
    },
  );
  test(
    'file selection caps count, handles cancel and clears on session change',
    () async {
      final repository = FakeSelection();
      final controller = DocumentSelectionController(repository);
      addTearDown(controller.dispose);
      repository.cancel = true;
      expect(await controller.select(), isFalse);
      repository.cancel = false;
      for (var count = 0; count < FormLimits.documents; count++) {
        expect(await controller.select(), isTrue);
      }
      expect(await controller.select(), isFalse);
      expect(controller.issue, DocumentSelectionIssue.limit);
      controller.clear();
      repository.pending = Completer<List<PendingDocument>>();
      final selecting = controller.select();
      controller.clear();
      repository.pending!.complete([
        PendingDocument(
          title: 'Interrumpido',
          fileName: 'ficticio.pdf',
          bytes: Uint8List(1),
        ),
      ]);
      expect(await selecting, isFalse);
      expect(controller.documents, isEmpty);
    },
  );
  test('file size is independently bounded in controller', () async {
    final repository = FakeSelection()
      ..pending = Completer<List<PendingDocument>>();
    final controller = DocumentSelectionController(repository);
    addTearDown(controller.dispose);
    final selecting = controller.select();
    repository.pending!.complete([
      PendingDocument(
        title: 'Prueba',
        fileName: 'ficticio.pdf',
        bytes: Uint8List(FormLimits.documentBytes + 1),
      ),
    ]);
    expect(await selecting, isFalse);
    expect(controller.documents, isEmpty);
  });
  for (final width in [320.0, 1440.0]) {
    testWidgets(
      'chip input supports comma, Enter, pending restore, deletion and long tokens at $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final source = TextEditingController();
        addTearDown(source.dispose);
        await tester.pumpWidget(
          app(
            Scaffold(
              body: SingleChildScrollView(
                child: ChipRequestField(
                  label: 'Prueba',
                  hint: 'Ejemplo',
                  controller: source,
                ),
              ),
            ),
          ),
        );
        await tester.enterText(find.byType(TextFormField), 'Uno,Dos,');
        await tester.pumpAndSettle();
        expect(find.byType(InputChip), findsNWidgets(2));
        await tester.enterText(find.byType(TextFormField), 'Tres');
        expect(source.text, 'Uno\nDos\nTres');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
        expect(find.byType(InputChip), findsNWidgets(3));
        await tester.tap(find.byTooltip('Quitar elemento').first);
        await tester.pumpAndSettle();
        expect(source.text, 'Dos\nTres');
        source.text = 'Palabra' * 500;
        await tester.pumpAndSettle();
        expect(find.byType(InputChip), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'documents require title and show a removable pending list, never uploaded',
    (tester) async {
      final controller = DocumentSelectionController(FakeSelection());
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
      expect(find.text('Estudio ficticio 0'), findsOneWidget);
      expect(find.textContaining('Pendiente de subir'), findsOneWidget);
      expect(find.textContaining('NO guarda archivos'), findsOneWidget);
      await tester.tap(find.text('Quitar elemento'));
      await tester.pumpAndSettle();
      expect(controller.documents, isEmpty);
    },
  );
  testWidgets(
    'birth picker bounds dates and can clear; multiline fields expose counter',
    (tester) async {
      await tester.pumpWidget(
        app(Scaffold(body: BirthDateField(value: null, onChanged: (_) {}))),
      );
      await tester.tap(find.text('Seleccionar fecha'));
      await tester.pumpAndSettle();
      final picker = tester.widget<DatePickerDialog>(
        find.byType(DatePickerDialog),
      );
      expect(picker.firstDate.year, 1900);
      expect(picker.lastDate.year, DateTime.now().toUtc().year);
      await tester.pumpWidget(
        app(
          Scaffold(
            body: RequestField(
              label: 'Detalle',
              hint: '',
              controller: TextEditingController(),
              minLines: 4,
              maxLines: 10,
            ),
          ),
        ),
      );
      expect(
        tester
            .widget<TextField>(find.byType(TextField))
            .decoration!
            .counterText,
        isNull,
      );
      expect(tester.widget<TextField>(find.byType(TextField)).minLines, 4);
    },
  );
}
