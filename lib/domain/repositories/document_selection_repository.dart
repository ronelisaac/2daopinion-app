import '../pending_document.dart';

abstract interface class DocumentSelectionRepository {
  Future<List<PendingDocument>> select({
    required int maxFiles,
    required int maxTotalBytes,
  });
}
