import 'package:flutter/foundation.dart';
import '../domain/form_limits.dart';
import '../domain/attachment_policy.dart';
import '../domain/pending_document.dart';
import '../domain/repositories/document_selection_repository.dart';

class DocumentSelectionController extends ChangeNotifier {
  DocumentSelectionController(this._repository);
  final DocumentSelectionRepository _repository;
  final List<PendingDocument> _documents = [];
  List<PendingDocument> get documents => List.unmodifiable(_documents);
  List<PendingDocument> get studies =>
      documents.where((item) => !item.isVideo).toList();
  List<PendingDocument> get videos =>
      documents.where((item) => item.isVideo).toList();
  bool busy = false;
  bool _disposed = false;
  int _generation = 0;
  DocumentSelectionIssue? issue;
  int get totalBytes =>
      _documents.fold(0, (total, document) => total + document.bytes.length);
  Future<bool> select({bool video = false}) async {
    if (busy || _disposed) return false;
    issue = video
        ? (videos.isNotEmpty ? DocumentSelectionIssue.videoLimit : null)
        : (studies.length >= FormLimits.documents
              ? DocumentSelectionIssue.limit
              : null);
    if (issue != null) {
      notifyListeners();
      return false;
    }
    final generation = _generation;
    busy = true;
    notifyListeners();
    try {
      final selected = await _repository.select(
        maxFiles: video ? 1 : FormLimits.documents - studies.length,
        maxTotalBytes: FormLimits.totalDocumentBytes - totalBytes,
        video: video,
      );
      if (_disposed || generation != _generation || selected.isEmpty) {
        return false;
      }
      if (selected.any(
        (document) =>
            document.isVideo != video ||
            !AttachmentPolicy.valid(
              document.fileName,
              document.bytes.length,
              document.duration,
            ),
      )) {
        issue = video
            ? DocumentSelectionIssue.videoInvalid
            : DocumentSelectionIssue.invalidFile;
        return false;
      }
      if (video
          ? videos.length + selected.length > 1
          : studies.length + selected.length > FormLimits.documents) {
        issue = video
            ? DocumentSelectionIssue.videoLimit
            : DocumentSelectionIssue.limit;
        return false;
      }
      if (totalBytes +
              selected.fold<int>(
                0,
                (total, document) => total + document.bytes.length,
              ) >
          FormLimits.totalDocumentBytes) {
        issue = DocumentSelectionIssue.totalSize;
        return false;
      }
      if (selected.any(
        (document) =>
            document.title.trim().isEmpty ||
            document.title.length > FormLimits.documentTitle,
      )) {
        issue = DocumentSelectionIssue.title;
        return false;
      }
      _documents.addAll(selected);
      return true;
    } catch (error) {
      if (!_disposed && generation == _generation) {
        issue = error is DocumentSelectionFailure
            ? error.issue
            : DocumentSelectionIssue.unavailable;
      }
      return false;
    } finally {
      if (!_disposed && generation == _generation) {
        busy = false;
        notifyListeners();
      }
    }
  }

  void remove(int index) {
    if (_disposed || busy || index < 0 || index >= _documents.length) return;
    _documents.removeAt(index);
    issue = null;
    notifyListeners();
  }

  void clear({bool notify = true}) {
    _generation++;
    _documents.clear();
    busy = false;
    issue = null;
    if (!_disposed && notify) notifyListeners();
  }

  bool rename(PendingDocument document, String title) {
    if (_disposed || busy) return false;
    final index = _documents.indexOf(document);
    if (index < 0) return false;
    if (title.trim().isEmpty || title.length > FormLimits.documentTitle) {
      issue = DocumentSelectionIssue.title;
      notifyListeners();
      return false;
    }
    _documents[index] = PendingDocument(
      title: title.trim(),
      fileName: document.fileName,
      bytes: document.bytes,
      duration: document.duration,
    );
    issue = null;
    notifyListeners();
    return true;
  }

  @override
  void dispose() {
    _disposed = true;
    clear();
    super.dispose();
  }
}
