import 'package:flutter/widgets.dart';
import '../domain/saved_consultation_draft.dart';
import 'localization.dart';

String draftMessage(BuildContext context, DraftIssue issue) => switch (issue) {
  DraftIssue.session => strings(context).sessionExpired,
  DraftIssue.permission => strings(context).draftPermissionError,
  DraftIssue.conflict => strings(context).draftConflict,
  DraftIssue.consent => strings(context).draftConsentRequired,
  DraftIssue.invalid => strings(context).draftInvalid,
  DraftIssue.unavailable => strings(context).draftUnavailable,
};
