import 'package:flutter/material.dart';
import '../core/localization.dart';

class InformationalFooter extends StatelessWidget {
  const InformationalFooter({super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      children: [
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/about'),
          child: Text(strings(context).about),
        ),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/terms'),
          child: Text(strings(context).terms),
        ),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/privacy'),
          child: Text(strings(context).privacy),
        ),
      ],
    ),
  );
}
