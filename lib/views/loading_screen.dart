import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/localization.dart';
import '../widgets/responsive_content.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({
    super.key,
    this.failed = false,
    this.onRetry,
    this.preview = false,
  });
  final bool failed;
  final VoidCallback? onRetry;
  final bool preview;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ResponsiveContent(
            maxWidth: 480,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 120,
                  height: 120,
                  semanticLabel: strings(context).appTitle,
                ),
                const SizedBox(height: 56),
                Text(
                  strings(context).designWordmark,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  failed
                      ? strings(context).initializationFailed
                      : strings(context).loading,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 64),
                if (failed)
                  FilledButton(
                    onPressed: onRetry,
                    child: Text(strings(context).retry),
                  )
                else if (preview)
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(strings(context).back),
                  )
                else
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
