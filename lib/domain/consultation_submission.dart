const submissionPolicyVersion = 'dev-submission-2026-09-08';

class ConsultationSubmission {
  const ConsultationSubmission({
    required this.id,
    required this.revision,
    required this.submittedAt,
  });
  final String id;
  final int revision;
  final DateTime submittedAt;
  String get reference => 'SO-$id';
}

enum SubmissionIssue {
  consent,
  unsaved,
  invalid,
  attachments,
  session,
  conflict,
  unavailable,
}

class SubmissionFailure implements Exception {
  const SubmissionFailure(this.issue);
  final SubmissionIssue issue;
}
