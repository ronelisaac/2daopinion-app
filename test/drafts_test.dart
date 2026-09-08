import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:segunda_opinion_app/controllers/consultation_draft_controller.dart';
import 'package:segunda_opinion_app/domain/consultation_draft.dart';
import 'package:segunda_opinion_app/domain/country_config.dart';
import 'package:segunda_opinion_app/domain/saved_consultation_draft.dart';
import 'package:segunda_opinion_app/core/app_theme.dart';
import 'package:segunda_opinion_app/l10n/app_localizations.dart';
import 'package:segunda_opinion_app/views/draft_request_screen.dart';
import 'helpers/fake_draft_repository.dart';

const empty = ConsultationDraft(countryCode: 'CL', reason: '', details: '');
const content = ConsultationDraft(
  countryCode: 'CL',
  reason: 'Prueba ficticia',
  details: '',
);
ConsultationDraftController controllerFor(FakeDraftRepository repository) =>
    ConsultationDraftController(repository, country: CountryConfig.chile);

void main() {
  test(
    'must load and accept separate storage terms before first save',
    () async {
      final repository = FakeDraftRepository();
      final controller = controllerFor(repository);
      addTearDown(controller.dispose);
      expect(await controller.save(empty, accepted: true), false);
      expect(repository.saves, 0);
      await controller.load();
      expect(await controller.save(empty, accepted: false), false);
      expect(controller.issue, DraftIssue.consent);
      expect(repository.saves, 0);
      expect(await controller.save(empty, accepted: true), true);
      expect(controller.saved!.revision, 1);
      expect(controller.saved!.content.isComplete, false);
      expect(await controller.save(content, accepted: false), true);
      expect(controller.saved!.revision, 2);
    },
  );
  test('failed load cannot overwrite an unknown existing draft', () async {
    final repository = FakeDraftRepository()..failure = DraftIssue.unavailable;
    final controller = controllerFor(repository);
    addTearDown(controller.dispose);
    expect(await controller.load(), false);
    expect(await controller.save(content, accepted: true), false);
    expect(repository.saves, 0);
    repository.failure = null;
    expect(await controller.load(), true);
  });
  test('limits and country are enforced before write', () async {
    final repository = FakeDraftRepository();
    final controller = controllerFor(repository);
    addTearDown(controller.dispose);
    await controller.load();
    expect(
      await controller.save(
        ConsultationDraft(countryCode: 'CL', reason: 'x' * 4001, details: ''),
        accepted: true,
      ),
      false,
    );
    expect(
      await controller.save(
        const ConsultationDraft(countryCode: 'AR', reason: '', details: ''),
        accepted: true,
      ),
      false,
    );
    expect(repository.saves, 0);
  });
  test('concurrent tabs do not overwrite another saved revision', () async {
    final repository = FakeDraftRepository();
    final first = controllerFor(repository);
    final second = controllerFor(repository);
    addTearDown(first.dispose);
    addTearDown(second.dispose);
    await first.load();
    await second.load();
    expect(await first.save(content, accepted: true), true);
    expect(await second.save(empty, accepted: true), false);
    expect(second.issue, DraftIssue.conflict);
    expect(repository.record!.content.reason, content.reason);
    await second.load();
    expect(second.saved!.revision, 1);
    expect(await second.save(empty, accepted: false), true);
    expect(await first.save(content, accepted: false), false);
    expect(repository.record!.revision, 2);
  });
  test(
    'network errors recover, duplicate saves and late disposal are safe',
    () async {
      final repository = FakeDraftRepository();
      final controller = controllerFor(repository);
      await controller.load();
      repository.failure = DraftIssue.unavailable;
      expect(await controller.save(content, accepted: true), false);
      expect(controller.busy, false);
      repository.failure = null;
      repository.pending = Completer<void>();
      final save = controller.save(content, accepted: true);
      expect(await controller.save(content, accepted: true), false);
      controller.dispose();
      repository.pending!.complete();
      expect(await save, false);
    },
  );

  testWidgets('leaving a dirty draft asks before discarding local text', (
    tester,
  ) async {
    final repository = FakeDraftRepository();
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.pushNamed(context, '/draft'),
              child: const Text('open'),
            ),
          ),
        ),
        routes: {
          '/draft': (_) =>
              DraftRequestScreen(controller: controllerFor(repository)),
        },
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Texto local');
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Volver'));
    await tester.pumpAndSettle();
    expect(find.text('Tienes cambios sin guardar'), findsOneWidget);
    await tester.tap(find.text('SEGUIR EDITANDO'));
    await tester.pumpAndSettle();
    expect(find.text('Texto local'), findsOneWidget);
    await tester.tap(find.byTooltip('Volver'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('DESCARTAR CAMBIOS LOCALES'));
    await tester.pumpAndSettle();
    expect(find.text('open'), findsOneWidget);
    expect(repository.saves, 0);
    expect(tester.takeException(), isNull);
  });

  for (final width in [375.0, 1440.0]) {
    testWidgets(
      'draft saves incomplete fields, restores and preserves failed edits at $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final repository = FakeDraftRepository();
        Future<void> open() async {
          await tester.pumpWidget(
            MaterialApp(
              theme: buildAppTheme(),
              locale: const Locale('es'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: DraftRequestScreen(controller: controllerFor(repository)),
            ),
          );
          await tester.pumpAndSettle();
        }

        await open();
        final reason = find.descendant(
          of: find.byKey(const ValueKey('draftReason')),
          matching: find.byType(TextFormField),
        );
        await tester.enterText(reason, 'Prueba ficticia');
        await tester.ensureVisible(find.text('GUARDAR BORRADOR'));
        await tester.tap(find.text('GUARDAR BORRADOR'));
        await tester.pumpAndSettle();
        expect(repository.saves, 0);
        expect(
          find.text(
            'Acepta las condiciones específicas del borrador antes de guardarlo por primera vez.',
          ),
          findsOneWidget,
        );
        await tester.ensureVisible(find.byKey(const ValueKey('draftConsent')));
        await tester.tap(find.byKey(const ValueKey('draftConsent')));
        await tester.ensureVisible(find.text('GUARDAR BORRADOR'));
        await tester.tap(find.text('GUARDAR BORRADOR'));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('draftSaved')), findsOneWidget);
        expect(repository.record!.content.reason, 'Prueba ficticia');
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
        await open();
        expect(find.text('Prueba ficticia'), findsOneWidget);
        expect(find.byKey(const ValueKey('draftConsent')), findsNothing);
        await tester.enterText(reason, 'Edición local');
        repository.failure = DraftIssue.unavailable;
        await tester.ensureVisible(find.text('GUARDAR BORRADOR'));
        await tester.tap(find.text('GUARDAR BORRADOR'));
        await tester.pumpAndSettle();
        expect(find.text('Edición local'), findsOneWidget);
        expect(find.byKey(const ValueKey('draftSaved')), findsNothing);
        expect(repository.record!.content.reason, 'Prueba ficticia');
        expect(tester.takeException(), isNull);
      },
    );
  }
}
