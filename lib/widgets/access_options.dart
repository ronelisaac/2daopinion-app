import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/localization.dart';
import 'access_button.dart';
import 'preview_dialog.dart';

class AccessOptions extends StatelessWidget {
  const AccessOptions({super.key, this.onDark = true});

  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final text = strings(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AccessButton(
          label: text.facebook,
          asset: 'facebook',
          background: AppColors.facebook,
          foreground: Colors.white,
          onPressed: () => explainPreview(context, text.pendingFeature),
        ),
        const SizedBox(height: 16),
        AccessButton(
          label: text.google,
          asset: 'google',
          onPressed: () => explainPreview(context, text.pendingFeature),
        ),
        const SizedBox(height: 16),
        AccessButton(
          label: text.emailAccess,
          asset: 'email',
          onPressed: () => Navigator.pushNamed(context, '/account'),
        ),
        const SizedBox(height: 8),
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
          onPressed: () => Navigator.pushNamed(context, '/preview'),
          style: TextButton.styleFrom(
            foregroundColor: onDark ? Colors.white : AppColors.primary,
          ),
          child: Text(text.explore, style: const TextStyle(fontSize: 12)),
        ),
      ],
    );
  }
}
