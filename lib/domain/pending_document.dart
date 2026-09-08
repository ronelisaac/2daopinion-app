import 'dart:typed_data';
import 'attachment_policy.dart';

class PendingDocument {
  const PendingDocument({
    required this.title,
    required this.fileName,
    required this.bytes,
    this.duration,
  });
  final String title;
  final String fileName;
  final Uint8List bytes;
  final Duration? duration;
  bool get isVideo => AttachmentPolicy.isVideo(fileName);
}

enum DocumentSelectionIssue {
  invalidFile,
  limit,
  totalSize,
  title,
  unavailable,
  videoInvalid,
  videoLimit,
}

class DocumentSelectionFailure implements Exception {
  const DocumentSelectionFailure(this.issue);
  final DocumentSelectionIssue issue;
}
