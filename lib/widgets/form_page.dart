import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/localization.dart';
import 'asset_icon.dart';
import 'brand_panel.dart';
import 'preview_notice.dart';
import 'informational_footer.dart';
import 'responsive_content.dart';
import 'responsive_layout.dart';

class FormPage extends StatelessWidget {
  const FormPage({
    super.key,
    required this.title,
    required this.children,
    required this.action,
    required this.onAction,
    this.busy = false,
    this.showFooter = false,
  });

  final String title;
  final List<Widget> children;
  final String action;
  final VoidCallback onAction;
  final bool busy;
  final bool showFooter;

  @override
  Widget build(BuildContext context) => ResponsiveLayout(
    builder: (context, layout) => Scaffold(
      backgroundColor: layout.isCompact
          ? Colors.white
          : AppColors.pageBackground,
      appBar: AppBar(
        toolbarHeight: layout.isCompact ? 45 : 72,
        leading: IconButton(
          tooltip: strings(context).back,
          onPressed: () => Navigator.maybePop(context),
          icon: const AssetIcon('back', size: 18),
        ),
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      bottomNavigationBar: showFooter
          ? const InformationalFooter(showPreviewNotice: true)
          : const PreviewNotice(),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: EdgeInsets.all(layout.isCompact ? 24 : 40),
            child: ResponsiveContent(
              maxWidth: layout.isExpanded ? 1120 : 720,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (layout.isExpanded) ...[
                    SizedBox(
                      width: 260,
                      height: 440,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BrandPanel(title: strings(context).appTitle),
                      ),
                    ),
                    const SizedBox(width: 32),
                  ],
                  Expanded(
                    child: Container(
                      key: const ValueKey('formSurface'),
                      padding: layout.isCompact
                          ? EdgeInsets.zero
                          : const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          layout.isCompact ? 0 : 16,
                        ),
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: layout.isCompact
                              ? (constraints.maxHeight - 48).clamp(
                                  0,
                                  double.infinity,
                                )
                              : 0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: children,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 32),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: layout.isCompact
                                        ? double.infinity
                                        : 320,
                                  ),
                                  child: FilledButton(
                                    onPressed: busy ? null : onAction,
                                    child: busy
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(action),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
