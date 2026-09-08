import 'package:flutter/material.dart';
import 'controllers/account_controller.dart';
import 'controllers/guest_draft_controller.dart';
import 'views/guest_request_screen.dart';
import 'views/request_entry_screen.dart';
import 'views/login_screen.dart';
import 'widgets/guest_home_intro.dart';
import 'controllers/draft_overview_controller.dart';
import 'domain/draft_overview.dart';
import 'widgets/draft_overview_card.dart';
import 'views/patient_home_screen.dart';
import 'controllers/consultation_controller.dart';
import 'controllers/consultation_draft_controller.dart';
import 'domain/repositories/consultation_draft_repository.dart';
import 'views/draft_request_screen.dart';
import 'controllers/password_reset_controller.dart';
import 'controllers/profile_controller.dart';
import 'controllers/session_controller.dart';
import 'core/app_theme.dart';
import 'core/identity_messages.dart';
import 'core/localization.dart';
import 'domain/country_config.dart';
import 'domain/identity.dart';
import 'domain/repositories/account_repository.dart';
import 'domain/repositories/identity_repository.dart';
import 'l10n/app_localizations.dart';
import 'repositories/preview_consultation_repository.dart';
import 'views/account_screen.dart';
import 'views/home_screen.dart';
import 'views/information_screen.dart';
import 'views/loading_screen.dart';
import 'views/password_reset_screen.dart';
import 'views/profile_screen.dart';
import 'views/request_screen.dart';
import 'views/session_gate.dart';
import 'controllers/document_selection_controller.dart';
import 'repositories/local_document_selection_repository.dart';

class ConnectedApp extends StatefulWidget {
  const ConnectedApp({
    super.key,
    required this.initialize,
    required this.identityRepository,
    required this.accountRepository,
    required this.draftRepository,
  });
  final Future<void> Function() initialize;
  final IdentityRepository identityRepository;
  final AccountRepository accountRepository;
  final ConsultationDraftRepository draftRepository;
  @override
  State<ConnectedApp> createState() => _ConnectedAppState();
}

class _ConnectedAppState extends State<ConnectedApp> {
  final _guest = GuestDraftController();
  final _documents = DocumentSelectionController(
    LocalDocumentSelectionRepository(),
  );
  late final SessionController _session;
  var _navigator = GlobalKey<NavigatorState>();
  int _navigationEpoch = 0;
  int _accessNavigation = 0;
  @override
  void initState() {
    super.initState();
    _session = SessionController(
      widget.identityRepository,
      initialize: widget.initialize,
    )..start();
  }

  @override
  void dispose() {
    _documents.dispose();
    _guest.clear();
    _session.dispose();
    super.dispose();
  }

  Future<void> _returnHome() async {
    if (mounted) {
      final navigation = ++_accessNavigation;
      final refreshing = _session.refresh();
      final navigator = _navigator.currentState;
      navigator?.pushNamedAndRemoveUntil('/home', (_) => false);
      if (_guest.resumeAfterAccess && navigator != null) {
        navigator.pushNamed('/continue-request').then((_) {
          if (mounted &&
              navigation == _accessNavigation &&
              identical(navigator, _navigator.currentState) &&
              _session.status == SessionStatus.ready &&
              !navigator.canPop()) {
            navigator.pushNamedAndRemoveUntil('/home', (_) => false);
          }
        });
      }
      await refreshing;
    }
  }

  Widget _account(BuildContext context) => AccountScreen(
    controller: AccountController(
      widget.accountRepository,
      requiredPolicyVersion: developmentPolicyVersion,
    ),
    onAuthenticated: _returnHome,
  );
  Widget _login(BuildContext context) => LoginScreen(
    controller: AccountController(widget.accountRepository),
    onAuthenticated: _returnHome,
  );
  Widget _guestHome(BuildContext context) => HomeScreen(
    showFooter: true,
    onLogin: () => Navigator.pushNamed(context, '/login'),
    secondaryContent: GuestHomeIntro(
      onAccess: () => Navigator.pushNamed(context, '/login'),
    ),
  );
  Widget _profile(BuildContext context) => ProfileScreen(
    controller: ProfileController(widget.identityRepository),
    profile: _session.profile,
    onSaved: _returnHome,
    onSignOut: _session.signOut,
  );
  Widget _guard(Widget child, {bool welcome = false}) => SessionGate(
    controller: _session,
    signedOut: welcome ? _guestHome : _account,
    incomplete: _profile,
    child: child,
  );
  Widget _request() => RequestScreen(
    controller: ConsultationController(
      const PreviewConsultationRepository(),
      country: CountryConfig.chile,
    ),
  );

  Widget _memberRequest() => _guard(
    Builder(
      builder: (_) => DraftRequestScreen(
        documents: _documents,
        initialDraft: _guest.resumeAfterAccess ? _guest.content : null,
        onInitialDraftConsumed: _guest.clear,
        controller: ConsultationDraftController(
          widget.draftRepository,
          country: CountryConfig.chile,
        ),
      ),
    ),
  );

  Widget _home(BuildContext context) => PatientHomeScreen(
    controller: DraftOverviewController(widget.draftRepository),
    onSignOut: () async {
      try {
        await _session.signOut();
      } catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(identityMessage(context, error))),
          );
        }
      }
    },
  );

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _session,
    builder: (context, child) {
      if (_navigationEpoch != _session.navigationEpoch) {
        _documents.clear(notify: false);
        _guest.clear();
        _navigationEpoch = _session.navigationEpoch;
        _navigator = GlobalKey<NavigatorState>();
      }
      return MaterialApp(
        key: ValueKey(_session.navigationEpoch),
        navigatorKey: _navigator,
        debugShowCheckedModeBanner: false,
        onGenerateTitle: (context) => strings(context).appTitle,
        theme: buildAppTheme(),
        locale: const Locale('es'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        initialRoute: '/',
        routes: {
          '/': (context) => _guard(_home(context), welcome: true),
          '/account': _account,
          '/login': _login,
          '/register': (context) => AccountScreen(
            controller: AccountController(
              widget.accountRepository,
              requiredPolicyVersion: developmentPolicyVersion,
              registering: true,
            ),
            onAuthenticated: _returnHome,
          ),
          '/home': (context) => _guard(_home(context), welcome: true),
          '/profile': (context) => _guard(_profile(context)),
          '/continue-request': (_) => _memberRequest(),
          '/request': (context) => ListenableBuilder(
            listenable: _session,
            builder: (context, _) => RequestEntryScreen(
              guestAtEntry:
                  _session.status == SessionStatus.loading &&
                      _session.user == null
                  ? null
                  : _session.user == null,
              guest: GuestRequestScreen(
                documents: _documents,
                controller: _guest,
                onAccess: () {
                  if (_session.user == null) {
                    Navigator.pushNamed(context, '/login');
                  } else {
                    _returnHome();
                  }
                },
              ),
              member: _memberRequest(),
            ),
          ),
          '/preview': (context) => HomeScreen(
            requestRoute: '/preview/request',
            showFooter: true,
            secondaryContent: DraftOverviewCard(
              preview: true,
              overview: DraftOverview(
                updatedAt: DateTime.utc(2026, 9, 8),
                hasRequiredDetails: false,
              ),
              onOpen: () => Navigator.pushNamed(context, '/preview/request'),
            ),
          ),
          '/preview/request': (_) => _request(),
          '/loading': (_) => const LoadingScreen(preview: true),
          '/reset-password': (_) => PasswordResetScreen(
            controller: PasswordResetController(widget.identityRepository),
          ),
          '/terms': (context) => InformationScreen(
            title: strings(context).terms,
            body: strings(context).developmentTermsBody,
          ),
          '/draft-terms': (context) => InformationScreen(
            title: strings(context).draftReadTerms,
            body: strings(context).draftTermsBody,
          ),
          '/privacy': (context) => InformationScreen(
            title: strings(context).privacy,
            body: strings(context).developmentPrivacyBody,
          ),
          '/about': (context) => InformationScreen(
            title: strings(context).about,
            body: strings(context).aboutBody,
          ),
        },
      );
    },
  );
}
