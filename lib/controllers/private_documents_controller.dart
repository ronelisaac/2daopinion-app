import 'package:flutter/foundation.dart';
import '../domain/private_document.dart';
import '../domain/pending_document.dart';

class PrivateDocumentsController extends ChangeNotifier {
  PrivateDocumentsController(this._repository);
  final PrivateDocumentRepository _repository;
  List<PrivateDocument> documents = [];
  String? draftId;
  bool busy = false;
  bool _disposed = false;
  DocumentIssue? issue;
  double progress = 0;
  TransferCancellation? _cancellation;
  bool get transferring => _cancellation != null;
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> load(String id) async {
    if (busy || _disposed) return;
    draftId = id;
    busy = true;
    issue = null;
    _notify();
    try {
      final result = await _repository.list(id);
      if (!_disposed) documents = result;
    } catch (error) {
      issue = error is DocumentFailure
          ? error.issue
          : DocumentIssue.unavailable;
    } finally {
      busy = false;
      _notify();
    }
  }

  Future<void> upload(
    List<PendingDocument> pending, {
    required bool accepted,
    required void Function(PendingDocument) onUploaded,
  }) async {
    if (busy || _disposed || draftId == null || pending.isEmpty) return;
    if (!accepted) {
      issue = DocumentIssue.permission;
      _notify();
      return;
    }
    final cancellation = TransferCancellation();
    _cancellation = cancellation;
    busy = true;
    issue = null;
    progress = 0;
    _notify();
    try {
      for (var index = 0; index < pending.length; index++) {
        cancellation.check();
        final result = await _repository.upload(
          draftId!,
          pending[index],
          accepted: accepted,
          cancellation: cancellation,
          onProgress: (value) {
            if (_disposed) return;
            progress = (index + value.clamp(0, 1)) / pending.length;
            _notify();
          },
        );
        if (_disposed) return;
        documents = [
          ...documents.where((document) => document.id != result.id),
          result,
        ];
        onUploaded(pending[index]);
      }
      progress = 1;
    } catch (error) {
      issue = error is DocumentFailure
          ? error.issue
          : DocumentIssue.unavailable;
    } finally {
      _cancellation = null;
      busy = false;
      _notify();
    }
  }

  void cancel() => _cancellation?.cancel();
  Future<void> delete(PrivateDocument document) async {
    if (busy || _disposed || draftId == null) return;
    busy = true;
    issue = null;
    _notify();
    try {
      await _repository.delete(draftId!, document.id);
      final result = await _repository.list(draftId!);
      if (!_disposed) documents = result;
    } catch (error) {
      issue = error is DocumentFailure
          ? error.issue
          : DocumentIssue.unavailable;
    } finally {
      busy = false;
      _notify();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    cancel();
    documents = [];
    super.dispose();
  }
}
