import '../consultation_draft.dart';
import '../saved_consultation_draft.dart';

abstract interface class ConsultationDraftRepository {
  Future<SavedConsultationDraft?> load();
  Future<SavedConsultationDraft> save(
    ConsultationDraft content, {
    required int expectedRevision,
    required bool acceptStorageTerms,
  });
}
