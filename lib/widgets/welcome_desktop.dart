import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/localization.dart';
import 'access_options.dart';
import 'brand_panel.dart';
import 'responsive_content.dart';

class WelcomeDesktop extends StatelessWidget {
  const WelcomeDesktop({
    super.key,
    this.onGoogle,
    this.busy = false,
    this.error,
  });
  final VoidCallback? onGoogle;
  final bool busy;
  final String? error;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        flex: 6,
        child: BrandPanel(title: strings(context).welcome, large: true),
      ),
      Expanded(
        flex: 5,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(40),
              child: ResponsiveContent(
                maxWidth: 400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 72,
                        height: 72,
                        semanticLabel: strings(context).appTitle,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      strings(context).accountTitle,
                      style: const TextStyle(
                        fontSize: 28,
                        height: 1.3,
                        color: AppColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 32),
                    AccessOptions(
                      onDark: false,
                      onGoogle: onGoogle,
                      busy: busy,
                      error: error,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
