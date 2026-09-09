import 'package:flutter/foundation.dart';
import '../domain/consultation_submission.dart';
import '../domain/saved_consultation_draft.dart';
import '../domain/repositories/consultation_submission_repository.dart';

class ConsultationSubmissionController extends ChangeNotifier {
  ConsultationSubmissionController(this._repository);
  final ConsultationSubmissionRepository _repository;
  ConsultationSubmission? receipt;
  SubmissionIssue? issue;
  bool loaded = false;
  bool busy = false;
  bool _disposed = false;

  Future<void> load() async {
    if (busy || _disposed) return;
    loaded = false;
    receipt = null;
    busy = true;
    issue = null;
    notifyListeners();
    try {
      final result = await _repository.load();
      if (!_disposed) {
        receipt = result;
        loaded = true;
      }
    } catch (error) {
      if (!_disposed) {
        issue = error is SubmissionFailure
            ? error.issue
            : SubmissionIssue.unavailable;
      }
    } finally {
      busy = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<void> submit(
    SavedConsultationDraft? draft, {
    required bool accepted,
    required bool dirty,
    required bool hasAttachments,
  }) async {
    if (busy || _disposed || !loaded || receipt != null) return;
    issue = !accepted
        ? SubmissionIssue.consent
        : draft == null || dirty
        ? SubmissionIssue.unsaved
        : hasAttachments
        ? SubmissionIssue.attachments
        : !draft.content.readyForSubmission
        ? SubmissionIssue.invalid
        : null;
    if (issue != null) {
      notifyListeners();
      return;
    }
    busy = true;
    notifyListeners();
    try {
      final result = await _repository.submit(draft!, accepted: accepted);
      if (!_disposed) receipt = result;
    } catch (error) {
      if (!_disposed) {
        issue = error is SubmissionFailure
            ? error.issue
            : SubmissionIssue.unavailable;
      }
    } finally {
      busy = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    receipt = null;
    super.dispose();
  }
}
