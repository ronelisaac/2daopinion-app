import 'package:flutter/material.dart';

import '../core/localization.dart';

class BrandPanel extends StatelessWidget {
  const BrandPanel({super.key, required this.title, this.large = false});

  final String title;
  final bool large;

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      Image.asset(
        'assets/images/login-background.png',
        fit: BoxFit.cover,
        excludeFromSemantics: true,
      ),
      const ColoredBox(color: Color(0x59000000)),
      Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(large ? 48 : 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/images/logo-white.png',
                width: 64,
                height: 64,
                semanticLabel: strings(context).appTitle,
              ),
              const SizedBox(height: 32),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: large ? 38 : 26,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                strings(context).brandTagline,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
