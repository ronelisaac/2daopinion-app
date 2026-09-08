import 'package:flutter/material.dart';

import '../widgets/preview_notice.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/welcome_desktop.dart';
import '../widgets/welcome_mobile.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
    this.onGoogle,
    this.busy = false,
    this.error,
  });
  final VoidCallback? onGoogle;
  final bool busy;
  final String? error;

  @override
  Widget build(BuildContext context) => Scaffold(
    bottomNavigationBar: const PreviewNotice(),
    body: ResponsiveLayout(
      builder: (context, layout) => layout.isExpanded
          ? WelcomeDesktop(onGoogle: onGoogle, busy: busy, error: error)
          : WelcomeMobile(onGoogle: onGoogle, busy: busy, error: error),
    ),
  );
}
