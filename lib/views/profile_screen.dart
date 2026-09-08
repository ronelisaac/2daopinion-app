import 'package:flutter/material.dart';
import '../controllers/profile_controller.dart';
import '../domain/identity.dart';
import '../core/localization.dart';
import '../core/identity_messages.dart';
import '../widgets/form_page.dart';
import '../widgets/terms_acceptance.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.controller,
    required this.onSaved,
    required this.onSignOut,
    this.profile,
  });
  final ProfileController controller;
  final PatientProfile? profile;
  final Future<void> Function() onSaved;
  final Future<void> Function() onSignOut;
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _form = GlobalKey<FormState>();
  late final _firstName = TextEditingController(
    text: widget.profile?.firstName ?? '',
  );
  late final _lastName = TextEditingController(
    text: widget.profile?.lastName ?? '',
  );
  bool _accepted = false;
  String? _error;
  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    widget.controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _error = null);
    try {
      await widget.controller.save(
        firstName: _firstName.text,
        lastName: _lastName.text,
        acceptTerms: _accepted,
        completing: widget.profile == null,
      );
      if (!mounted) return;
      await widget.onSaved();
    } catch (error) {
      if (mounted) setState(() => _error = identityMessage(context, error));
    }
  }

  Future<void> _signOut() async {
    try {
      await widget.onSignOut();
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
        title: widget.profile == null
            ? strings(context).completeProfile
            : strings(context).myProfile,
        action: strings(context).saveProfile,
        onAction: _save,
        busy: widget.controller.busy,
        children: [
          if (widget.profile == null)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(strings(context).profilePending),
            ),
          TextFormField(
            key: const ValueKey('profileFirstName'),
            controller: _firstName,
            maxLength: 80,
            decoration: InputDecoration(labelText: strings(context).firstName),
            validator: (value) => widget.controller.validName(value ?? '')
                ? null
                : strings(context).nameLength,
          ),
          const SizedBox(height: 20),
          TextFormField(
            key: const ValueKey('profileLastName'),
            controller: _lastName,
            maxLength: 80,
            decoration: InputDecoration(labelText: strings(context).lastName),
            validator: (value) => widget.controller.validName(value ?? '')
                ? null
                : strings(context).nameLength,
          ),
          if (widget.profile == null)
            TermsAcceptance(
              value: _accepted,
              onChanged: widget.controller.busy
                  ? null
                  : (value) => setState(() => _accepted = value),
            ),
          if (_error != null)
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          TextButton(
            onPressed: widget.controller.busy ? null : _signOut,
            child: Text(strings(context).signOut),
          ),
        ],
      ),
    ),
  );
}
