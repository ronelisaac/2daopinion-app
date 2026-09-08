import 'dart:typed_data';
import 'pending_document.dart';

enum PrivateDocumentState { stored, missing }

enum DocumentIssue {
  session,
  permission,
  invalid,
  quota,
  cancelled,
  unavailable,
}

class DocumentFailure implements Exception {
  const DocumentFailure(this.issue);
  final DocumentIssue issue;
}

class TransferCancellation {
  bool cancelled = false;
  void Function()? _handler;
  void bind(void Function()? handler) {
    _handler = handler;
    if (cancelled) handler?.call();
  }

  void cancel() {
    cancelled = true;
    _handler?.call();
  }

  void check() {
    if (cancelled) throw const DocumentFailure(DocumentIssue.cancelled);
  }
}

class PrivateDocument {
  const PrivateDocument({
    required this.id,
    required this.draftId,
    required this.title,
    required this.fileName,
    required this.size,
    required this.state,
  });
  final String id;
  final String draftId;
  final String title;
  final String fileName;
  final int size;
  final PrivateDocumentState state;
}

abstract interface class PrivateDocumentRepository {
  Future<List<PrivateDocument>> list(String draftId);
  Future<PrivateDocument> upload(
    String draftId,
    PendingDocument document, {
    required bool accepted,
    required TransferCancellation cancellation,
    required void Function(double) onProgress,
  });
  Future<Uint8List> read(String draftId, String documentId);
  Future<void> delete(String draftId, String documentId);
}
