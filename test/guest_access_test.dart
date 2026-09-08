import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:segunda_opinion_app/connected_app.dart';
import 'package:segunda_opinion_app/controllers/account_controller.dart';
import 'package:segunda_opinion_app/domain/clinical_context.dart';
import 'package:segunda_opinion_app/domain/consultation_draft.dart';
import 'package:segunda_opinion_app/domain/country_config.dart';
import 'package:segunda_opinion_app/domain/identity.dart';
import 'package:segunda_opinion_app/domain/operation_result.dart';
import 'package:segunda_opinion_app/domain/saved_consultation_draft.dart';
import 'package:segunda_opinion_app/repositories/clinical_context_mapper.dart';
import 'package:segunda_opinion_app/repositories/firebase_identity_repository.dart';
import 'package:segunda_opinion_app/views/draft_request_screen.dart';
import 'package:segunda_opinion_app/views/guest_request_screen.dart';
import 'package:segunda_opinion_app/views/home_screen.dart';
import 'package:segunda_opinion_app/views/verification_screen.dart';
import 'package:segunda_opinion_app/views/login_screen.dart';
import 'package:segunda_opinion_app/views/request_entry_screen.dart';
import 'package:segunda_opinion_app/views/loading_screen.dart';
import 'package:segunda_opinion_app/core/app_theme.dart';
import 'package:segunda_opinion_app/l10n/app_localizations.dart';
import 'helpers/fake_draft_repository.dart';
import 'identity_test.dart' show FakeIdentity, storedProfile, verified;
import 'controllers_test.dart' show RecordingAccountRepository;

class PendingGoogle extends RecordingAccountRepository {
  final completion = Completer<OperationResult>();
  int calls = 0;
  @override
  Future<OperationResult> signInWithGoogle() {
    calls++;
    return completion.future;
  }
}

Future<void> press(WidgetTester tester, String label) async {
  final target = find.text(label);
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> fill(WidgetTester tester, String label, String value) async {
  final field = find.widgetWithText(TextFormField, label);
  await tester.ensureVisible(field);
  await tester.enterText(field, value);
  await tester.pumpAndSettle();
}

Future<void> mount(
  WidgetTester tester,
  FakeIdentity identity,
  FakeDraftRepository drafts,
) async {
  await tester.pumpWidget(
    ConnectedApp(
      initialize: () async {},
      identityRepository: identity,
      accountRepository: identity,
      draftRepository: drafts,
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> beginGuest(WidgetTester tester) async {
  await press(tester, 'Consulta médica');
  expect(find.byType(GuestRequestScreen), findsOneWidget);
  await fill(tester, 'Motivo de tu consulta', 'Motivo ficticio visitante');
  await fill(tester, 'Síntomas y evolución', 'Evolución ficticia');
  await fill(tester, 'Preguntas al especialista', 'Pregunta ficticia');
  await press(tester, 'CONTINUAR CON MI CUENTA');
}

void main() {
  testWidgets('switching to registration preserves email but clears password', (
    tester,
  ) async {
    final identity = FakeIdentity();
    addTearDown(identity.events.close);
    await mount(tester, identity, FakeDraftRepository());
    await press(tester, 'INGRESAR O CREAR CUENTA');
    await press(tester, 'Usa tu correo electrónico');
    await tester.enterText(
      find.byKey(const ValueKey('email')),
      'test@example.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('password')),
      'Test-only-123',
    );
    await press(tester, 'Crear cuenta');
    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('email')))
          .controller!
          .text,
      'test@example.com',
    );
    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('password')))
          .controller!
          .text,
      isEmpty,
    );
    expect(find.byKey(const ValueKey('firstName')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('expanded guest form supports large text on a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final identity = FakeIdentity();
    addTearDown(identity.events.close);
    await mount(tester, identity, FakeDraftRepository());
    await press(tester, 'Consulta médica');
    await tester.ensureVisible(find.text('CONTINUAR CON MI CUENTA'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'request entry waits for session restore and does not switch under login',
    (tester) async {
      Widget entry(bool? guest) => MaterialApp(
        theme: buildAppTheme(),
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: RequestEntryScreen(
          guestAtEntry: guest,
          guest: const Text('Guest'),
          member: const Text('Member'),
        ),
      );
      await tester.pumpWidget(entry(null));
      expect(find.byType(LoadingScreen), findsOneWidget);
      await tester.pumpWidget(entry(false));
      expect(find.text('Member'), findsOneWidget);
      await tester.pumpWidget(entry(true));
      expect(find.text('Member'), findsOneWidget);
    },
  );

  testWidgets(
    'cancel login keeps guest fields through resize and never writes',
    (tester) async {
      final identity = FakeIdentity();
      final drafts = FakeDraftRepository();
      addTearDown(identity.events.close);
      await mount(tester, identity, drafts);
      await beginGuest(tester);
      expect(find.byType(LoginScreen), findsOneWidget);
      Navigator.of(tester.element(find.byType(LoginScreen))).pop();
      await tester.pumpAndSettle();
      expect(find.text('Evolución ficticia'), findsOneWidget);
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpAndSettle();
      expect(find.text('Pregunta ficticia'), findsOneWidget);
      await tester.ensureVisible(find.text('CONTINUAR CON MI CUENTA'));
      await tester.pumpAndSettle();
      expect(drafts.loads, 0);
      expect(drafts.saves, 0);
      expect(tester.takeException(), isNull);
    },
  );
  test('clinical context round trip, legacy default and strict version', () {
    const context = ClinicalContext(
      symptomEvolution: 'Ejemplo',
      questions: 'Prueba',
      modality: 'document_review',
    );
    final decoded = ClinicalContextMapper.decode(
      ClinicalContextMapper.encode(context),
    );
    expect(decoded.symptomEvolution, context.symptomEvolution);
    expect(decoded.questions, context.questions);
    expect(decoded.modality, context.modality);
    expect(ClinicalContextMapper.decode(null).allergies, '');
    expect(
      () => ClinicalContextMapper.decode({'schemaVersion': 2}),
      throwsFormatException,
    );
    expect(
      const ClinicalContext(modality: 'invented').withinStorageLimits,
      isFalse,
    );
    expect(ClinicalContext(allergies: 'x' * 4001).withinStorageLimits, isFalse);
  });
  test('Google stays disabled without even accessing Firebase', () async {
    final repository = FirebaseIdentityRepository(
      auth: () => throw StateError('Must not access Firebase'),
      database: () => throw StateError('Must not access Firestore'),
      country: CountryConfig.chile,
      locale: 'es',
    );
    await expectLater(
      repository.signInWithGoogle(),
      throwsA(
        isA<IdentityFailure>().having(
          (error) => error.issue,
          'issue',
          IdentityIssue.googleUnavailable,
        ),
      ),
    );
  });
  test(
    'Google handles cancellation, excludes duplicates and unlocks after disposal',
    () async {
      final repository = PendingGoogle();
      final controller = AccountController(repository);
      final pending = controller.signInWithGoogle();
      expect(controller.busy, isTrue);
      await expectLater(controller.signInWithGoogle(), throwsStateError);
      expect(repository.calls, 1);
      controller.dispose();
      repository.completion.completeError(
        const IdentityFailure(IdentityIssue.cancelled),
      );
      await expectLater(pending, throwsA(isA<IdentityFailure>()));
      expect(controller.busy, isFalse);
      expect(
        FirebaseIdentityRepository.failureForCode('popup-blocked').issue,
        IdentityIssue.popupBlocked,
      );
      expect(
        FirebaseIdentityRepository.failureForCode(
          'account-exists-with-different-credential',
        ).issue,
        IdentityIssue.accountConflict,
      );
    },
  );
  for (final width in [375.0, 1440.0]) {
    testWidgets(
      'guest keeps expanded form through login and explicit save at $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final identity = FakeIdentity()..profile = storedProfile;
        final drafts = FakeDraftRepository();
        addTearDown(identity.events.close);
        await mount(tester, identity, drafts);
        expect(find.byType(HomeScreen), findsOneWidget);
        expect(drafts.loads, 0);
        await beginGuest(tester);
        expect(find.textContaining('Facebook'), findsNothing);
        expect(drafts.loads, 0);
        expect(drafts.saves, 0);
        await press(tester, 'Usa tu correo electrónico');
        await tester.enterText(
          find.byKey(const ValueKey('email')),
          'test@example.com',
        );
        await tester.enterText(
          find.byKey(const ValueKey('password')),
          'Test-only-123',
        );
        await press(tester, 'CONTINUAR');
        expect(find.byType(DraftRequestScreen), findsOneWidget);
        expect(find.text('Motivo ficticio visitante'), findsOneWidget);
        expect(find.text('Evolución ficticia'), findsOneWidget);
        expect(find.text('Pregunta ficticia'), findsOneWidget);
        expect(drafts.saves, 0);
        final acceptance = find.byType(Checkbox);
        await tester.ensureVisible(acceptance);
        await tester.tap(acceptance);
        await tester.pumpAndSettle();
        await press(tester, 'GUARDAR BORRADOR');
        expect(drafts.saves, 1);
        expect(
          drafts.record!.content.clinicalContext.questions,
          'Pregunta ficticia',
        );
        expect(
          drafts.record!.content.clinicalContext.symptomEvolution,
          'Evolución ficticia',
        );
        Navigator.of(tester.element(find.byType(DraftRequestScreen))).pop();
        await tester.pumpAndSettle();
        expect(find.byType(HomeScreen), findsOneWidget);
        expect(find.text('Borrador · Sin enviar'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'registration and verification resume guest content, never auto-save',
    (tester) async {
      final identity = FakeIdentity();
      final drafts = FakeDraftRepository();
      addTearDown(identity.events.close);
      await mount(tester, identity, drafts);
      await beginGuest(tester);
      await press(tester, 'Crear cuenta');
      for (final entry in {
        'email': 'test@example.com',
        'firstName': 'Prueba',
        'lastName': 'Ficticia',
        'password': 'Test-only-123',
        'repeatPassword': 'Test-only-123',
      }.entries) {
        final field = find.byKey(ValueKey(entry.key));
        await tester.ensureVisible(field);
        await tester.enterText(field, entry.value);
      }
      await tester.ensureVisible(find.byType(Checkbox));
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      await press(tester, 'CONTINUAR');
      expect(identity.registrations, 1);
      expect(find.byType(VerificationScreen), findsOneWidget);
      expect(drafts.loads, 0);
      identity.emit(verified);
      await tester.pumpAndSettle();
      expect(find.byType(DraftRequestScreen), findsOneWidget);
      expect(find.text('Pregunta ficticia'), findsOneWidget);
      expect(drafts.saves, 0);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'existing saved draft requires a choice before applying guest content',
    (tester) async {
      final identity = FakeIdentity()..profile = storedProfile;
      final drafts = FakeDraftRepository()
        ..record = SavedConsultationDraft(
          id: 'DraftAbCdEfGhIjKl123',
          revision: 4,
          updatedAt: DateTime.utc(2026, 9, 8),
          content: const ConsultationDraft(
            countryCode: 'CL',
            reason: 'Guardado ficticio',
            details: 'Existente',
          ),
        );
      addTearDown(identity.events.close);
      await mount(tester, identity, drafts);
      await beginGuest(tester);
      await press(tester, 'Usa tu correo electrónico');
      await tester.enterText(
        find.byKey(const ValueKey('email')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const ValueKey('password')),
        'Test-only-123',
      );
      await press(tester, 'CONTINUAR');
      expect(find.text('Ya tienes un borrador guardado'), findsOneWidget);
      expect(drafts.saves, 0);
      await press(tester, 'REVISAR NUEVO');
      expect(find.text('Motivo ficticio visitante'), findsOneWidget);
      expect(drafts.record!.revision, 4);
      expect(drafts.record!.content.reason, 'Guardado ficticio');
      await press(tester, 'GUARDAR BORRADOR');
      expect(drafts.record!.revision, 5);
      expect(drafts.record!.content.reason, 'Motivo ficticio visitante');
      expect(tester.takeException(), isNull);
    },
  );
}
