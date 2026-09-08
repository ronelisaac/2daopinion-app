class ConsultationDraft {
  const ConsultationDraft({
    required this.countryCode,
    required this.reason,
    required this.details,
    this.medicines = '',
    this.specialTreatments = '',
    this.previousProposals = '',
  });

  final String countryCode;
  final String reason;
  final String details;
  final String medicines;
  final String specialTreatments;
  final String previousProposals;

  bool get isComplete => reason.trim().isNotEmpty && details.trim().isNotEmpty;

  bool get withinStorageLimits => [
    reason,
    details,
    medicines,
    specialTreatments,
    previousProposals,
  ].every((value) => value.length <= 4000);
}
