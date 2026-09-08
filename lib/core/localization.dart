import 'package:flutter/material.dart';

import '../domain/input_validation.dart';
import '../l10n/app_localizations.dart';

AppLocalizations strings(BuildContext context) => AppLocalizations.of(context)!;

String? inputError(BuildContext context, InputIssue? issue) => switch (issue) {
  null => null,
  InputIssue.required => strings(context).requiredField,
  InputIssue.invalidEmail => strings(context).invalidEmail,
  InputIssue.shortPassword => strings(context).shortPassword,
  InputIssue.passwordMismatch => strings(context).passwordMismatch,
};
