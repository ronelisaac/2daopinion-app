import 'dart:async';
import 'package:flutter/foundation.dart';

import '../domain/identity.dart';
import '../domain/repositories/identity_repository.dart';

enum SessionStatus { loading, signedOut, incomplete, unverified, ready, failed }

class SessionController extends ChangeNotifier {
  SessionController(
    this._repository, {
    required Future<void> Function() initialize,
  }) : _initialize = initialize;
  final IdentityRepository _repository;
  final Future<void> Function() _initialize;
  StreamSubscription<IdentityUser?>? _subscription;
  SessionStatus status = SessionStatus.loading;
  IdentityUser? user;
  PatientProfile? profile;
  bool busy = false;
  bool _disposed = false;
  int _generation = 0;
  int navigationEpoch = 0;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> start() async {
    status = SessionStatus.loading;
    _notify();
    try {
      await _initialize();
      if (_disposed) return;
      await _subscription?.cancel();
      if (_disposed) return;
      _subscription = _repository.watchIdentity().listen(
        _load,
        onError: (_) {
          _generation++;
          profile = null;
          status = SessionStatus.failed;
          _notify();
        },
      );
    } catch (_) {
      status = SessionStatus.failed;
      _notify();
    }
  }

  Future<void> _load(IdentityUser? identity) async {
    if (_disposed) return;
    final generation = ++_generation;
    if (user != null && user!.authUserId != identity?.authUserId) {
      navigationEpoch++;
    }
    user = identity;
    profile = null;
    status = identity == null ? SessionStatus.signedOut : SessionStatus.loading;
    _notify();
    if (identity == null) return;
    try {
      final loaded = await _repository.loadProfile(identity.authUserId);
      if (_disposed || generation != _generation) return;
      profile = loaded;
      status =
          loaded == null || loaded.policyVersion != developmentPolicyVersion
          ? SessionStatus.incomplete
          : identity.emailVerified
          ? SessionStatus.ready
          : SessionStatus.unverified;
    } catch (_) {
      if (_disposed || generation != _generation) return;
      status = SessionStatus.failed;
    }
    _notify();
  }

  Future<void> refresh() async {
    if (_disposed) return;
    final generation = _generation;
    status = SessionStatus.loading;
    _notify();
    try {
      final identity = await _repository.refreshIdentity();
      if (_disposed || generation != _generation) return;
      await _load(identity);
    } catch (_) {
      if (!_disposed && generation == _generation) {
        profile = null;
        status = SessionStatus.failed;
        _notify();
      }
      rethrow;
    }
  }

  Future<void> _run(Future<void> Function() operation) async {
    if (busy) return;
    busy = true;
    _notify();
    try {
      await operation();
    } finally {
      busy = false;
      _notify();
    }
  }

  Future<void> signOut() => _run(() async {
    await _repository.signOut();
    await _load(null);
  });
  Future<void> sendVerification() => _run(_repository.sendVerification);
  Future<void> checkVerification() => _run(refresh);

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    _subscription?.cancel();
    super.dispose();
  }
}
