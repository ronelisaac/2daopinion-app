import 'package:flutter/material.dart';
import '../core/localization.dart';

class TermsAcceptance extends StatelessWidget {
  const TermsAcceptance({
    super.key,
    required this.value,
    required this.onChanged,
  });
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(strings(context).developmentTermsNotice),
      TextButton(
        onPressed: () => Navigator.pushNamed(context, '/terms'),
        child: Text(strings(context).readTerms),
      ),
      CheckboxListTile(
        key: const ValueKey('acceptTerms'),
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        value: value,
        onChanged: onChanged == null
            ? null
            : (value) => onChanged!(value ?? false),
        title: Text(strings(context).acceptDevelopmentTerms),
      ),
    ],
  );
}
