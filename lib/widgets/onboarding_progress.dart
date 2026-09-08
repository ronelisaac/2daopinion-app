import 'package:flutter/material.dart';
import '../core/localization.dart';

class OnboardingProgress extends StatelessWidget {
  const OnboardingProgress({super.key, required this.step});
  final int step;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          strings(context).onboardingProgress(step),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: step / 3),
      ],
    ),
  );
}
