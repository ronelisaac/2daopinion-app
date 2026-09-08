import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:segunda_opinion_app/domain/patient_notice.dart';
import 'package:segunda_opinion_app/domain/repositories/notice_repository.dart';
import 'package:segunda_opinion_app/controllers/notices_controller.dart';
import 'package:segunda_opinion_app/views/notices_screen.dart';
import 'package:segunda_opinion_app/views/home_screen.dart';
import 'package:segunda_opinion_app/connected_app.dart';
import 'package:segunda_opinion_app/widgets/notice_bell.dart';
import 'package:segunda_opinion_app/repositories/preview_notice_repository.dart';
import 'consultation_steps_test.dart' show app;
import 'identity_test.dart' show FakeIdentity, storedProfile, verified;
import 'helpers/fake_draft_repository.dart';

PatientNotice notice(String id) => PatientNotice(
  id: id * 64,
  kind: NoticeKind.welcome,
  createdAt: DateTime.utc(2026, 9, 8),
  isRead: false,
);

class FakeNotices implements NoticeRepository {
  List<PatientNotice> items = [notice('a')];
  int pages = 0;
  int writes = 0;
  NoticeIssue? failure;
  bool failWrite = false;
  Completer<NoticePage>? pending;
  NoticeCursor? next;
  @override
  Future<NoticePage> page({NoticeCursor? after}) async {
    pages++;
    if (failure != null) throw NoticeFailure(failure!);
    return pending == null ? NoticePage(items, next: next) : pending!.future;
  }

  @override
  Future<int> unreadCount() async {
    if (failure != null) throw NoticeFailure(failure!);
    return items.where((item) => !item.isRead).length;
  }

  @override
  Future<void> setRead(String id, bool isRead) async {
    writes++;
    if (failWrite) throw const NoticeFailure(NoticeIssue.unavailable);
    items = items
        .map((item) => item.id == id ? item.withRead(isRead) : item)
        .toList();
  }
}

void main() {
  test(
    'read state changes only after confirmation; failures never show false success',
    () async {
      final repository = FakeNotices();
      final controller = NoticesController(repository);
      addTearDown(controller.dispose);
      await controller.load();
      expect(controller.unread, 1);
      repository.failWrite = true;
      await controller.setRead(controller.items.single, true);
      expect(controller.items.single.isRead, isFalse);
      expect(controller.unread, isNull);
      repository.failWrite = false;
      await controller.setRead(controller.items.single, true);
      expect(controller.items.single.isRead, isTrue);
      expect(controller.unread, 0);
      await controller.setRead(controller.items.single, false);
      expect(controller.unread, 1);
    },
  );
  test(
    'pagination deduplicates IDs and failed refresh preserves rows but not a stale count',
    () async {
      final repository = FakeNotices()
        ..next = const NoticeCursor(
          ownerId: 'patient',
          timestampSeconds: 1,
          timestampNanoseconds: 1,
          id: 'cursor',
        );
      final controller = NoticesController(repository);
      addTearDown(controller.dispose);
      await controller.load();
      repository.items = [notice('a'), notice('b')];
      repository.next = null;
      await controller.load(more: true);
      expect(controller.items.length, 2);
      expect(controller.hasMore, isFalse);
      repository.failure = NoticeIssue.unavailable;
      await controller.load();
      expect(controller.items.length, 2);
      expect(controller.unread, isNull);
      repository.failure = NoticeIssue.session;
      await controller.load();
      expect(controller.items, isEmpty);
    },
  );
  test(
    'dispose ignores pending data and repeated actions while loading',
    () async {
      final repository = FakeNotices()..pending = Completer<NoticePage>();
      final controller = NoticesController(repository);
      final loading = controller.load();
      await controller.load();
      expect(repository.pages, 1);
      controller.dispose();
      repository.pending!.complete(NoticePage([notice('a')]));
      await loading;
      expect(controller.items, isEmpty);
      expect(controller.unread, isNull);
    },
  );
  testWidgets('disabled environment does not pretend there are zero messages', (
    tester,
  ) async {
    await tester.pumpWidget(app(const NoticesScreen()));
    expect(find.textContaining('aún no están habilitados'), findsOneWidget);
    expect(find.text('No hay avisos para mostrar.'), findsNothing);
  });
  testWidgets('empty and failed states are distinct', (tester) async {
    final repository = FakeNotices()..items = [];
    final controller = NoticesController(repository);
    await tester.pumpWidget(
      app(NoticesScreen(createController: () => controller)),
    );
    await tester.pumpAndSettle();
    expect(find.text('No hay avisos para mostrar.'), findsOneWidget);
    repository.failure = NoticeIssue.unavailable;
    await controller.load();
    await tester.pumpAndSettle();
    expect(find.text('No hay avisos para mostrar.'), findsNothing);
    expect(find.textContaining('No pudimos confirmar'), findsOneWidget);
  });
  testWidgets('badge caps at 99+ and never shows a false count on error', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(Scaffold(body: NoticeBell(onPressed: () {}, unread: 100))),
    );
    expect(find.text('99+'), findsOneWidget);
    await tester.pumpWidget(app(Scaffold(body: NoticeBell(onPressed: () {}))));
    expect(tester.widget<Badge>(find.byType(Badge)).isLabelVisible, isFalse);
  });
  for (final width in [320.0, 1440.0]) {
    testWidgets('preview is explicit and read toggle works at $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        app(
          NoticesScreen(
            preview: true,
            createController: () =>
                NoticesController(PreviewNoticeRepository()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('EJEMPLO ·'), findsOneWidget);
      expect(find.text('2 sin leer'), findsOneWidget);
      await tester.ensureVisible(find.text('MARCAR COMO LEÍDO').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('MARCAR COMO LEÍDO').first);
      await tester.pumpAndSettle();
      expect(find.text('1 sin leer'), findsOneWidget);
      expect(find.text('MARCAR COMO NO LEÍDO'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('route rebuild keeps the loaded controller and read state', (
    tester,
  ) async {
    var created = 0;
    Widget screen() => app(
      NoticesScreen(
        preview: true,
        createController: () {
          created++;
          return NoticesController(PreviewNoticeRepository());
        },
      ),
    );
    await tester.pumpWidget(screen());
    await tester.pumpAndSettle();
    await tester.tap(find.text('MARCAR COMO LEÍDO').first);
    await tester.pumpAndSettle();
    await tester.pumpWidget(screen());
    await tester.pumpAndSettle();
    expect(created, 1);
    expect(find.text('1 sin leer'), findsOneWidget);
    expect(find.text('MARCAR COMO NO LEÍDO'), findsOneWidget);
  });
  testWidgets(
    'guest cannot enter private notices; session change removes existing notice view',
    (tester) async {
      final identity = FakeIdentity();
      addTearDown(identity.events.close);
      final notices = FakeNotices();
      await tester.pumpWidget(
        ConnectedApp(
          initialize: () async {},
          identityRepository: identity,
          accountRepository: identity,
          draftRepository: FakeDraftRepository(),
          noticeRepository: notices,
        ),
      );
      await tester.pumpAndSettle();
      Navigator.of(
        tester.element(find.byType(HomeScreen)),
      ).pushNamed('/notifications');
      await tester.pumpAndSettle();
      expect(find.byType(NoticesScreen), findsNothing);
      expect(notices.pages, 0);
      identity.profile = storedProfile;
      identity.emit(verified);
      await tester.pumpAndSettle();
      expect(find.byType(NoticesScreen), findsOneWidget);
      identity.emit(null);
      await tester.pumpAndSettle();
      expect(find.byType(NoticesScreen), findsNothing);
      expect(find.text('Conoce tu espacio personal'), findsNothing);
    },
  );
}
