const developmentPolicyVersion = 'dev-access-2026-09-08';

class IdentityUser {
  const IdentityUser({
    required this.authUserId,
    required this.email,
    required this.emailVerified,
  });
  final String authUserId;
  final String email;
  final bool emailVerified;
}

class PatientProfile {
  const PatientProfile({
    required this.id,
    required this.authUserId,
    required this.firstName,
    required this.lastName,
    required this.countryCode,
    required this.locale,
    required this.policyVersion,
  });
  final String id;
  final String authUserId;
  final String firstName;
  final String lastName;
  final String countryCode;
  final String locale;
  final String policyVersion;
}

enum IdentityIssue {
  credentials,
  network,
  throttled,
  unavailable,
  permission,
  termsRequired,
  profilePending,
  sessionExpired,
  unknown,
}

class IdentityFailure implements Exception {
  const IdentityFailure(this.issue);
  final IdentityIssue issue;
}
