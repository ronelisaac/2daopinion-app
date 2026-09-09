import '../consultation_submission.dart';
import '../saved_consultation_draft.dart';

abstract interface class ConsultationSubmissionRepository {
  Future<ConsultationSubmission?> load();
  Future<ConsultationSubmission> submit(
    SavedConsultationDraft draft, {
    required bool accepted,
  });
}
