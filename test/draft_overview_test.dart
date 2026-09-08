import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:segunda_opinion_app/controllers/draft_overview_controller.dart';
import 'package:segunda_opinion_app/core/app_theme.dart';
import 'package:segunda_opinion_app/domain/consultation_draft.dart';
import 'package:segunda_opinion_app/domain/saved_consultation_draft.dart';
import 'package:segunda_opinion_app/l10n/app_localizations.dart';
import 'package:segunda_opinion_app/views/patient_home_screen.dart';
import 'package:segunda_opinion_app/widgets/draft_overview_card.dart';
import 'package:segunda_opinion_app/widgets/informational_footer.dart';
import 'helpers/fake_draft_repository.dart';

final savedDraft = SavedConsultationDraft(
  id: 'DraftAbCdEfGhIjKl123',
  revision: 1,
  content: const ConsultationDraft(
    countryCode: 'CL',
    reason: 'Motivo ficticio privado',
    details: 'Detalles ficticios privados',
  ),
  updatedAt: DateTime.utc(2026, 9, 8),
);

class PendingDraftRepository extends FakeDraftRepository {
  final requests = <Completer<SavedConsultationDraft?>>[];
  @override
  Future<SavedConsultationDraft?> load() {
    final request = Completer<SavedConsultationDraft?>();
    requests.add(request);
    return request.future;
  }
}

Widget homeApp(
  DraftOverviewController controller,
  FakeDraftRepository repository, {
  double scale = 1,
}) => MaterialApp(
  theme: buildAppTheme(),
  locale: const Locale('es'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: child!,
  ),
  home: PatientHomeScreen(controller: controller, onSignOut: () {}),
  routes: {
    '/request': (context) => Scaffold(
      body: TextButton(
        onPressed: () {
          repository.record = savedDraft;
          Navigator.pop(context);
        },
        child: const Text('Guardar ejemplo y volver'),
      ),
    ),
  },
);

void main() {
  test(
    'overview distinguishes empty, saved and failed reads without stale data',
    () async {
      final repository = FakeDraftRepository();
      final controller = DraftOverviewController(repository);
      addTearDown(controller.dispose);
      expect(controller.status, DraftOverviewStatus.loading);
      await controller.load();
      expect(controller.status, DraftOverviewStatus.empty);
      repository.record = savedDraft;
      await controller.load();
      expect(controller.status, DraftOverviewStatus.ready);
      expect(controller.overview!.updatedAt, savedDraft.updatedAt);
      expect(controller.overview!.hasRequiredDetails, isTrue);
      repository.failure = DraftIssue.unavailable;
      await controller.load();
      expect(controller.status, DraftOverviewStatus.failed);
      expect(controller.overview, isNull);
    },
  );

  test('older response cannot replace newer overview', () async {
    final repository = PendingDraftRepository();
    final controller = DraftOverviewController(repository);
    addTearDown(controller.dispose);
    final firstLoad = controller.load();
    final secondLoad = controller.load();
    repository.requests[1].complete(null);
    await secondLoad;
    repository.requests[0].complete(savedDraft);
    await firstLoad;
    expect(controller.status, DraftOverviewStatus.empty);
    expect(controller.overview, isNull);
  });

  test(
    'disposed overview ignores pending response and further loads',
    () async {
      final repository = PendingDraftRepository();
      final controller = DraftOverviewController(repository);
      final loading = controller.load();
      controller.dispose();
      repository.requests.single.complete(savedDraft);
      await loading;
      await controller.load();
      expect(repository.requests.length, 1);
      expect(controller.overview, isNull);
    },
  );

  testWidgets('loading and failure do not masquerade as an empty draft', (
    tester,
  ) async {
    final repository = PendingDraftRepository();
    final controller = DraftOverviewController(repository);
    await tester.pumpWidget(homeApp(controller, repository));
    await tester.pump();
    expect(find.text('Consultando tu borrador guardado…'), findsOneWidget);
    expect(find.text('Aún no tienes un borrador guardado'), findsNothing);
    repository.requests.single.completeError(
      const DraftFailure(DraftIssue.permission),
    );
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Esto no significa que no exista'),
      findsOneWidget,
    );
    expect(find.text('Aún no tienes un borrador guardado'), findsNothing);
    final retry = find.widgetWithText(OutlinedButton, 'REINTENTAR');
    await tester.ensureVisible(retry);
    await tester.tap(retry);
    await tester.pump();
    repository.requests.last.complete(null);
    await tester.pumpAndSettle();
    expect(find.text('Aún no tienes un borrador guardado'), findsOneWidget);
  });

  for (final width in [375.0, 1440.0]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets(
        'home resumes and refreshes draft at width $width and scale $scale',
        (tester) async {
          tester.view.physicalSize = Size(width, 900);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          final repository = FakeDraftRepository();
          final controller = DraftOverviewController(repository);
          await tester.pumpWidget(
            homeApp(controller, repository, scale: scale),
          );
          await tester.pumpAndSettle();
          expect(repository.loads, 1);
          final start = find.text('PREPARAR BORRADOR');
          await tester.ensureVisible(start);
          await tester.pumpAndSettle();
          await tester.tap(start);
          await tester.pumpAndSettle();
          await tester.tap(find.text('Guardar ejemplo y volver'));
          await tester.pumpAndSettle();
          expect(repository.loads, 2);
          expect(find.text('Borrador · Sin enviar'), findsOneWidget);
          expect(find.text(savedDraft.content.reason), findsNothing);
          expect(find.text(savedDraft.content.details), findsNothing);
          expect(
            find.text(
              'Motivo y detalles completados. Puedes seguir revisándolos.',
            ),
            findsOneWidget,
          );
          final resume = find.text('RETOMAR BORRADOR');
          await tester.ensureVisible(resume);
          await tester.pumpAndSettle();
          expect(
            tester.getRect(resume).bottom,
            lessThanOrEqualTo(
              tester.getRect(find.byType(InformationalFooter)).top,
            ),
          );
          await tester.tap(resume);
          await tester.pumpAndSettle();
          expect(find.text('Guardar ejemplo y volver'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('service entry and manual refresh use the same saved overview', (
    tester,
  ) async {
    final repository = FakeDraftRepository();
    final controller = DraftOverviewController(repository);
    await tester.pumpWidget(homeApp(controller, repository));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Crea o retoma tu borrador de prueba'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar ejemplo y volver'));
    await tester.pumpAndSettle();
    expect(repository.loads, 2);
    repository.record = null;
    final refresh = find.byTooltip('Actualizar resumen');
    await tester.ensureVisible(refresh);
    await tester.pumpAndSettle();
    await tester.tap(refresh);
    await tester.pumpAndSettle();
    expect(repository.loads, 3);
    expect(find.text('Aún no tienes un borrador guardado'), findsOneWidget);
    expect(find.byType(DraftOverviewCard), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
