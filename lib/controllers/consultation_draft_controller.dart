import 'package:flutter/foundation.dart';
import '../domain/consultation_draft.dart';
import '../domain/country_config.dart';
import '../domain/saved_consultation_draft.dart';
import '../domain/repositories/consultation_draft_repository.dart';

class ConsultationDraftController extends ChangeNotifier {
  ConsultationDraftController(this._repository, {required this.country});
  final ConsultationDraftRepository _repository;
  final CountryConfig country;
  SavedConsultationDraft? saved;
  bool loaded = false;
  bool busy = false;
  bool _disposed = false;
  DraftIssue? issue;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<bool> load() async {
    if (busy || _disposed) return false;
    busy = true;
    issue = null;
    _notify();
    try {
      final result = await _repository.load();
      if (_disposed) return false;
      saved = result;
      loaded = true;
      return true;
    } catch (error) {
      issue = error is DraftFailure ? error.issue : DraftIssue.unavailable;
      return false;
    } finally {
      busy = false;
      _notify();
    }
  }

  Future<bool> save(ConsultationDraft content, {required bool accepted}) async {
    if (busy || _disposed || !loaded) return false;
    issue = null;
    if (content.countryCode != country.code || !content.withinStorageLimits) {
      issue = DraftIssue.invalid;
    } else if (saved == null && !accepted) {
      issue = DraftIssue.consent;
    }
    if (issue != null) {
      _notify();
      return false;
    }
    busy = true;
    _notify();
    try {
      final result = await _repository.save(
        content,
        expectedRevision: saved?.revision ?? 0,
        acceptStorageTerms: accepted,
      );
      if (_disposed) return false;
      saved = result;
      return true;
    } catch (error) {
      issue = error is DraftFailure ? error.issue : DraftIssue.unavailable;
      return false;
    } finally {
      busy = false;
      _notify();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
