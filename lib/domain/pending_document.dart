import 'dart:typed_data';

class PendingDocument {
  const PendingDocument({
    required this.title,
    required this.fileName,
    required this.bytes,
  });
  final String title;
  final String fileName;
  final Uint8List bytes;
}

enum DocumentSelectionIssue {
  invalidFile,
  limit,
  totalSize,
  title,
  unavailable,
}

class DocumentSelectionFailure implements Exception {
  const DocumentSelectionFailure(this.issue);
  final DocumentSelectionIssue issue;
}
