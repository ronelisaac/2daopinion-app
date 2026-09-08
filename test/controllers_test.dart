import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:segunda_opinion_app/controllers/account_controller.dart';
import 'package:segunda_opinion_app/controllers/consultation_controller.dart';
import 'package:segunda_opinion_app/domain/account_draft.dart';
import 'package:segunda_opinion_app/domain/consultation_draft.dart';
import 'package:segunda_opinion_app/domain/country_config.dart';
import 'package:segunda_opinion_app/domain/operation_result.dart';
import 'package:segunda_opinion_app/domain/repositories/account_repository.dart';
import 'package:segunda_opinion_app/domain/repositories/consultation_repository.dart';
import 'package:segunda_opinion_app/repositories/preview_account_repository.dart';

class RecordingAccountRepository implements AccountRepository {
  int signIns = 0;
  int registrations = 0;
  Completer<OperationResult>? pending;

  @override
  Future<OperationResult> createAccount(AccountDraft account) async {
    registrations++;
    return OperationResult.previewOnly;
  }

  @override
  Future<OperationResult> signIn(AccountDraft account) async {
    signIns++;
    return pending?.future ?? Future.value(OperationResult.previewOnly);
  }
}

class RecordingConsultationRepository implements ConsultationRepository {
  ConsultationDraft? received;
  bool fail = false;

  @override
  Future<OperationResult> submit(ConsultationDraft draft) async {
    received = draft;
    if (fail) throw StateError('Unavailable');
    return OperationResult.previewOnly;
  }
}

void main() {
  const account = AccountDraft(
    email: 'demo@example.com',
    password: 'password-demo',
    firstName: 'Demo',
    lastName: 'Paciente',
    passwordConfirmation: 'password-demo',
  );

  test('Account controller chooses the correct repository operation', () async {
    final repository = RecordingAccountRepository();
    final controller = AccountController(repository);
    addTearDown(controller.dispose);
    expect(await controller.submit(account), OperationResult.previewOnly);
    controller.setRegistering(true);
    await controller.submit(account);
    expect(repository.signIns, 1);
    expect(repository.registrations, 1);
    expect(controller.busy, isFalse);
  });

  test('Invalid account fields never reach the repository', () async {
    final repository = RecordingAccountRepository();
    final controller = AccountController(repository);
    addTearDown(controller.dispose);
    await expectLater(
      controller.submit(const AccountDraft(email: 'invalid', password: '')),
      throwsArgumentError,
    );
    expect(repository.signIns, 0);
  });

  test(
    'Duplicate submissions and mode changes are blocked while busy',
    () async {
      final repository = RecordingAccountRepository()
        ..pending = Completer<OperationResult>();
      final controller = AccountController(repository);
      addTearDown(controller.dispose);
      final first = controller.submit(account);
      expect(controller.busy, isTrue);
      controller.setRegistering(true);
      expect(controller.registering, isFalse);
      await expectLater(controller.submit(account), throwsStateError);
      repository.pending!.complete(OperationResult.previewOnly);
      await first;
      expect(repository.signIns, 1);
      expect(controller.busy, isFalse);
    },
  );

  test('An account operation may finish after its view is disposed', () async {
    final repository = RecordingAccountRepository()
      ..pending = Completer<OperationResult>();
    final controller = AccountController(repository);
    final operation = controller.submit(account);
    controller.dispose();
    repository.pending!.complete(OperationResult.previewOnly);
    expect(await operation, OperationResult.previewOnly);
  });

  test(
    'Preview account repository never reports authentication success',
    () async {
      const repository = PreviewAccountRepository();
      expect(await repository.signIn(account), OperationResult.previewOnly);
      expect(
        await repository.createAccount(account),
        OperationResult.previewOnly,
      );
    },
  );

  test(
    'Consultation controller normalizes fields and uses the selected country',
    () async {
      final repository = RecordingConsultationRepository();
      final controller = ConsultationController(
        repository,
        country: const CountryConfig(code: 'PE', currency: 'PEN'),
      );
      addTearDown(controller.dispose);
      expect(
        await controller.submit(
          reason: ' Example ',
          details: ' Details ',
          medicines: '',
          specialTreatments: '',
          previousProposals: '',
        ),
        OperationResult.previewOnly,
      );
      expect(repository.received!.countryCode, 'PE');
      expect(repository.received!.reason, 'Example');
      expect(repository.received!.details, 'Details');
    },
  );

  test('Invalid consultation does not reach the repository', () async {
    final repository = RecordingConsultationRepository();
    final controller = ConsultationController(
      repository,
      country: CountryConfig.chile,
    );
    addTearDown(controller.dispose);
    await expectLater(
      controller.submit(
        reason: ' ',
        details: 'Details',
        medicines: '',
        specialTreatments: '',
        previousProposals: '',
      ),
      throwsArgumentError,
    );
    expect(repository.received, isNull);
  });

  test('Repository errors restore the controller state', () async {
    final repository = RecordingConsultationRepository()..fail = true;
    final controller = ConsultationController(
      repository,
      country: CountryConfig.chile,
    );
    addTearDown(controller.dispose);
    await expectLater(
      controller.submit(
        reason: 'Example',
        details: 'Details',
        medicines: '',
        specialTreatments: '',
        previousProposals: '',
      ),
      throwsStateError,
    );
    expect(controller.busy, isFalse);
  });
}
