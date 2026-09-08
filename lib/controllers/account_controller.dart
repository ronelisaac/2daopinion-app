import 'package:flutter/foundation.dart';

import '../domain/account_draft.dart';
import '../domain/identity.dart';
import '../domain/input_validation.dart';
import '../domain/operation_result.dart';
import '../domain/repositories/account_repository.dart';

class AccountController extends ChangeNotifier {
  AccountController(this._repository, {this.requiredPolicyVersion});

  final String? requiredPolicyVersion;

  final AccountRepository _repository;
  bool _registering = false;
  bool _busy = false;
  bool _disposed = false;

  bool get registering => _registering;
  bool get busy => _busy;

  void setRegistering(bool value) {
    if (_busy || _registering == value) return;
    _registering = value;
    notifyListeners();
  }

  InputIssue? validateEmail(String? value) => InputValidation.email(value);
  InputIssue? validateName(String? value) => InputValidation.required(value);
  InputIssue? validatePassword(String? value) =>
      InputValidation.password(value, registering: _registering);
  InputIssue? validateConfirmation(String? value, String password) =>
      InputValidation.confirmation(value, password);

  Future<OperationResult> submit(AccountDraft account) async {
    if (_busy) throw StateError('An account operation is already running.');
    if (!account.isValid(registering: _registering)) {
      throw ArgumentError('Account fields are invalid.');
    }
    if (_registering &&
        requiredPolicyVersion != null &&
        account.acceptedPolicyVersion != requiredPolicyVersion) {
      throw const IdentityFailure(IdentityIssue.termsRequired);
    }
    _busy = true;
    notifyListeners();
    try {
      return await (_registering
          ? _repository.createAccount(account)
          : _repository.signIn(account));
    } finally {
      _busy = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
