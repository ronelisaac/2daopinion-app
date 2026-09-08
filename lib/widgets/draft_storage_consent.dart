import 'package:flutter/material.dart';
import '../core/localization.dart';

class DraftStorageConsent extends StatelessWidget {
  const DraftStorageConsent({
    super.key,
    required this.recorded,
    required this.value,
    required this.onChanged,
  });
  final bool recorded;
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextButton(
        onPressed: () => Navigator.pushNamed(context, '/draft-terms'),
        child: Text(strings(context).draftReadTerms),
      ),
      if (recorded)
        Text(strings(context).draftConsentRecorded)
      else
        CheckboxListTile(
          key: const ValueKey('draftConsent'),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: value,
          onChanged: (value) => onChanged(value ?? false),
          title: Text(strings(context).draftConsentLabel),
        ),
    ],
  );
}
