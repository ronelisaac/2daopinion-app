import 'package:flutter/material.dart';
import '../core/localization.dart';
import '../domain/consultation_draft.dart';

class ConsultationReadiness extends StatelessWidget {
  const ConsultationReadiness({
    super.key,
    required this.content,
    required this.onEdit,
  });

  final ConsultationDraft content;
  final ValueChanged<int>? onEdit;

  @override
  Widget build(BuildContext context) {
    final text = strings(context);
    final missing = content.missingSubmissionFields;
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: colors.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              text.requiredChecklistTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(text.requiredChecklistNotice),
            const SizedBox(height: 12),
            for (final field in SubmissionField.values)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExcludeSemantics(
                      child: Icon(
                        missing.contains(field)
                            ? Icons.radio_button_unchecked
                            : Icons.check_circle_outline,
                        color: missing.contains(field)
                            ? colors.onSurfaceVariant
                            : colors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 40),
                        ),
                        onPressed: onEdit == null
                            ? null
                            : () => onEdit!(
                                field == SubmissionField.modality ? 2 : 0,
                              ),
                        child: Text(
                          '${switch (field) {
                            SubmissionField.reason => text.reason,
                            SubmissionField.details => text.details,
                            SubmissionField.modality => text.preferredModality,
                          }} · ${missing.contains(field) ? text.requiredPending : text.requiredProvided}',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (!content.withinStorageLimits)
              Text(
                text.requestLimitsError,
                style: TextStyle(color: colors.error),
              ),
          ],
        ),
      ),
    );
  }
}
