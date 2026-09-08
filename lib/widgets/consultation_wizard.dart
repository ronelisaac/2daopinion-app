import 'package:flutter/material.dart';
import '../core/localization.dart';
import '../domain/consultation_draft.dart';
import 'consultation_review.dart';

class ConsultationWizard extends StatelessWidget {
  const ConsultationWizard({
    super.key,
    required this.step,
    required this.onStep,
    required this.consultationFields,
    required this.clinicalFields,
    required this.content,
    this.busy = false,
  });
  final int step;
  final ValueChanged<int> onStep;
  final Widget consultationFields;
  final Widget clinicalFields;
  final ConsultationDraft content;
  final bool busy;
  Widget _retained(bool visible, Widget child) => ExcludeFocus(
    excluding: !visible,
    child: Visibility(visible: visible, maintainState: true, child: child),
  );
  @override
  Widget build(BuildContext context) {
    final text = strings(context);
    final labels = [
      text.consultationStep,
      text.contextStep,
      text.goalsStep,
      text.reviewStep,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          liveRegion: true,
          child: Text(text.consultationProgress(step + 1, labels[step])),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: (step + 1) / labels.length),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var index = 0; index < labels.length; index++)
              ChoiceChip(
                key: ValueKey('consultationStep$index'),
                label: Text(labels[index]),
                selected: step == index,
                onSelected: busy ? null : (_) => onStep(index),
              ),
          ],
        ),
        const SizedBox(height: 24),
        _retained(step == 0, consultationFields),
        _retained(step == 1 || step == 2, clinicalFields),
        if (step == 3)
          ConsultationReview(content: content, onEdit: busy ? null : onStep),
        if (step > 0)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: busy ? null : () => onStep(step - 1),
              child: Text(text.previousStep),
            ),
          ),
      ],
    );
  }
}
