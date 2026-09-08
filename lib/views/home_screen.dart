import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/localization.dart';
import '../widgets/asset_icon.dart';
import '../widgets/home_navigation.dart';
import '../widgets/home_services.dart';
import '../widgets/preview_notice.dart';
import '../widgets/responsive_content.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/informational_footer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    this.onSignOut,
    this.requestRoute = '/request',
    this.showFooter = false,
  });
  final VoidCallback? onSignOut;
  final String requestRoute;
  final bool showFooter;

  @override
  Widget build(BuildContext context) => ResponsiveLayout(
    builder: (context, layout) {
      final text = strings(context);
      final navigation = HomeNavigation(
        onHome: () {
          if (!layout.isExpanded) Navigator.pop(context);
        },
        onLoading: () {
          if (!layout.isExpanded) Navigator.pop(context);
          Navigator.pushNamed(context, '/loading');
        },
        connected: onSignOut != null,
        onProfile: onSignOut == null
            ? null
            : () => Navigator.pushNamed(context, '/profile'),
        onExit:
            onSignOut ??
            () => Navigator.popUntil(context, (route) => route.isFirst),
      );
      return Scaffold(
        backgroundColor: AppColors.primary,
        bottomNavigationBar: const PreviewNotice(),
        drawer: layout.isExpanded ? null : Drawer(child: navigation),
        appBar: layout.isExpanded
            ? null
            : AppBar(
                toolbarHeight: 64,
                elevation: 0,
                leading: Builder(
                  builder: (context) => IconButton(
                    tooltip: text.menu,
                    icon: const AssetIcon('menu', size: 18),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
              ),
        body: Row(
          children: [
            if (layout.isExpanded)
              SizedBox(
                key: const ValueKey('desktopNavigation'),
                width: 240,
                child: navigation,
              ),
            Expanded(
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    layout.pagePadding,
                    layout.isExpanded ? 64 : 22,
                    layout.pagePadding,
                    48,
                  ),
                  child: ResponsiveContent(
                    maxWidth: 960,
                    child: Column(
                      children: [
                        Text(
                          text.homeTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: layout.isExpanded ? 36 : 25,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: layout.isExpanded ? 56 : 32),
                        HomeServices(requestRoute: requestRoute),
                        if (showFooter)
                          const Padding(
                            padding: EdgeInsets.only(top: 32),
                            child: Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                              child: InformationalFooter(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
