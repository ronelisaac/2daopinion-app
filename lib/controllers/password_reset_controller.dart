import 'package:flutter/foundation.dart';
import '../domain/input_validation.dart';
import '../domain/repositories/identity_repository.dart';

class PasswordResetController extends ChangeNotifier {
  PasswordResetController(this._repository);
  final IdentityRepository _repository;
  bool busy = false;
  bool sent = false;
  bool _disposed = false;

  Future<void> submit(String email) async {
    if (busy) return;
    if (InputValidation.email(email.trim()) != null) {
      throw ArgumentError('Invalid email');
    }
    busy = true;
    notifyListeners();
    try {
      await _repository.sendPasswordReset(email.trim());
      sent = true;
    } finally {
      busy = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
