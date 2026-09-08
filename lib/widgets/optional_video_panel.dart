import 'package:flutter/material.dart';
import '../controllers/document_selection_controller.dart';
import '../core/localization.dart';
import '../domain/pending_document.dart';

class OptionalVideoPanel extends StatelessWidget {
  const OptionalVideoPanel({
    super.key,
    required this.controller,
    this.readOnly = false,
  });
  final DocumentSelectionController controller;
  final bool readOnly;
  @override
  Widget build(BuildContext context) {
    final text = strings(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          text.optionalVideoTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Text(text.optionalVideoHint),
        const SizedBox(height: 12),
        if (controller.videos.isEmpty)
          if (readOnly)
            Text(text.noOptionalVideo)
          else
            OutlinedButton.icon(
              onPressed: controller.busy
                  ? null
                  : () => controller.record(() async {
                      final result = await Navigator.pushNamed(
                        context,
                        '/record-video',
                      );
                      return result is PendingDocument ? result : null;
                    }),
              icon: const Icon(Icons.videocam_outlined),
              label: Text(text.selectOptionalVideo),
            ),
        for (final video in controller.videos)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(video.fileName),
                  Text(
                    text.videoDurationLabel(
                      (video.duration!.inMilliseconds / 1000).ceil(),
                    ),
                  ),
                  Text(text.pendingUpload),
                  if (!readOnly)
                    TextButton.icon(
                      onPressed: controller.busy
                          ? null
                          : () => controller.remove(
                              controller.documents.indexOf(video),
                            ),
                      icon: const Icon(Icons.delete_outline),
                      label: Text(text.removeVideo),
                    ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}
