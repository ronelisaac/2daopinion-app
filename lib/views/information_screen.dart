import 'package:flutter/material.dart';
import '../widgets/responsive_content.dart';
import '../widgets/informational_footer.dart';

class InformationScreen extends StatelessWidget {
  const InformationScreen({super.key, required this.title, required this.body});
  final String title;
  final String body;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    bottomNavigationBar: const InformationalFooter(),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ResponsiveContent(
          maxWidth: 760,
          child: SelectableText(body, style: const TextStyle(height: 1.6)),
        ),
      ),
    ),
  );
}
