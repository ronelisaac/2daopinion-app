import 'package:flutter/material.dart';

import '../controllers/account_controller.dart';
import '../core/localization.dart';
import '../domain/account_draft.dart';
import '../domain/identity.dart';
import '../core/identity_messages.dart';
import '../widgets/terms_acceptance.dart';
import '../domain/operation_result.dart';
import '../widgets/form_page.dart';
import '../widgets/preview_dialog.dart';
import '../widgets/onboarding_progress.dart';
import '../widgets/access_button.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({
    super.key,
    required this.controller,
    this.onAuthenticated,
  });
  final AccountController controller;
  final Future<void> Function()? onAuthenticated;

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  var _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _accepted = false;
  bool _showPassword = false;
  String? _error;

  @override
  void dispose() {
    for (final controller in [
      _email,
      _firstName,
      _lastName,
      _password,
      _confirmation,
    ]) {
      controller.dispose();
    }
    widget.controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final text = strings(context);
    setState(() => _error = null);
    try {
      final result = await widget.controller.submit(
        AccountDraft(
          email: _email.text.trim(),
          firstName: _firstName.text.trim(),
          lastName: _lastName.text.trim(),
          password: _password.text,
          passwordConfirmation: _confirmation.text,
          acceptedPolicyVersion: _accepted
              ? widget.controller.requiredPolicyVersion
              : null,
        ),
      );
      if (!mounted) return;
      if (result == OperationResult.completed &&
          widget.onAuthenticated != null) {
        _password.clear();
        _confirmation.clear();
        await widget.onAuthenticated!();
        return;
      }
      await explainPreview(
        context,
        result == OperationResult.previewOnly
            ? text.accountPreview
            : text.actionCompleted,
      );
    } catch (error) {
      if (!mounted) return;
      if (error is IdentityFailure &&
          error.issue == IdentityIssue.profilePending &&
          widget.onAuthenticated != null) {
        _password.clear();
        _confirmation.clear();
        await widget.onAuthenticated!();
        return;
      }
      setState(() => _error = identityMessage(context, error));
    }
  }

  Future<void> _google() async {
    setState(() => _error = null);
    try {
      final result = await widget.controller.signInWithGoogle();
      if (!mounted) return;
      if (result == OperationResult.completed &&
          widget.onAuthenticated != null) {
        _password.clear();
        _confirmation.clear();
        await widget.onAuthenticated!();
      } else {
        await explainPreview(context, strings(context).accountPreview);
      }
    } catch (error) {
      if (mounted) setState(() => _error = identityMessage(context, error));
    }
  }

  void _setRegistering(bool value) {
    _formKey = GlobalKey<FormState>();
    setState(() {
      _error = null;
      _accepted = false;
      _showPassword = false;
    });
    _password.clear();
    _confirmation.clear();
    widget.controller.setRegistering(value);
  }

  @override
  Widget build(BuildContext context) {
    final text = strings(context);
    final controller = widget.controller;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) => Form(
        key: _formKey,
        child: FormPage(
          title: text.accountTitle,
          action: text.continueAction,
          onAction: _submit,
          busy: controller.busy,
          showFooter: widget.onAuthenticated != null,
          children: [
            if (controller.registering) const OnboardingProgress(step: 1),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: controller.busy
                        ? null
                        : () => _setRegistering(false),
                    child: Text(
                      text.signIn,
                      style: TextStyle(
                        fontWeight: !controller.registering
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: controller.busy
                        ? null
                        : () => _setRegistering(true),
                    child: Text(
                      text.createAccount,
                      style: TextStyle(
                        fontWeight: controller.registering
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const ValueKey('email'),
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: text.email,
                hintText: text.emailHint,
              ),
              validator: (value) =>
                  inputError(context, controller.validateEmail(value)),
            ),
            if (controller.registering) ...[
              const SizedBox(height: 20),
              TextFormField(
                key: const ValueKey('firstName'),
                maxLength: 80,
                controller: _firstName,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(labelText: text.firstName),
                validator: (value) =>
                    inputError(context, controller.validateName(value)),
              ),
              const SizedBox(height: 20),
              TextFormField(
                key: const ValueKey('lastName'),
                maxLength: 80,
                controller: _lastName,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(labelText: text.lastName),
                validator: (value) =>
                    inputError(context, controller.validateName(value)),
              ),
            ],
            const SizedBox(height: 20),
            TextFormField(
              key: const ValueKey('password'),
              controller: _password,
              obscureText: !_showPassword,
              enableSuggestions: false,
              autocorrect: false,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => _showPassword = !_showPassword),
                  tooltip: _showPassword
                      ? text.hidePassword
                      : text.showPassword,
                  icon: Icon(
                    _showPassword ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
                labelText: controller.registering
                    ? text.choosePassword
                    : text.password,
              ),
              validator: (value) =>
                  inputError(context, controller.validatePassword(value)),
            ),
            if (controller.registering) ...[
              const SizedBox(height: 20),
              TextFormField(
                key: const ValueKey('repeatPassword'),
                controller: _confirmation,
                obscureText: !_showPassword,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(labelText: text.repeatPassword),
                validator: (value) => inputError(
                  context,
                  controller.validateConfirmation(value, _password.text),
                ),
              ),
              if (controller.requiredPolicyVersion != null)
                TermsAcceptance(
                  value: _accepted,
                  onChanged: controller.busy
                      ? null
                      : (value) => setState(() => _accepted = value),
                ),
            ],
            if (!controller.registering && widget.onAuthenticated != null)
              TextButton(
                onPressed: controller.busy
                    ? null
                    : () => Navigator.pushNamed(context, '/reset-password'),
                child: Text(text.resetPassword),
              ),
            if (_error != null)
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            if (widget.onAuthenticated != null) ...[
              const SizedBox(height: 20),
              AccessButton(
                label: text.google,
                asset: 'google',
                onPressed: controller.busy ? null : _google,
              ),
              const SizedBox(height: 8),
              Text(text.googleSetupPending),
            ],
          ],
        ),
      ),
    );
  }
}
