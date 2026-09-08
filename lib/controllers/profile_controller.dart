import 'package:flutter/foundation.dart';
import '../domain/identity.dart';
import '../domain/repositories/identity_repository.dart';

class ProfileController extends ChangeNotifier {
  ProfileController(this._repository);
  final IdentityRepository _repository;
  bool busy = false;
  bool _disposed = false;

  bool validName(String value) =>
      value.trim().isNotEmpty && value.trim().length <= 80;

  Future<void> save({
    required String firstName,
    required String lastName,
    required bool acceptTerms,
    required bool completing,
  }) async {
    if (busy) throw StateError('Profile operation in progress');
    if (!validName(firstName) || !validName(lastName)) {
      throw ArgumentError('Invalid profile');
    }
    if (completing && !acceptTerms) {
      throw const IdentityFailure(IdentityIssue.termsRequired);
    }
    busy = true;
    notifyListeners();
    try {
      await _repository.saveProfile(
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        acceptDevelopmentTerms: acceptTerms,
      );
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
