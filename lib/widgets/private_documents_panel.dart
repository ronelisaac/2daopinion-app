import 'package:flutter/material.dart';
import '../controllers/private_documents_controller.dart';
import '../controllers/document_selection_controller.dart';
import '../domain/private_document.dart';
import '../core/localization.dart';

class PrivateDocumentsPanel extends StatefulWidget {
  const PrivateDocumentsPanel({
    super.key,
    required this.controller,
    required this.selection,
  });
  final PrivateDocumentsController controller;
  final DocumentSelectionController selection;
  @override
  State<PrivateDocumentsPanel> createState() => _PrivateDocumentsPanelState();
}

class _PrivateDocumentsPanelState extends State<PrivateDocumentsPanel> {
  bool _accepted = false;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([widget.controller, widget.selection]),
    builder: (context, _) {
      final controller = widget.controller;
      final text = strings(context);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            text.privateDocumentsTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(text.localUploadNotice),
          if (controller.draftId == null)
            Text(text.saveBeforeUpload)
          else ...[
            CheckboxListTile(
              value: _accepted,
              onChanged: controller.busy
                  ? null
                  : (value) => setState(() => _accepted = value ?? false),
              title: Text(text.fileConsent),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            FilledButton.icon(
              onPressed:
                  controller.busy ||
                      widget.selection.busy ||
                      widget.selection.documents.isEmpty ||
                      !_accepted
                  ? null
                  : () => controller.upload(
                      widget.selection.documents,
                      accepted: _accepted,
                      onUploaded: (document) => widget.selection.remove(
                        widget.selection.documents.indexOf(document),
                      ),
                    ),
              icon: const Icon(Icons.cloud_upload_outlined),
              label: Text(text.uploadPrivateFiles),
            ),
            if (controller.busy)
              LinearProgressIndicator(
                value: controller.transferring ? controller.progress : null,
              ),
            if (controller.transferring)
              TextButton(
                onPressed: controller.cancel,
                child: Text(text.cancelTransfer),
              ),
            TextButton(
              onPressed: controller.busy
                  ? null
                  : () => controller.load(controller.draftId!),
              child: Text(text.reloadPrivateFiles),
            ),
            for (final document in controller.documents)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(document.title),
                      Text(
                        document.state == PrivateDocumentState.stored
                            ? text.privateFileStored
                            : text.privateFileMissing,
                      ),
                      if (document.state == PrivateDocumentState.stored)
                        TextButton(
                          onPressed: controller.busy
                              ? null
                              : () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(text.deletePrivateFile),
                                      content: Text(
                                        text.deletePrivateFileNotice,
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: Text(
                                            MaterialLocalizations.of(
                                              context,
                                            ).cancelButtonLabel,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: Text(text.deletePrivateFile),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirmed == true && context.mounted) {
                                    await controller.delete(document);
                                  }
                                },
                          child: Text(text.deletePrivateFile),
                        ),
                    ],
                  ),
                ),
              ),
          ],
          if (controller.issue != null)
            Text(switch (controller.issue!) {
              DocumentIssue.cancelled => text.transferCancelled,
              DocumentIssue.quota => text.privateQuotaReached,
              DocumentIssue.session => text.fileSessionRequired,
              DocumentIssue.permission => text.filePermissionDenied,
              DocumentIssue.invalid => text.fileInvalid,
              DocumentIssue.unavailable => text.fileServiceUnavailable,
            }, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          const SizedBox(height: 24),
        ],
      );
    },
  );
}
