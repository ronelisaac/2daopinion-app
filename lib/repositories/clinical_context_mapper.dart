import '../domain/clinical_context.dart';
import '../domain/birth_date.dart';

class ClinicalContextMapper {
  static ClinicalContext decode(Map<String, dynamic>? data) {
    if (data == null) return const ClinicalContext();
    if (data['schemaVersion'] != 1) {
      throw const FormatException('Unsupported clinical context version.');
    }
    return ClinicalContext(
      birthDate: data['birthDate'] == null
          ? null
          : BirthDate(
              data['birthDate']['year'] as int,
              data['birthDate']['month'] as int,
              data['birthDate']['day'] as int,
            ),
      patientContext: data['patientContext'] as String,
      knownDiagnosis: data['knownDiagnosis'] as String,
      symptomEvolution: data['symptomEvolution'] as String,
      medicalHistory: data['medicalHistory'] as String,
      allergies: data['allergies'] as String,
      questions: data['questions'] as String,
      studySummary: data['studySummary'] as String,
      specialty: data['specialty'] as String,
      modality: data['modality'] as String,
    );
  }

  static Map<String, dynamic> encode(ClinicalContext value) => {
    'schemaVersion': 1,
    if (value.birthDate != null)
      'birthDate': {
        'year': value.birthDate!.year,
        'month': value.birthDate!.month,
        'day': value.birthDate!.day,
      },
    'patientContext': value.patientContext,
    'knownDiagnosis': value.knownDiagnosis,
    'symptomEvolution': value.symptomEvolution,
    'medicalHistory': value.medicalHistory,
    'allergies': value.allergies,
    'questions': value.questions,
    'studySummary': value.studySummary,
    'specialty': value.specialty,
    'modality': value.modality,
  };
}
