import 'package:file_selector/file_selector.dart';
import '../domain/form_limits.dart';
import '../domain/pending_document.dart';
import '../domain/repositories/document_selection_repository.dart';

class LocalDocumentSelectionRepository implements DocumentSelectionRepository {
  @override
  Future<List<PendingDocument>> select({
    required int maxFiles,
    required int maxTotalBytes,
  }) async {
    final files = await openFiles(
      acceptedTypeGroups: [
        const XTypeGroup(
          extensions: ['pdf', 'jpg', 'jpeg', 'png'],
          uniformTypeIdentifiers: [
            'com.adobe.pdf',
            'public.jpeg',
            'public.png',
          ],
        ),
      ],
    );
    if (files.length > maxFiles) {
      throw const DocumentSelectionFailure(DocumentSelectionIssue.limit);
    }
    var total = 0;
    final sizes = <int>[];
    for (final file in files) {
      final size = await file.length();
      final extension = file.name.split('.').last.toLowerCase();
      if (!['pdf', 'jpg', 'jpeg', 'png'].contains(extension) ||
          size == 0 ||
          size > FormLimits.documentBytes) {
        throw const DocumentSelectionFailure(
          DocumentSelectionIssue.invalidFile,
        );
      }
      sizes.add(size);
      total += size;
    }
    if (total > maxTotalBytes) {
      throw const DocumentSelectionFailure(DocumentSelectionIssue.totalSize);
    }
    final selected = <PendingDocument>[];
    for (var index = 0; index < files.length; index++) {
      final file = files[index];
      final bytes = await file.readAsBytes();
      if (bytes.length != sizes[index]) {
        throw const DocumentSelectionFailure(
          DocumentSelectionIssue.invalidFile,
        );
      }
      final title = StringBuffer();
      for (final rune in file.name.runes) {
        final character = String.fromCharCode(rune);
        if (title.length + character.length > FormLimits.documentTitle) break;
        title.write(character);
      }
      selected.add(
        PendingDocument(
          title: title.toString(),
          fileName: file.name,
          bytes: bytes,
        ),
      );
    }
    return selected;
  }
}
