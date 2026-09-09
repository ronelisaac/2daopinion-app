import 'package:flutter/material.dart';
import '../controllers/consultation_submission_controller.dart';
import '../domain/consultation_submission.dart';
import '../domain/saved_consultation_draft.dart';
import '../core/localization.dart';

class SubmissionPanel extends StatefulWidget {
  const SubmissionPanel({
    super.key,
    required this.controller,
    required this.draft,
    required this.dirty,
    required this.hasAttachments,
    required this.blocked,
  });
  final ConsultationSubmissionController controller;
  final SavedConsultationDraft? draft;
  final bool dirty;
  final bool hasAttachments;
  final bool blocked;
  @override
  State<SubmissionPanel> createState() => _SubmissionPanelState();
}

class _SubmissionPanelState extends State<SubmissionPanel> {
  bool accepted = false;
  @override
  void didUpdateWidget(SubmissionPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.draft?.revision != widget.draft?.revision ||
        (!oldWidget.dirty && widget.dirty)) {
      accepted = false;
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) {
      final text = strings(context);
      final controller = widget.controller;
      final receipt = controller.receipt;
      final disabled = widget.blocked || controller.busy;
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                text.submissionTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (receipt != null) ...[
                SelectableText(text.submissionReceipt(receipt.reference)),
                Text(text.submissionImmutable),
              ] else ...[
                Text(text.submissionNotice),
                const SizedBox(height: 12),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(text.submissionTerms),
                  value: accepted,
                  onChanged: disabled
                      ? null
                      : (value) => setState(() => accepted = value ?? false),
                ),
                if (controller.loaded)
                  FilledButton.icon(
                    onPressed: disabled
                        ? null
                        : () => controller.submit(
                            widget.draft,
                            accepted: accepted,
                            dirty: widget.dirty,
                            hasAttachments: widget.hasAttachments,
                          ),
                    icon: const Icon(Icons.send_outlined),
                    label: Text(text.submissionSend),
                  )
                else if (!controller.busy)
                  TextButton(
                    onPressed: controller.load,
                    child: Text(text.retry),
                  ),
              ],
              if (controller.busy) const LinearProgressIndicator(),
              if (controller.issue != null)
                Text(
                  switch (controller.issue!) {
                    SubmissionIssue.consent => text.submissionConsentError,
                    SubmissionIssue.unsaved => text.submissionUnsavedError,
                    SubmissionIssue.invalid => text.submissionInvalidError,
                    SubmissionIssue.attachments =>
                      text.submissionAttachmentsError,
                    SubmissionIssue.session => text.submissionSessionError,
                    SubmissionIssue.conflict => text.submissionConflictError,
                    SubmissionIssue.unavailable =>
                      text.submissionUnavailableError,
                  },
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
            ],
          ),
        ),
      );
    },
  );
}
