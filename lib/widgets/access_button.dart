import 'package:flutter/material.dart';

import 'asset_icon.dart';

class AccessButton extends StatelessWidget {
  const AccessButton({
    super.key,
    required this.label,
    required this.asset,
    required this.onPressed,
    this.background = const Color(0xFFF5F5F5),
    this.foreground = const Color(0xFF2D2938),
  });

  final String label;
  final String asset;
  final VoidCallback onPressed;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: onPressed,
    style: FilledButton.styleFrom(
      minimumSize: const Size(double.infinity, 57),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      backgroundColor: background,
      foregroundColor: foreground,
      textStyle: const TextStyle(fontFamily: 'Montserrat', fontSize: 16),
    ),
    child: Row(
      children: [
        AssetIcon(asset, size: 28),
        const SizedBox(width: 18),
        Expanded(child: Text(label, textAlign: TextAlign.center)),
      ],
    ),
  );
}
