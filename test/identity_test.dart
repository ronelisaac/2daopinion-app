import 'dart:async';
import 'helpers/fake_draft_repository.dart';
import 'package:segunda_opinion_app/views/draft_request_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:segunda_opinion_app/connected_app.dart';
import 'package:segunda_opinion_app/controllers/account_controller.dart';
import 'package:segunda_opinion_app/controllers/profile_controller.dart';
import 'package:segunda_opinion_app/controllers/password_reset_controller.dart';
import 'package:segunda_opinion_app/controllers/session_controller.dart';
import 'package:segunda_opinion_app/domain/account_draft.dart';
import 'package:segunda_opinion_app/domain/identity.dart';
import 'package:segunda_opinion_app/domain/operation_result.dart';
import 'package:segunda_opinion_app/domain/repositories/account_repository.dart';
import 'package:segunda_opinion_app/domain/repositories/identity_repository.dart';
import 'package:segunda_opinion_app/views/home_screen.dart';
import 'package:segunda_opinion_app/views/profile_screen.dart';
import 'package:segunda_opinion_app/views/verification_screen.dart';

const verified = IdentityUser(
  authUserId: 'patient',
  email: 'test@example.com',
  emailVerified: true,
);
const unverified = IdentityUser(
  authUserId: 'patient',
  email: 'test@example.com',
  emailVerified: false,
);
const storedProfile = PatientProfile(
  id: 'portable-id',
  authUserId: 'patient',
  firstName: 'Prueba',
  lastName: 'Ficticia',
  countryCode: 'CL',
  locale: 'es',
  policyVersion: developmentPolicyVersion,
);

class FakeIdentity implements IdentityRepository, AccountRepository {
  int googleSignIns = 0;
  @override
  Future<OperationResult> signInWithGoogle() async {
    googleSignIns++;
    return OperationResult.completed;
  }

  final events = StreamController<IdentityUser?>.broadcast();
  IdentityUser? current;
  PatientProfile? profile;
  Completer<PatientProfile?>? pendingProfile;
  Completer<IdentityUser?>? pendingRefresh;
  bool failLoad = false;
  bool failSave = false;
  int registrations = 0;
  int saves = 0;
  int verifications = 0;
  String? resetEmail;
  String? savedFirstName;
  @override
  Stream<IdentityUser?> watchIdentity() async* {
    yield current;
    yield* events.stream;
  }

  void emit(IdentityUser? identity) {
    current = identity;
    events.add(identity);
  }

  @override
  Future<IdentityUser?> refreshIdentity() async =>
      pendingRefresh == null ? current : pendingRefresh!.future;
  @override
  Future<PatientProfile?> loadProfile(String authUserId) async {
    if (failLoad) throw const IdentityFailure(IdentityIssue.network);
    return pendingProfile == null ? profile : pendingProfile!.future;
  }

  @override
  Future<void> saveProfile({
    required String firstName,
    required String lastName,
    required bool acceptDevelopmentTerms,
  }) async {
    saves++;
    if (failSave) throw const IdentityFailure(IdentityIssue.network);
    savedFirstName = firstName;
    profile = storedProfile;
  }

  @override
  Future<OperationResult> createAccount(AccountDraft account) async {
    registrations++;
    emit(unverified);
    profile = storedProfile;
    return OperationResult.completed;
  }

  @override
  Future<OperationResult> signIn(AccountDraft account) async {
    emit(verified);
    return OperationResult.completed;
  }

  @override
  Future<void> sendVerification() async {
    verifications++;
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    resetEmail = email;
  }

  @override
  Future<void> signOut() async {
    emit(null);
  }
}

Future<void> flush() => Future<void>.delayed(Duration.zero);
AccountDraft draft([String? policy]) => AccountDraft(
  email: 'test@example.com',
  password: 'Test-only-123',
  passwordConfirmation: 'Test-only-123',
  firstName: 'Prueba',
  lastName: 'Ficticia',
  acceptedPolicyVersion: policy,
);

void main() {
  test(
    'registration requires current explicit acceptance before any write',
    () async {
      final repository = FakeIdentity();
      final controller = AccountController(
        repository,
        requiredPolicyVersion: developmentPolicyVersion,
      )..setRegistering(true);
      addTearDown(controller.dispose);
      addTearDown(repository.events.close);
      for (final policy in [null, 'obsolete']) {
        await expectLater(
          controller.submit(draft(policy)),
          throwsA(isA<IdentityFailure>()),
        );
      }
      expect(repository.registrations, 0);
      expect(controller.busy, false);
      expect(
        await controller.submit(draft(developmentPolicyVersion)),
        OperationResult.completed,
      );
      expect(repository.registrations, 1);
    },
  );

  test(
    'profile completion validates terms and names, trims and recovers from errors',
    () async {
      final repository = FakeIdentity();
      final controller = ProfileController(repository);
      addTearDown(controller.dispose);
      addTearDown(repository.events.close);
      expect(controller.validName(' '), false);
      expect(controller.validName('x' * 81), false);
      await expectLater(
        controller.save(
          firstName: 'Test',
          lastName: 'User',
          acceptTerms: false,
          completing: true,
        ),
        throwsA(isA<IdentityFailure>()),
      );
      expect(repository.saves, 0);
      repository.failSave = true;
      await expectLater(
        controller.save(
          firstName: ' Test ',
          lastName: 'User',
          acceptTerms: true,
          completing: true,
        ),
        throwsA(isA<IdentityFailure>()),
      );
      expect(controller.busy, false);
      repository.failSave = false;
      await controller.save(
        firstName: ' Test ',
        lastName: 'User',
        acceptTerms: true,
        completing: true,
      );
      expect(repository.savedFirstName, 'Test');
    },
  );

  test(
    'session restores profile, requires verification and clears on logout',
    () async {
      final repository = FakeIdentity()
        ..current = unverified
        ..profile = storedProfile;
      final controller = SessionController(repository, initialize: () async {});
      addTearDown(controller.dispose);
      addTearDown(repository.events.close);
      await controller.start();
      await flush();
      expect(controller.status, SessionStatus.unverified);
      await controller.sendVerification();
      expect(repository.verifications, 1);
      repository.emit(verified);
      await flush();
      expect(controller.status, SessionStatus.ready);
      expect(controller.profile?.id, 'portable-id');
      await controller.signOut();
      await flush();
      expect(controller.status, SessionStatus.signedOut);
      expect(controller.profile, isNull);
      expect(controller.navigationEpoch, 1);
    },
  );

  test(
    'missing profile resumes completion and server errors fail closed',
    () async {
      final repository = FakeIdentity()..current = verified;
      final controller = SessionController(repository, initialize: () async {});
      addTearDown(controller.dispose);
      addTearDown(repository.events.close);
      await controller.start();
      await flush();
      expect(controller.status, SessionStatus.incomplete);
      repository.failLoad = true;
      await controller.refresh();
      expect(controller.status, SessionStatus.failed);
      expect(controller.profile, isNull);
      repository.failLoad = false;
      repository.profile = storedProfile;
      await controller.refresh();
      expect(controller.status, SessionStatus.ready);
    },
  );

  test('late profile cannot restore a logged out session', () async {
    final pending = Completer<PatientProfile?>();
    final repository = FakeIdentity()
      ..current = verified
      ..pendingProfile = pending;
    final controller = SessionController(repository, initialize: () async {});
    addTearDown(controller.dispose);
    addTearDown(repository.events.close);
    await controller.start();
    await flush();
    await controller.signOut();
    await flush();
    pending.complete(storedProfile);
    await flush();
    expect(controller.status, SessionStatus.signedOut);
    expect(controller.profile, isNull);
  });

  test('late refresh cannot restore a logged out session', () async {
    final repository = FakeIdentity()
      ..current = verified
      ..profile = storedProfile;
    final controller = SessionController(repository, initialize: () async {});
    addTearDown(controller.dispose);
    addTearDown(repository.events.close);
    await controller.start();
    await flush();
    repository.pendingRefresh = Completer<IdentityUser?>();
    final refresh = controller.refresh();
    await controller.signOut();
    await flush();
    repository.pendingRefresh!.complete(verified);
    await refresh;
    expect(controller.status, SessionStatus.signedOut);
    expect(controller.profile, isNull);
  });

  test('password reset validates and normalizes email', () async {
    final repository = FakeIdentity();
    final controller = PasswordResetController(repository);
    addTearDown(controller.dispose);
    addTearDown(repository.events.close);
    await expectLater(controller.submit('invalid'), throwsArgumentError);
    expect(repository.resetEmail, isNull);
    await controller.submit(' test@example.com ');
    expect(repository.resetEmail, 'test@example.com');
    expect(controller.sent, true);
    expect(controller.busy, false);
  });

  for (final width in [375.0, 1440.0]) {
    testWidgets('guarded profile and logout clear navigation at width $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final repository = FakeIdentity()
        ..current = verified
        ..profile = storedProfile;
      addTearDown(repository.events.close);
      await tester.pumpWidget(
        ConnectedApp(
          initialize: () async {},
          identityRepository: repository,
          accountRepository: repository,
          draftRepository: FakeDraftRepository(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
      Navigator.of(
        tester.element(find.byType(HomeScreen)),
      ).pushNamed('/profile');
      await tester.pumpAndSettle();
      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(find.text('Prueba'), findsOneWidget);
      await tester.tap(find.text('Cerrar sesión'));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(ProfileScreen), findsNothing);
      expect(
        Navigator.of(tester.element(find.byType(HomeScreen))).canPop(),
        false,
      );
      expect(repository.profile, storedProfile);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('draft fields and route disappear when identity signs out', (
    tester,
  ) async {
    final repository = FakeIdentity()
      ..current = verified
      ..profile = storedProfile;
    final drafts = FakeDraftRepository();
    addTearDown(repository.events.close);
    await tester.pumpWidget(
      ConnectedApp(
        initialize: () async {},
        identityRepository: repository,
        accountRepository: repository,
        draftRepository: drafts,
      ),
    );
    await tester.pumpAndSettle();
    expect(drafts.loads, 1);
    Navigator.of(tester.element(find.byType(HomeScreen))).pushNamed('/request');
    await tester.pumpAndSettle();
    expect(drafts.loads, 2);
    expect(find.byType(DraftRequestScreen), findsOneWidget);
    await tester.enterText(
      find.byType(TextFormField).first,
      'Texto ficticio no guardado',
    );
    repository.emit(null);
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Texto ficticio no guardado'), findsNothing);
    expect(find.byType(DraftRequestScreen), findsNothing);
    expect(find.byKey(const ValueKey('draftOverview')), findsNothing);
    expect(drafts.saves, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'preview overview is explicitly fictional and never loads drafts',
    (tester) async {
      final repository = FakeIdentity();
      final drafts = FakeDraftRepository();
      addTearDown(repository.events.close);
      await tester.pumpWidget(
        ConnectedApp(
          initialize: () async {},
          identityRepository: repository,
          accountRepository: repository,
          draftRepository: drafts,
        ),
      );
      await tester.pumpAndSettle();
      Navigator.of(
        tester.element(find.byType(HomeScreen)),
      ).pushNamed('/preview');
      await tester.pumpAndSettle();
      expect(find.text('Ejemplo de solicitud en preparación'), findsOneWidget);
      expect(
        find.textContaining('No corresponde a una solicitud real'),
        findsOneWidget,
      );
      final example = find.text('VER FORMULARIO DE EJEMPLO');
      await tester.ensureVisible(example);
      await tester.pumpAndSettle();
      await tester.tap(example);
      await tester.pumpAndSettle();
      expect(find.byType(TextFormField), findsWidgets);
      expect(find.byType(DraftRequestScreen), findsNothing);
      expect(drafts.loads, 0);
      expect(drafts.saves, 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('unverified identity cannot open private home', (tester) async {
    final repository = FakeIdentity()
      ..current = unverified
      ..profile = storedProfile;
    addTearDown(repository.events.close);
    await tester.pumpWidget(
      ConnectedApp(
        initialize: () async {},
        identityRepository: repository,
        accountRepository: repository,
        draftRepository: FakeDraftRepository(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(VerificationScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
