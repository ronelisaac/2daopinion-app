import 'package:flutter/widgets.dart';
import '../domain/identity.dart';
import 'localization.dart';

String identityMessage(BuildContext context, Object error) {
  final text = strings(context);
  return switch (error is IdentityFailure
      ? error.issue
      : IdentityIssue.unknown) {
    IdentityIssue.credentials => text.credentialsError,
    IdentityIssue.network => text.networkError,
    IdentityIssue.throttled => text.throttledError,
    IdentityIssue.unavailable => text.identityUnavailable,
    IdentityIssue.permission => text.profileAccessError,
    IdentityIssue.termsRequired => text.termsRequired,
    IdentityIssue.profilePending => text.profilePending,
    IdentityIssue.sessionExpired => text.sessionExpired,
    IdentityIssue.cancelled => text.googleCancelled,
    IdentityIssue.popupBlocked => text.googlePopupBlocked,
    IdentityIssue.accountConflict => text.googleAccountConflict,
    IdentityIssue.googleUnavailable => text.googleSetupPending,
    IdentityIssue.unknown => text.actionFailed,
  };
}
