import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/localization.dart';

class HomeNavigation extends StatelessWidget {
  const HomeNavigation({
    super.key,
    required this.onHome,
    required this.onLoading,
    required this.onExit,
    this.onProfile,
    this.connected = false,
  });

  final VoidCallback onHome;
  final VoidCallback onLoading;
  final VoidCallback onExit;
  final VoidCallback? onProfile;
  final bool connected;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    child: SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        children: [
          Image.asset(
            'assets/images/logo.png',
            width: 64,
            height: 64,
            semanticLabel: strings(context).appTitle,
          ),
          const SizedBox(height: 16),
          Text(
            strings(context).appTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 40),
          ListTile(
            title: Text(strings(context).home),
            selected: true,
            selectedColor: AppColors.primary,
            selectedTileColor: AppColors.primaryLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            onTap: onHome,
          ),
          const SizedBox(height: 8),
          ListTile(
            title: Text(strings(context).loadingPreview),
            onTap: onLoading,
          ),
          const Divider(height: 32),
          if (onProfile != null)
            ListTile(title: Text(strings(context).myProfile), onTap: onProfile),
          ListTile(
            title: Text(
              connected
                  ? strings(context).signOut
                  : strings(context).backToWelcome,
            ),
            onTap: onExit,
          ),
        ],
      ),
    ),
  );
}
