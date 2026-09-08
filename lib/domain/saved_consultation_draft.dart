import 'consultation_draft.dart';

const draftStoragePolicyVersion = 'dev-draft-storage-2026-09-08';

class SavedConsultationDraft {
  const SavedConsultationDraft({
    required this.id,
    required this.revision,
    required this.content,
    required this.updatedAt,
  });
  final String id;
  final int revision;
  final ConsultationDraft content;
  final DateTime updatedAt;
}

enum DraftIssue { session, unavailable, permission, conflict, consent, invalid }

class DraftFailure implements Exception {
  const DraftFailure(this.issue);
  final DraftIssue issue;
}
