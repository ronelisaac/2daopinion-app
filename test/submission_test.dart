import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:segunda_opinion_app/controllers/consultation_submission_controller.dart';
import 'package:segunda_opinion_app/domain/consultation_submission.dart';
import 'package:segunda_opinion_app/domain/consultation_draft.dart';
import 'package:segunda_opinion_app/domain/clinical_context.dart';
import 'package:segunda_opinion_app/domain/saved_consultation_draft.dart';
import 'package:segunda_opinion_app/domain/repositories/consultation_submission_repository.dart';
import 'package:segunda_opinion_app/widgets/submission_panel.dart';
import 'package:segunda_opinion_app/l10n/app_localizations.dart';

final saved = SavedConsultationDraft(
  id: 'DraftAbCdEfGhIjKl123',
  revision: 1,
  updatedAt: DateTime.utc(2026),
  content: const ConsultationDraft(
    countryCode: 'CL',
    reason: 'Ficticio',
    details: 'Detalle ficticio',
    clinicalContext: ClinicalContext(modality: 'document_review'),
  ),
);

class ControlledSubmissions implements ConsultationSubmissionRepository {
  ConsultationSubmission? receipt;
  SubmissionFailure? failure;
  Completer<ConsultationSubmission>? pending;
  int sends = 0;
  @override
  Future<ConsultationSubmission?> load() async {
    if (failure != null) throw failure!;
    return receipt;
  }

  @override
  Future<ConsultationSubmission> submit(
    SavedConsultationDraft draft, {
    required bool accepted,
  }) async {
    sends++;
    if (failure != null) throw failure!;
    return pending != null
        ? pending!.future
        : receipt ??= ConsultationSubmission(
            id: draft.id,
            revision: draft.revision,
            submittedAt: DateTime.utc(2026),
          );
  }
}

void main() {
  testWidgets(
    'changing the linked batch resets explicit submission acceptance',
    (tester) async {
      final controller = ConsultationSubmissionController(
        ControlledSubmissions(),
      );
      addTearDown(controller.dispose);
      await controller.load();
      Widget screen(int count) => MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: SubmissionPanel(
              controller: controller,
              draft: saved,
              dirty: false,
              hasAttachments: false,
              blocked: false,
              linkedFiles: count,
            ),
          ),
        ),
      );
      await tester.pumpWidget(screen(1));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(CheckboxListTile));
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();
      expect(
        tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
        true,
      );
      await tester.pumpWidget(screen(2));
      await tester.pumpAndSettle();
      expect(
        tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
        false,
      );
      expect(tester.takeException(), isNull);
    },
  );
  test(
    'failed refresh clears old receipt and blocks blind submission',
    () async {
      final repository = ControlledSubmissions()
        ..receipt = ConsultationSubmission(
          id: saved.id,
          revision: 1,
          submittedAt: DateTime.utc(2026),
        );
      final controller = ConsultationSubmissionController(repository);
      addTearDown(controller.dispose);
      await controller.load();
      expect(controller.receipt, isNotNull);
      repository.failure = const SubmissionFailure(SubmissionIssue.session);
      await controller.load();
      expect(controller.receipt, isNull);
      expect(controller.loaded, isFalse);
      await controller.submit(
        saved,
        accepted: true,
        dirty: false,
        hasAttachments: false,
      );
      expect(repository.sends, 0);
    },
  );
  test(
    'requires loaded receipt, separate consent, saved complete content and no files',
    () async {
      final repository = ControlledSubmissions();
      final controller = ConsultationSubmissionController(repository);
      addTearDown(controller.dispose);
      await controller.submit(
        saved,
        accepted: true,
        dirty: false,
        hasAttachments: false,
      );
      expect(repository.sends, 0);
      await controller.load();
      await controller.submit(
        saved,
        accepted: false,
        dirty: false,
        hasAttachments: false,
      );
      expect(controller.issue, SubmissionIssue.consent);
      await controller.submit(
        saved,
        accepted: true,
        dirty: true,
        hasAttachments: false,
      );
      expect(controller.issue, SubmissionIssue.unsaved);
      await controller.submit(
        null,
        accepted: true,
        dirty: false,
        hasAttachments: false,
      );
      expect(controller.issue, SubmissionIssue.unsaved);
      await controller.submit(
        saved,
        accepted: true,
        dirty: false,
        hasAttachments: true,
      );
      expect(controller.issue, SubmissionIssue.attachments);
      final incomplete = SavedConsultationDraft(
        id: saved.id,
        revision: 1,
        updatedAt: saved.updatedAt,
        content: const ConsultationDraft(
          countryCode: 'CL',
          reason: '',
          details: '',
        ),
      );
      await controller.submit(
        incomplete,
        accepted: true,
        dirty: false,
        hasAttachments: false,
      );
      expect(controller.issue, SubmissionIssue.invalid);
      expect(repository.sends, 0);
    },
  );
  test(
    'single in-flight submit, restored receipt and no duplicate writes',
    () async {
      final repository = ControlledSubmissions()..pending = Completer();
      final controller = ConsultationSubmissionController(repository);
      addTearDown(controller.dispose);
      await controller.load();
      final sending = controller.submit(
        saved,
        accepted: true,
        dirty: false,
        hasAttachments: false,
      );
      await controller.submit(
        saved,
        accepted: true,
        dirty: false,
        hasAttachments: false,
      );
      expect(repository.sends, 1);
      final receipt = ConsultationSubmission(
        id: saved.id,
        revision: 1,
        submittedAt: DateTime.utc(2026),
      );
      repository.receipt = receipt;
      repository.pending!.complete(receipt);
      await sending;
      expect(controller.receipt!.reference, 'SO-${saved.id}');
      await controller.submit(
        saved,
        accepted: true,
        dirty: false,
        hasAttachments: false,
      );
      expect(repository.sends, 1);
      final restored = ConsultationSubmissionController(repository);
      addTearDown(restored.dispose);
      await restored.load();
      expect(restored.receipt, receipt);
    },
  );
  test(
    'failed load blocks sending; failed confirmation retry and disposal are safe',
    () async {
      final repository = ControlledSubmissions()
        ..failure = const SubmissionFailure(SubmissionIssue.unavailable);
      final controller = ConsultationSubmissionController(repository);
      await controller.load();
      expect(controller.loaded, false);
      await controller.submit(
        saved,
        accepted: true,
        dirty: false,
        hasAttachments: false,
      );
      expect(repository.sends, 0);
      repository.failure = null;
      await controller.load();
      repository.failure = const SubmissionFailure(SubmissionIssue.conflict);
      await controller.submit(
        saved,
        accepted: true,
        dirty: false,
        hasAttachments: false,
      );
      expect(controller.issue, SubmissionIssue.conflict);
      expect(controller.receipt, null);
      repository.failure = null;
      repository.pending = Completer();
      final pending = controller.submit(
        saved,
        accepted: true,
        dirty: false,
        hasAttachments: false,
      );
      controller.dispose();
      repository.pending!.complete(
        ConsultationSubmission(
          id: saved.id,
          revision: 1,
          submittedAt: DateTime.utc(2026),
        ),
      );
      await pending;
      expect(controller.receipt, null);
    },
  );
  for (final width in [320.0, 1440.0]) {
    testWidgets('submission consent and receipt at $width px', (tester) async {
      await tester.binding.setSurfaceSize(Size(width, 1800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final repository = ControlledSubmissions();
      final controller = ConsultationSubmissionController(repository);
      addTearDown(controller.dispose);
      await controller.load();
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: SubmissionPanel(
                controller: controller,
                draft: saved,
                dirty: false,
                hasAttachments: false,
                blocked: false,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(repository.sends, 0);
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(repository.sends, 1);
      expect(find.text('Recepción confirmada: SO-${saved.id}'), findsOneWidget);
      expect(find.byType(CheckboxListTile), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
