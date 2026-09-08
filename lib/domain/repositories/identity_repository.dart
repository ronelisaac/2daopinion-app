import '../identity.dart';

abstract interface class IdentityRepository {
  Stream<IdentityUser?> watchIdentity();
  Future<IdentityUser?> refreshIdentity();
  Future<PatientProfile?> loadProfile(String authUserId);
  Future<void> saveProfile({
    required String firstName,
    required String lastName,
    required bool acceptDevelopmentTerms,
  });
  Future<void> sendVerification();
  Future<void> sendPasswordReset(String email);
  Future<void> signOut();
}
