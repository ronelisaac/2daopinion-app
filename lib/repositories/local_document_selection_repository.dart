import 'package:file_selector/file_selector.dart';
import '../domain/form_limits.dart';
import '../domain/attachment_policy.dart';
import '../domain/pending_document.dart';
import '../domain/repositories/document_selection_repository.dart';
import 'video_metadata.dart';

class LocalDocumentSelectionRepository implements DocumentSelectionRepository {
  LocalDocumentSelectionRepository({
    Future<List<XFile>> Function(bool video)? picker,
    Future<Duration> Function(String path)? videoDuration,
  }) : _picker = picker ?? _pick,
       _videoDuration = videoDuration ?? readVideoDuration;
  final Future<List<XFile>> Function(bool video) _picker;
  final Future<Duration> Function(String path) _videoDuration;
  static Future<List<XFile>> _pick(bool video) async {
    if (video) {
      final file = await openFile(
        acceptedTypeGroups: [
          const XTypeGroup(
            extensions: AttachmentPolicy.videoExtensions,
            uniformTypeIdentifiers: [
              'public.mpeg-4',
              'com.apple.quicktime-movie',
            ],
          ),
        ],
      );
      return file == null ? [] : [file];
    }
    return openFiles(
      acceptedTypeGroups: [
        const XTypeGroup(
          extensions: AttachmentPolicy.documentExtensions,
          uniformTypeIdentifiers: [
            'com.adobe.pdf',
            'public.jpeg',
            'public.png',
            'com.microsoft.word.doc',
            'com.microsoft.excel.xls',
          ],
        ),
      ],
    );
  }

  @override
  Future<List<PendingDocument>> select({
    required int maxFiles,
    required int maxTotalBytes,
    bool video = false,
  }) async {
    final files = await _picker(video);
    try {
      if (files.length > maxFiles) {
        throw const DocumentSelectionFailure(DocumentSelectionIssue.limit);
      }
      var total = 0;
      final sizes = <int>[];
      for (final file in files) {
        final size = await file.length();
        final extensions = video
            ? AttachmentPolicy.videoExtensions
            : AttachmentPolicy.documentExtensions;
        if (!extensions.contains(AttachmentPolicy.extension(file.name)) ||
            file.name.length > 255 ||
            size == 0 ||
            size > (video ? FormLimits.videoBytes : FormLimits.documentBytes)) {
          throw DocumentSelectionFailure(
            video
                ? DocumentSelectionIssue.videoInvalid
                : DocumentSelectionIssue.invalidFile,
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
        Duration? duration;
        if (video) {
          try {
            duration = await _videoDuration(file.path);
          } catch (_) {
            throw const DocumentSelectionFailure(
              DocumentSelectionIssue.videoInvalid,
            );
          }
          if (!AttachmentPolicy.valid(file.name, sizes[index], duration)) {
            throw const DocumentSelectionFailure(
              DocumentSelectionIssue.videoInvalid,
            );
          }
        }
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
            duration: duration,
          ),
        );
      }
      return selected;
    } finally {
      for (final file in files) {
        releaseLocalFile(file.path);
      }
    }
  }
}
