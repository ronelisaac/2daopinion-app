import 'package:flutter/material.dart';
import '../controllers/password_reset_controller.dart';
import '../domain/input_validation.dart';
import '../core/localization.dart';
import '../core/identity_messages.dart';
import '../widgets/form_page.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key, required this.controller});
  final PasswordResetController controller;
  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  String? _error;
  @override
  void dispose() {
    _email.dispose();
    widget.controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _error = null);
    try {
      await widget.controller.submit(_email.text);
    } catch (error) {
      if (mounted) setState(() => _error = identityMessage(context, error));
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, child) => Form(
      key: _form,
      child: FormPage(
        title: strings(context).resetPassword,
        action: widget.controller.sent
            ? strings(context).back
            : strings(context).sendReset,
        onAction: widget.controller.sent
            ? () => Navigator.pop(context)
            : _submit,
        busy: widget.controller.busy,
        children: [
          if (widget.controller.sent)
            Text(strings(context).resetSent)
          else
            TextFormField(
              key: const ValueKey('resetEmail'),
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: InputDecoration(labelText: strings(context).email),
              validator: (value) =>
                  inputError(context, InputValidation.email(value)),
            ),
          if (_error != null)
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
        ],
      ),
    ),
  );
}
