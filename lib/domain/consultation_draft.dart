import 'clinical_context.dart';
import 'form_limits.dart';

enum SubmissionField { reason, details, modality }

class ConsultationDraft {
  const ConsultationDraft({
    required this.countryCode,
    required this.reason,
    required this.details,
    this.medicines = '',
    this.specialTreatments = '',
    this.previousProposals = '',
    this.clinicalContext = const ClinicalContext(),
  });

  final String countryCode;
  final String reason;
  final String details;
  final String medicines;
  final String specialTreatments;
  final String previousProposals;
  final ClinicalContext clinicalContext;

  bool get isComplete => reason.trim().isNotEmpty && details.trim().isNotEmpty;

  List<SubmissionField> get missingSubmissionFields => [
    if (reason.trim().isEmpty) SubmissionField.reason,
    if (details.trim().isEmpty) SubmissionField.details,
    if (!clinicalContext.hasChosenModality) SubmissionField.modality,
  ];

  bool get readyForSubmission =>
      missingSubmissionFields.isEmpty && withinStorageLimits;

  bool get withinStorageLimits =>
      [
        reason,
        details,
        medicines,
        specialTreatments,
        previousProposals,
      ].every((value) => value.length <= FormLimits.text) &&
      clinicalContext.withinStorageLimits;
}
