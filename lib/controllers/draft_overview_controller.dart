import 'package:flutter/foundation.dart';
import '../domain/draft_overview.dart';
import '../domain/repositories/consultation_draft_repository.dart';

enum DraftOverviewStatus { loading, empty, ready, failed }

class DraftOverviewController extends ChangeNotifier {
  DraftOverviewController(this._repository);
  final ConsultationDraftRepository _repository;
  DraftOverviewStatus status = DraftOverviewStatus.loading;
  DraftOverview? overview;
  int _generation = 0;
  bool _disposed = false;

  Future<void> load() async {
    if (_disposed) return;
    final generation = ++_generation;
    overview = null;
    status = DraftOverviewStatus.loading;
    notifyListeners();
    try {
      final record = await _repository.load();
      if (_disposed || generation != _generation) return;
      overview = record == null
          ? null
          : DraftOverview(
              updatedAt: record.updatedAt,
              hasRequiredDetails: record.content.isComplete,
            );
      status = record == null
          ? DraftOverviewStatus.empty
          : DraftOverviewStatus.ready;
    } catch (_) {
      if (_disposed || generation != _generation) return;
      status = DraftOverviewStatus.failed;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    super.dispose();
  }
}
