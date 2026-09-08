import 'package:flutter/foundation.dart';

class ConsultationStepsController extends ChangeNotifier {
  static const count = 4;
  int _index = 0;
  bool _disposed = false;
  int get index => _index;
  bool get isReview => _index == count - 1;

  void select(int index) {
    if (_disposed || index < 0 || index >= count || index == _index) return;
    _index = index;
    notifyListeners();
  }

  void next() => select(_index + 1);
  void previous() => select(_index - 1);

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
