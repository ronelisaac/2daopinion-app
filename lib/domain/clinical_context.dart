import 'birth_date.dart';
import 'form_limits.dart';

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
    this.birthDate,
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
  final BirthDate? birthDate;

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
      ].every((value) => value.length <= FormLimits.text) &&
      (birthDate == null || birthDate!.validAt(DateTime.now().toUtc())) &&
      ['', 'document_review', 'review_and_consultation'].contains(modality);
}
