import 'package:flutter/material.dart';
import '../controllers/session_controller.dart';
import '../core/localization.dart';
import '../core/identity_messages.dart';
import 'loading_screen.dart';
import 'verification_screen.dart';

class SessionGate extends StatelessWidget {
  const SessionGate({
    super.key,
    required this.controller,
    required this.signedOut,
    required this.incomplete,
    required this.child,
  });
  final SessionController controller;
  final WidgetBuilder signedOut;
  final WidgetBuilder incomplete;
  final Widget child;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => switch (controller.status) {
      SessionStatus.loading => const LoadingScreen(),
      SessionStatus.signedOut => signedOut(context),
      SessionStatus.incomplete => incomplete(context),
      SessionStatus.unverified => VerificationScreen(controller: controller),
      SessionStatus.ready => child,
      SessionStatus.failed => Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(strings(context).sessionLoadFailed),
                ),
                FilledButton(
                  onPressed: controller.start,
                  child: Text(strings(context).retry),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      await controller.signOut();
                    } catch (error) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(identityMessage(context, error)),
                          ),
                        );
                      }
                    }
                  },
                  child: Text(strings(context).signOut),
                ),
              ],
            ),
          ),
        ),
      ),
    },
  );
}
