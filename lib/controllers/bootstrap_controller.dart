import 'package:flutter/foundation.dart';

enum BootstrapStatus { idle, loading, ready, failed }

class BootstrapController extends ChangeNotifier {
  BootstrapController(this._initialize);

  final Future<void> Function() _initialize;
  BootstrapStatus _status = BootstrapStatus.idle;
  bool _disposed = false;

  BootstrapStatus get status => _status;

  Future<void> start() async {
    if (_status == BootstrapStatus.loading) return;
    _status = BootstrapStatus.loading;
    notifyListeners();
    try {
      await _initialize();
      _status = BootstrapStatus.ready;
    } catch (_) {
      _status = BootstrapStatus.failed;
    }
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
