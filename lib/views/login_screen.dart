import 'package:flutter/material.dart';
import '../controllers/account_controller.dart';
import '../core/identity_messages.dart';
import '../core/localization.dart';
import '../domain/operation_result.dart';
import '../widgets/preview_dialog.dart';
import 'welcome_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.controller,
    required this.onAuthenticated,
  });
  final AccountController controller;
  final Future<void> Function() onAuthenticated;
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? _error;
  Future<void> _google() async {
    setState(() => _error = null);
    try {
      final result = await widget.controller.signInWithGoogle();
      if (!mounted) return;
      if (result == OperationResult.completed) {
        await widget.onAuthenticated();
      } else {
        await explainPreview(context, strings(context).accountPreview);
      }
    } catch (error) {
      if (mounted) setState(() => _error = identityMessage(context, error));
    }
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) => WelcomeScreen(
      onGoogle: _google,
      busy: widget.controller.busy,
      error: _error,
    ),
  );
}
