import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/account_draft.dart';
import '../domain/country_config.dart';
import '../domain/identity.dart';
import '../domain/operation_result.dart';
import '../domain/repositories/account_repository.dart';
import '../domain/repositories/identity_repository.dart';

class FirebaseIdentityRepository
    implements IdentityRepository, AccountRepository {
  FirebaseIdentityRepository({
    required FirebaseAuth Function() auth,
    required FirebaseFirestore Function() database,
    required CountryConfig country,
    required String locale,
  }) : _authProvider = auth,
       _databaseProvider = database,
       _country = country,
       _locale = locale;

  final FirebaseAuth Function() _authProvider;
  final FirebaseFirestore Function() _databaseProvider;
  final CountryConfig _country;
  final String _locale;
  FirebaseAuth get _auth => _authProvider();
  FirebaseFirestore get _database => _databaseProvider();

  IdentityUser? _identity(User? user) => user == null
      ? null
      : IdentityUser(
          authUserId: user.uid,
          email: user.email ?? '',
          emailVerified: user.emailVerified,
        );

  static IdentityFailure failureForCode(String code) =>
      IdentityFailure(switch (code) {
        'invalid-credential' ||
        'wrong-password' ||
        'user-not-found' ||
        'invalid-email' ||
        'email-already-in-use' ||
        'weak-password' => IdentityIssue.credentials,
        'network-request-failed' ||
        'unavailable' ||
        'deadline-exceeded' => IdentityIssue.network,
        'too-many-requests' || 'resource-exhausted' => IdentityIssue.throttled,
        'operation-not-allowed' ||
        'configuration-not-found' => IdentityIssue.unavailable,
        'permission-denied' => IdentityIssue.permission,
        'user-disabled' ||
        'user-token-expired' ||
        'invalid-user-token' ||
        'requires-recent-login' ||
        'unauthenticated' => IdentityIssue.sessionExpired,
        _ => IdentityIssue.unknown,
      });

  Future<Result> _guard<Result>(Future<Result> Function() operation) async {
    try {
      return await operation();
    } on FirebaseException catch (error) {
      throw failureForCode(error.code);
    }
  }

  @override
  Stream<IdentityUser?> watchIdentity() => _auth.userChanges().map(_identity);

  @override
  Future<IdentityUser?> refreshIdentity() => _guard(() async {
    try {
      await _auth.currentUser?.reload();
      await _auth.currentUser?.getIdToken(true);
      return _identity(_auth.currentUser);
    } on FirebaseAuthException catch (error) {
      if ([
        'user-disabled',
        'user-not-found',
        'user-token-expired',
        'invalid-user-token',
      ].contains(error.code)) {
        await _auth.signOut();
      }
      rethrow;
    }
  });

  @override
  Future<OperationResult> signIn(AccountDraft account) => _guard(() async {
    await _auth.signInWithEmailAndPassword(
      email: account.email.trim(),
      password: account.password,
    );
    return OperationResult.completed;
  });

  @override
  Future<OperationResult> createAccount(AccountDraft account) async {
    if (account.acceptedPolicyVersion != developmentPolicyVersion) {
      throw const IdentityFailure(IdentityIssue.termsRequired);
    }
    await _guard(
      () => _auth.createUserWithEmailAndPassword(
        email: account.email.trim(),
        password: account.password,
      ),
    );
    try {
      await saveProfile(
        firstName: account.firstName,
        lastName: account.lastName,
        acceptDevelopmentTerms: true,
      );
    } catch (_) {
      throw const IdentityFailure(IdentityIssue.profilePending);
    }
    return OperationResult.completed;
  }

  @override
  Future<PatientProfile?> loadProfile(String authUserId) => _guard(() async {
    final snapshot = await _database
        .collection('profiles')
        .doc(authUserId)
        .get(const GetOptions(source: Source.server));
    final data = snapshot.data();
    if (data == null) return null;
    return PatientProfile(
      id: data['id'] as String,
      authUserId: data['authUserId'] as String,
      firstName: data['firstName'] as String,
      lastName: data['lastName'] as String,
      countryCode: data['countryCode'] as String,
      locale: data['locale'] as String,
      policyVersion: data['policyVersion'] as String,
    );
  });

  @override
  Future<void> saveProfile({
    required String firstName,
    required String lastName,
    required bool acceptDevelopmentTerms,
  }) => _guard(() async {
    final user = _auth.currentUser;
    if (user == null) throw const IdentityFailure(IdentityIssue.sessionExpired);
    final reference = _database.collection('profiles').doc(user.uid);
    final profileId = _database.collection('profiles').doc().id;
    await _database.runTransaction((transaction) async {
      final snapshot = await transaction.get(reference);
      if (snapshot.exists) {
        transaction.update(reference, {
          'firstName': firstName.trim(),
          'lastName': lastName.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        if (!acceptDevelopmentTerms) {
          throw const IdentityFailure(IdentityIssue.termsRequired);
        }
        transaction.set(reference, {
          'id': profileId,
          'authUserId': user.uid,
          'firstName': firstName.trim(),
          'lastName': lastName.trim(),
          'countryCode': _country.code,
          'locale': _locale,
          'policyVersion': developmentPolicyVersion,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        transaction.set(
          reference.collection('consents').doc(developmentPolicyVersion),
          {
            'authUserId': user.uid,
            'policyVersion': developmentPolicyVersion,
            'context': 'development-registration',
            'accepted': true,
            'acceptedAt': FieldValue.serverTimestamp(),
          },
        );
      }
    });
  });

  @override
  Future<void> sendVerification() => _guard(() async {
    final user = _auth.currentUser;
    if (user == null) throw const IdentityFailure(IdentityIssue.sessionExpired);
    await _auth.setLanguageCode(_locale);
    if (!user.emailVerified) await user.sendEmailVerification();
  });

  @override
  Future<void> sendPasswordReset(String email) => _guard(() async {
    await _auth.setLanguageCode(_locale);
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (error) {
      if (error.code != 'user-not-found') rethrow;
    }
  });

  @override
  Future<void> signOut() => _guard(() => _auth.signOut());
}
