import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:segunda_opinion_app/controllers/guest_draft_controller.dart';
import 'package:segunda_opinion_app/core/app_theme.dart';
import 'package:segunda_opinion_app/domain/birth_date.dart';
import 'package:segunda_opinion_app/domain/clinical_context.dart';
import 'package:segunda_opinion_app/domain/consultation_draft.dart';
import 'package:segunda_opinion_app/domain/form_limits.dart';
import 'package:segunda_opinion_app/l10n/app_localizations.dart';
import 'package:segunda_opinion_app/views/guest_request_screen.dart';
import 'helpers/consultation_steps.dart';

void main() {
  ConsultationDraft draft({
    String reason = 'Motivo ficticio',
    String details = 'Detalle ficticio',
    String modality = 'document_review',
    BirthDate? birthDate,
  }) => ConsultationDraft(
    countryCode: 'CL',
    reason: reason,
    details: details,
    clinicalContext: ClinicalContext(modality: modality, birthDate: birthDate),
  );

  test(
    'submission requirements reject whitespace and unspecified modality',
    () {
      final content = draft(reason: ' \n\t ', details: ' ', modality: '');
      expect(content.missingSubmissionFields, SubmissionField.values);
      expect(content.withinStorageLimits, true);
      expect(content.readyForSubmission, false);
      expect(draft().readyForSubmission, true);
      expect(
        draft(modality: 'review_and_consultation').readyForSubmission,
        true,
      );
      expect(draft(modality: 'other').readyForSubmission, false);
    },
  );

  test('valid required fields do not bypass length or date validation', () {
    expect(draft(details: 'a' * FormLimits.text).readyForSubmission, true);
    expect(
      draft(details: 'a' * (FormLimits.text + 1)).readyForSubmission,
      false,
    );
    expect(
      draft(birthDate: const BirthDate(2025, 2, 29)).readyForSubmission,
      false,
    );
    expect(
      draft(birthDate: const BirthDate(2000, 2, 29)).readyForSubmission,
      true,
    );
  });

  for (final width in [320.0, 768.0, 1440.0]) {
    testWidgets('review points to required fields and clears errors at $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final guest = GuestDraftController();
      var continued = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: GuestRequestScreen(
            controller: guest,
            onAccess: () => continued = true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Requerido para enviar; puedes guardar el borrador sin completarlo.',
        ),
        findsNWidgets(2),
      );
      await goToStep(tester, 3);
      final reasonLink = find.text(
        'Motivo de tu consulta · Pendiente · completar',
      );
      await tester.ensureVisible(reasonLink);
      await tester.tap(reasonLink);
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Escribe el motivo de tu consulta; no puede contener solo espacios.',
        ),
        findsOneWidget,
      );
      final reason = find.widgetWithText(
        TextFormField,
        'Motivo de tu consulta',
      );
      await tester.enterText(reason, '  ');
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Escribe el motivo de tu consulta; no puede contener solo espacios.',
        ),
        findsOneWidget,
      );
      await tester.enterText(reason, 'Motivo ficticio');
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Escribe el motivo de tu consulta; no puede contener solo espacios.',
        ),
        findsNothing,
      );
      await goToStep(tester, 2);
      final dropdown = find.byType(DropdownButtonFormField<String>);
      await tester.ensureVisible(dropdown);
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Elige revisión documental o revisión + consulta antes de enviar.',
        ),
        findsOneWidget,
      );
      await tester.tap(dropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Revisión documental').last);
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Elige revisión documental o revisión + consulta antes de enviar.',
        ),
        findsNothing,
      );
      await goToStep(tester, 3);
      expect(
        find.text('Motivo de tu consulta · Informado · editar'),
        findsOneWidget,
      );
      expect(
        find.text('Detalles de la consulta · Pendiente · completar'),
        findsOneWidget,
      );
      final action = find.text('CONTINUAR CON MI CUENTA');
      await tester.ensureVisible(action);
      await tester.pumpAndSettle();
      await tester.tap(action);
      await tester.pumpAndSettle();
      expect(continued, true);
      expect(guest.content!.details, '');
      expect(tester.takeException(), isNull);
    });
  }
}
