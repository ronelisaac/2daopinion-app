import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/localization.dart';
import 'access_button.dart';
import 'preview_dialog.dart';

class AccessOptions extends StatelessWidget {
  const AccessOptions({
    super.key,
    this.onDark = true,
    this.onGoogle,
    this.busy = false,
    this.error,
  });

  final bool onDark;
  final VoidCallback? onGoogle;
  final bool busy;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final text = strings(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AccessButton(
          label: text.google,
          asset: 'google',
          onPressed: busy
              ? null
              : onGoogle ?? () => explainPreview(context, text.pendingFeature),
        ),
        const SizedBox(height: 16),
        AccessButton(
          label: text.emailAccess,
          asset: 'email',
          onPressed: busy
              ? null
              : () => Navigator.pushNamed(context, '/account'),
        ),
        if (busy) const LinearProgressIndicator(),
        if (error != null)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              error!,
              style: TextStyle(color: onDark ? Colors.white : AppColors.ink),
            ),
          ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: busy
              ? null
              : () => Navigator.pushNamed(context, '/register'),
          style: TextButton.styleFrom(
            foregroundColor: onDark ? Colors.white : AppColors.primary,
          ),
          child: Text(text.createAccount),
        ),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/terms'),
          style: TextButton.styleFrom(
            foregroundColor: onDark ? Colors.white : AppColors.ink,
          ),
          child: Text(
            text.terms,
            style: const TextStyle(
              fontSize: 11,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        TextButton(
          onPressed: busy ? null : () => Navigator.pushNamed(context, '/home'),
          style: TextButton.styleFrom(
            foregroundColor: onDark ? Colors.white : AppColors.primary,
          ),
          child: Text(
            text.continueAsGuest,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}
