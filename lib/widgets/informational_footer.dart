import 'package:flutter/material.dart';
import '../core/localization.dart';
import '../core/app_theme.dart';
import 'preview_notice.dart';

class InformationalFooter extends StatelessWidget {
  const InformationalFooter({super.key, this.showPreviewNotice = false});
  final bool showPreviewNotice;
  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.pageBackground,
    child: Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.greyLight)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            ),
            if (showPreviewNotice) const PreviewNotice(),
          ],
        ),
      ),
    ),
  );
}
