import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'controllers/account_controller.dart';
import 'controllers/consultation_controller.dart';
import 'domain/country_config.dart';
import 'domain/repositories/account_repository.dart';
import 'domain/repositories/consultation_repository.dart';
import 'l10n/app_localizations.dart';
import 'repositories/preview_account_repository.dart';
import 'repositories/preview_consultation_repository.dart';
import 'views/account_screen.dart';
import 'views/home_screen.dart';
import 'views/loading_screen.dart';
import 'views/request_screen.dart';
import 'views/bootstrap_view.dart';
import 'views/information_screen.dart';
import 'core/localization.dart';

class SegundaOpinionApp extends StatelessWidget {
  const SegundaOpinionApp({
    super.key,
    required this.initialize,
    this.country = CountryConfig.chile,
    this.locale = const Locale('es'),
    this.accountRepository = const PreviewAccountRepository(),
    this.consultationRepository = const PreviewConsultationRepository(),
  });

  final Future<void> Function() initialize;
  final CountryConfig country;
  final Locale locale;
  final AccountRepository accountRepository;
  final ConsultationRepository consultationRepository;

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
    theme: buildAppTheme(),
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: BootstrapView(initialize: initialize),
    routes: {
      '/account': (context) =>
          AccountScreen(controller: AccountController(accountRepository)),
      '/home': (context) => const HomeScreen(),
      '/preview': (context) => const HomeScreen(),
      '/terms': (context) => InformationScreen(
        title: strings(context).terms,
        body: strings(context).developmentTermsBody,
      ),
      '/request': (context) => RequestScreen(
        controller: ConsultationController(
          consultationRepository,
          country: country,
        ),
      ),
      '/loading': (context) => const LoadingScreen(preview: true),
    },
  );
}
