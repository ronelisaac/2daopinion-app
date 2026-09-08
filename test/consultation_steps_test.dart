import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:segunda_opinion_app/controllers/consultation_steps_controller.dart';
import 'package:segunda_opinion_app/controllers/consultation_draft_controller.dart';
import 'package:segunda_opinion_app/controllers/guest_draft_controller.dart';
import 'package:segunda_opinion_app/core/app_theme.dart';
import 'package:segunda_opinion_app/domain/clinical_context.dart';
import 'package:segunda_opinion_app/domain/consultation_draft.dart';
import 'package:segunda_opinion_app/domain/country_config.dart';
import 'package:segunda_opinion_app/domain/saved_consultation_draft.dart';
import 'package:segunda_opinion_app/l10n/app_localizations.dart';
import 'package:segunda_opinion_app/views/draft_request_screen.dart';
import 'package:segunda_opinion_app/views/guest_request_screen.dart';
import 'package:segunda_opinion_app/widgets/informational_footer.dart';
import 'helpers/consultation_steps.dart';
import 'helpers/fake_draft_repository.dart';

Widget app(Widget home) => MaterialApp(
  theme: buildAppTheme(),
  locale: const Locale('es'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);
Future<void> press(WidgetTester tester, String text) async {
  final button = find.text(text);
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
}

Future<void> fill(WidgetTester tester, String label, String value) async {
  final field = find.widgetWithText(TextFormField, label);
  await tester.ensureVisible(field);
  await tester.enterText(field, value);
  await tester.pumpAndSettle();
}

void main() {
  test(
    'steps respect bounds, do not notify for repeats and stop after disposal',
    () {
      final steps = ConsultationStepsController();
      var changes = 0;
      steps.addListener(() => changes++);
      steps.previous();
      steps.select(4);
      steps.select(-1);
      expect(changes, 0);
      steps.next();
      expect(steps.index, 1);
      steps.select(3);
      expect(steps.isReview, isTrue);
      steps.next();
      expect(changes, 2);
      steps.dispose();
      steps.select(0);
      expect(changes, 2);
    },
  );

  for (final width in [320.0, 1440.0]) {
    testWidgets(
      'every field and modality survives steps, edit and review at $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final guest = GuestDraftController();
        var accesses = 0;
        await tester.pumpWidget(
          app(
            GuestRequestScreen(controller: guest, onAccess: () => accesses++),
          ),
        );
        await tester.pumpAndSettle();
        final sections = [
          {
            'Motivo de tu consulta': 'Motivo ficticio',
            'Detalles de la consulta': 'Detalles ficticios',
            'Tratamiento con medicamentos': 'Medicamento ficticio',
            'Tratamientos especiales': 'Tratamiento ficticio',
            'Propuestas terapéuticas previas': 'Propuesta ficticia',
          },
          {
            'Edad y contexto del paciente': 'Contexto ficticio',
            'Diagnóstico conocido o sospechado': 'Diagnóstico ficticio',
            'Síntomas y evolución': 'Evolución ficticia',
            'Antecedentes relevantes': 'Antecedentes ficticios',
            'Alergias y reacciones': 'Reacción ficticia',
          },
          {
            'Preguntas al especialista': 'Pregunta ficticia',
            'Estudios y documentación disponible': 'Estudio ficticio',
            'Especialidad solicitada': 'Especialidad ficticia',
          },
        ];
        for (var index = 0; index < sections.length; index++) {
          for (final entry in sections[index].entries) {
            await fill(tester, entry.key, entry.value);
          }
          if (index == 2) {
            final dropdown = find.byType(DropdownButtonFormField<String>);
            await tester.ensureVisible(dropdown);
            await tester.pumpAndSettle();
            await tester.tap(dropdown);
            await tester.pumpAndSettle();
            await tester.tap(find.text('Revisión + consulta').last);
            await tester.pumpAndSettle();
          }
          await press(tester, 'SIGUIENTE PASO');
          expect(accesses, 0);
        }
        expect(find.byType(TextFormField), findsNothing);
        for (final section in sections) {
          for (final value in section.values) {
            expect(find.text(value), findsOneWidget);
          }
        }
        expect(find.text('Revisión + consulta'), findsOneWidget);
        await press(tester, 'Editar Preferencias');
        await fill(tester, 'Preguntas al especialista', 'Pregunta revisada');
        await press(tester, 'SIGUIENTE PASO');
        expect(find.text('Pregunta revisada'), findsOneWidget);
        expect(find.text('Diagnóstico ficticio'), findsOneWidget);
        await press(tester, 'Editar Antecedentes');
        await fill(tester, 'Síntomas y evolución', 'Evolución revisada');
        await goToStep(tester, 3);
        expect(find.text('Pregunta revisada'), findsOneWidget);
        await tester.ensureVisible(find.text('CONTINUAR CON MI CUENTA'));
        await tester.pumpAndSettle();
        expect(
          tester.getRect(find.text('CONTINUAR CON MI CUENTA')).bottom,
          lessThanOrEqualTo(
            tester.getRect(find.byType(InformationalFooter)).top,
          ),
        );
        await press(tester, 'CONTINUAR CON MI CUENTA');
        expect(accesses, 1);
        expect(guest.resumeAfterAccess, isTrue);
        expect(guest.content!.reason, 'Motivo ficticio');
        expect(
          guest.content!.clinicalContext.symptomEvolution,
          'Evolución revisada',
        );
        expect(guest.content!.clinicalContext.questions, 'Pregunta revisada');
        expect(
          guest.content!.clinicalContext.knownDiagnosis,
          'Diagnóstico ficticio',
        );
        expect(
          guest.content!.clinicalContext.modality,
          'review_and_consultation',
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'empty review is explicitly incomplete and never implies no allergies',
    (tester) async {
      final guest = GuestDraftController();
      await tester.pumpWidget(
        app(GuestRequestScreen(controller: guest, onAccess: () {})),
      );
      await goToStep(tester, 3);
      expect(find.text('No informado'), findsNWidgets(13));
      expect(
        find.textContaining('no valida la suficiencia clínica'),
        findsOneWidget,
      );
      expect(guest.content, isNull);
    },
  );

  testWidgets(
    'saving locks step navigation and does not discard reviewed fields',
    (tester) async {
      final repository = FakeDraftRepository();
      await tester.pumpWidget(
        app(
          DraftRequestScreen(
            controller: ConsultationDraftController(
              repository,
              country: CountryConfig.chile,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await fill(tester, 'Motivo de tu consulta', 'Prueba guardada');
      await goToStep(tester, 3);
      await tester.ensureVisible(find.byKey(const ValueKey('draftConsent')));
      await tester.tap(find.byKey(const ValueKey('draftConsent')));
      await tester.pumpAndSettle();
      repository.pending = Completer<void>();
      await tester.ensureVisible(find.text('GUARDAR BORRADOR'));
      await tester.tap(find.text('GUARDAR BORRADOR'));
      await tester.pump();
      for (final chip in tester.widgetList<ChoiceChip>(
        find.byType(ChoiceChip),
      )) {
        expect(chip.onSelected, isNull);
      }
      expect(repository.saves, 1);
      repository.pending!.complete();
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('draftSaved')), findsOneWidget);
      expect(repository.record!.content.reason, 'Prueba guardada');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'reloading a newer draft resets clinical fields retained between steps',
    (tester) async {
      SavedConsultationDraft record(String value, int revision) =>
          SavedConsultationDraft(
            id: 'DraftAbCdEfGhIjKl123',
            revision: revision,
            updatedAt: DateTime.utc(2026, 9, 8),
            content: ConsultationDraft(
              countryCode: 'CL',
              reason: 'Ficticio',
              details: '',
              clinicalContext: ClinicalContext(
                questions: value,
                symptomEvolution: value,
              ),
            ),
          );
      final repository = FakeDraftRepository()
        ..record = record('Versión inicial', 1);
      await tester.pumpWidget(
        app(
          DraftRequestScreen(
            controller: ConsultationDraftController(
              repository,
              country: CountryConfig.chile,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await goToStep(tester, 2);
      await fill(tester, 'Preguntas al especialista', 'Cambio local ficticio');
      repository.record = record('Versión remota ficticia', 2);
      await press(tester, 'RECARGAR VERSIÓN GUARDADA');
      await press(tester, 'DESCARTAR CAMBIOS LOCALES');
      await goToStep(tester, 3);
      expect(find.text('Versión remota ficticia'), findsNWidgets(2));
      expect(find.text('Cambio local ficticio'), findsNothing);
      await goToStep(tester, 2);
      expect(
        tester
            .widget<TextFormField>(
              find.widgetWithText(TextFormField, 'Preguntas al especialista'),
            )
            .controller!
            .text,
        'Versión remota ficticia',
      );
      expect(repository.saves, 0);
      expect(tester.takeException(), isNull);
    },
  );
}
