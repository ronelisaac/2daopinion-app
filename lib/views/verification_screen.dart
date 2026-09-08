import 'package:flutter/material.dart';
import '../controllers/session_controller.dart';
import '../core/localization.dart';
import '../core/identity_messages.dart';
import '../widgets/form_page.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key, required this.controller});
  final SessionController controller;
  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  String? _message;
  Future<void> _perform(Future<void> Function() action, String message) async {
    try {
      await action();
      if (mounted) setState(() => _message = message);
    } catch (error) {
      if (mounted) setState(() => _message = identityMessage(context, error));
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, child) => FormPage(
      title: strings(context).verifyEmail,
      action: strings(context).checkVerification,
      busy: widget.controller.busy,
      onAction: () => _perform(
        widget.controller.checkVerification,
        strings(context).verificationPending,
      ),
      children: [
        Text(strings(context).verificationInstructions),
        const SizedBox(height: 16),
        Text(widget.controller.user?.email ?? ''),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: widget.controller.busy
              ? null
              : () => _perform(
                  widget.controller.sendVerification,
                  strings(context).verificationSent,
                ),
          child: Text(strings(context).sendVerification),
        ),
        if (_message != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(_message!),
          ),
        TextButton(
          onPressed: widget.controller.busy
              ? null
              : () => _perform(widget.controller.signOut, ''),
          child: Text(strings(context).signOut),
        ),
      ],
    ),
  );
}
