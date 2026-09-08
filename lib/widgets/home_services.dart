import 'package:flutter/material.dart';

import '../core/localization.dart';
import 'asset_icon.dart';
import 'preview_dialog.dart';
import 'responsive_layout.dart';
import 'service_action.dart';

class HomeServices extends StatelessWidget {
  const HomeServices({
    super.key,
    this.requestRoute = '/request',
    this.draftMode = false,
  });
  final String requestRoute;
  final bool draftMode;

  @override
  Widget build(BuildContext context) => ResponsiveLayout(
    builder: (context, layout) {
      final text = strings(context);
      final columns = !layout.isCompact;
      final width = columns
          ? ((layout.width - 24) / 2).clamp(0.0, 360.0)
          : layout.width;
      return Wrap(
        alignment: WrapAlignment.center,
        spacing: 24,
        runSpacing: 34,
        children: [
          SizedBox(
            width: width,
            child: ServiceAction(
              expanded: columns,
              label: text.consultation,
              subtitle: draftMode
                  ? text.draftServiceSubtitle
                  : text.consultationSubtitle,
              icon: Image.asset(
                'assets/images/logo-white.png',
                width: 49,
                height: 49,
                excludeFromSemantics: true,
              ),
              onTap: () => Navigator.pushNamed(context, requestRoute),
            ),
          ),
          SizedBox(
            width: width,
            child: ServiceAction(
              expanded: columns,
              label: text.prescription,
              subtitle: text.prescriptionSubtitle,
              icon: const AssetIcon('prescription', size: 44),
              onTap: () => explainPreview(context, text.prescriptionSubtitle),
            ),
          ),
        ],
      );
    },
  );
}
