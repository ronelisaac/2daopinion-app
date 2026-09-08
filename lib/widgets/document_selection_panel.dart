import 'package:flutter/material.dart';
import '../controllers/document_selection_controller.dart';
import '../core/localization.dart';
import '../domain/pending_document.dart';
import 'document_title_dialog.dart';
import 'optional_video_panel.dart';

class DocumentSelectionPanel extends StatelessWidget {
  const DocumentSelectionPanel({
    super.key,
    required this.controller,
    this.readOnly = false,
    this.localUploadsEnabled = false,
  });
  final DocumentSelectionController controller;
  final bool readOnly;
  final bool localUploadsEnabled;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final text = strings(context);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            text.studySummary,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(text.multipleDocumentsHint),
          const SizedBox(height: 12),
          Text(
            text.documentsSelected(controller.studies.length),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          if (!readOnly)
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              onPressed: controller.busy ? null : controller.select,
              icon: const Icon(Icons.library_add_outlined),
              label: Text(
                controller.studies.isEmpty
                    ? text.selectDocument
                    : text.addMoreDocuments,
              ),
            ),
          const SizedBox(height: 12),
          for (final document in controller.studies)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      document.title,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(document.fileName),
                    Text(
                      '${(document.bytes.length / 1024).ceil()} KB · ${text.pendingUpload}',
                    ),
                    if (!readOnly)
                      Wrap(
                        spacing: 8,
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.edit_outlined),
                            label: Text(text.editDocumentTitle),
                            onPressed: controller.busy
                                ? null
                                : () async {
                                    final title = await showDialog<String>(
                                      context: context,
                                      builder: (_) => DocumentTitleDialog(
                                        title: document.title,
                                      ),
                                    );
                                    if (title != null && context.mounted) {
                                      controller.rename(document, title);
                                    }
                                  },
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.delete_outline),
                            label: Text(text.removeItem),
                            onPressed: controller.busy
                                ? null
                                : () => controller.remove(
                                    controller.documents.indexOf(document),
                                  ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          OptionalVideoPanel(controller: controller, readOnly: readOnly),
          if (controller.busy) const LinearProgressIndicator(),
          if (controller.issue != null)
            Text(switch (controller.issue!) {
              DocumentSelectionIssue.title => text.documentTitleRequired,
              DocumentSelectionIssue.limit => text.documentCountLimit,
              DocumentSelectionIssue.totalSize => text.documentTotalLimit,
              DocumentSelectionIssue.invalidFile => text.documentFileLimit,
              DocumentSelectionIssue.videoInvalid => text.videoInvalid,
              DocumentSelectionIssue.videoLimit => text.videoLimit,
              DocumentSelectionIssue.unavailable =>
                text.documentSelectionFailed,
            }, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          const SizedBox(height: 12),
          Text(
            localUploadsEnabled
                ? text.pendingEmulatorDocumentsNotice
                : text.pendingDocumentsNotice,
          ),
          const SizedBox(height: 24),
        ],
      );
    },
  );
}
