enum VideoCaptureIssue {
  unsupported,
  permission,
  unavailable,
  invalid,
  interrupted,
}

class VideoCaptureFailure implements Exception {
  const VideoCaptureFailure(this.issue);
  final VideoCaptureIssue issue;
}
