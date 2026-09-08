import 'package:flutter/material.dart';
import '../core/localization.dart';

class GuestHomeIntro extends StatelessWidget {
  const GuestHomeIntro({super.key, required this.onAccess});
  final VoidCallback onAccess;
  @override
  Widget build(BuildContext context) {
    final text = strings(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            text.guestHomeTitle,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Text(text.guestHomeSteps),
          const SizedBox(height: 16),
          Text(text.noEmergencyNotice),
          const SizedBox(height: 20),
          FilledButton(onPressed: onAccess, child: Text(text.accessOrRegister)),
        ],
      ),
    );
  }
}
