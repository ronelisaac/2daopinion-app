import 'dart:async';
import 'package:segunda_opinion_app/domain/consultation_draft.dart';
import 'package:segunda_opinion_app/domain/saved_consultation_draft.dart';
import 'package:segunda_opinion_app/domain/repositories/consultation_draft_repository.dart';

class FakeDraftRepository implements ConsultationDraftRepository {
  SavedConsultationDraft? record;
  DraftIssue? failure;
  Completer<void>? pending;
  int saves = 0;
  int loads = 0;
  @override
  Future<SavedConsultationDraft?> load() async {
    loads++;
    if (failure != null) throw DraftFailure(failure!);
    return record;
  }

  @override
  Future<SavedConsultationDraft> save(
    ConsultationDraft content, {
    required int expectedRevision,
    required bool acceptStorageTerms,
  }) async {
    saves++;
    await pending?.future;
    if (failure != null) throw DraftFailure(failure!);
    if ((record?.revision ?? 0) != expectedRevision) {
      throw const DraftFailure(DraftIssue.conflict);
    }
    record = SavedConsultationDraft(
      id: 'DraftAbCdEfGhIjKl123',
      revision: expectedRevision + 1,
      content: content,
      updatedAt: DateTime.utc(2026, 9, 8),
    );
    return record!;
  }
}
