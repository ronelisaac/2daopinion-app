import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/localization.dart';

class PreviewNotice extends StatelessWidget {
  const PreviewNotice({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      color: const Color(0xFFF2F5F4),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        strings(context).preview,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 10, color: AppColors.dark),
      ),
    ),
  );
}
