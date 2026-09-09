import 'package:flutter/material.dart';
import '../core/localization.dart';
import '../domain/consultation_draft.dart';
import 'consultation_readiness.dart';

class ConsultationReview extends StatelessWidget {
  const ConsultationReview({
    super.key,
    required this.content,
    required this.onEdit,
  });
  final ConsultationDraft content;
  final ValueChanged<int>? onEdit;
  @override
  Widget build(BuildContext context) {
    final text = strings(context);
    final clinical = content.clinicalContext;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(text.reviewTitle, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Text(text.reviewNotice),
        const SizedBox(height: 16),
        ConsultationReadiness(content: content, onEdit: onEdit),
        const SizedBox(height: 16),
        _ReviewSection(
          title: text.consultationStep,
          onEdit: onEdit == null ? null : () => onEdit!(0),
          values: {
            text.reason: content.reason,
            text.details: content.details,
            text.medicines: content.medicines,
            text.specialTreatments: content.specialTreatments,
            text.previousProposals: content.previousProposals,
          },
        ),
        _ReviewSection(
          title: text.contextStep,
          onEdit: onEdit == null ? null : () => onEdit!(1),
          values: {
            text.birthDate: clinical.birthDate == null
                ? ''
                : MaterialLocalizations.of(context).formatMediumDate(
                    DateTime(
                      clinical.birthDate!.year,
                      clinical.birthDate!.month,
                      clinical.birthDate!.day,
                    ),
                  ),
            text.patientContext: clinical.patientContext,
            text.knownDiagnosis: clinical.knownDiagnosis,
            text.symptomEvolution: clinical.symptomEvolution,
            text.medicalHistory: clinical.medicalHistory,
            text.allergies: clinical.allergies,
          },
        ),
        _ReviewSection(
          title: text.goalsStep,
          onEdit: onEdit == null ? null : () => onEdit!(2),
          values: {
            text.questions: clinical.questions,
            if (clinical.studySummary.isNotEmpty)
              text.legacyStudySummary: clinical.studySummary,
            text.specialty: clinical.specialty,
            text.preferredModality: switch (clinical.modality) {
              'document_review' => text.modalityDocument,
              'review_and_consultation' => text.modalityConsultation,
              _ => text.modalityUnsure,
            },
          },
        ),
      ],
    );
  }
}

class _ReviewSection extends StatelessWidget {
  const _ReviewSection({
    required this.title,
    required this.values,
    required this.onEdit,
  });
  final String title;
  final Map<String, String> values;
  final VoidCallback? onEdit;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 16),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              TextButton(
                onPressed: onEdit,
                child: Text(strings(context).editSection(title)),
              ),
            ],
          ),
          for (final entry in values.entries) ...[
            const SizedBox(height: 12),
            Text(
              entry.key,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              entry.value.trim().isEmpty
                  ? strings(context).notProvided
                  : entry.value,
            ),
          ],
        ],
      ),
    ),
  );
}
