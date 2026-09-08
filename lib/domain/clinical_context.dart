class ClinicalContext {
  const ClinicalContext({
    this.patientContext = '',
    this.knownDiagnosis = '',
    this.symptomEvolution = '',
    this.medicalHistory = '',
    this.allergies = '',
    this.questions = '',
    this.studySummary = '',
    this.specialty = '',
    this.modality = '',
  });
  final String patientContext;
  final String knownDiagnosis;
  final String symptomEvolution;
  final String medicalHistory;
  final String allergies;
  final String questions;
  final String studySummary;
  final String specialty;
  final String modality;

  bool get withinStorageLimits =>
      [
        patientContext,
        knownDiagnosis,
        symptomEvolution,
        medicalHistory,
        allergies,
        questions,
        studySummary,
        specialty,
      ].every((value) => value.length <= 4000) &&
      ['', 'document_review', 'review_and_consultation'].contains(modality);
}
