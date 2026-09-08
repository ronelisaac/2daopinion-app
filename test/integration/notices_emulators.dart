import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_web/firebase_auth_web.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_web/cloud_firestore_web.dart';
import 'package:http/http.dart' as http;
import 'package:segunda_opinion_app/domain/patient_notice.dart';
import 'package:segunda_opinion_app/repositories/firebase_notice_repository.dart';

Future<String> verifiedFixture(FirebaseAuth auth) async {
  final account = await auth.createUserWithEmailAndPassword(
    email: 'notice-${DateTime.now().microsecondsSinceEpoch}@example.test',
    password: 'Fictitious-Notice-938!',
  );
  final uid = account.user!.uid;
  final response = await http.post(
    Uri.parse(
      'http://127.0.0.1:9099/identitytoolkit.googleapis.com/v1/accounts:update',
    ),
    headers: {
      'Authorization': 'Bearer owner',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'localId': uid, 'emailVerified': true}),
  );
  expect(response.statusCode, 200);
  await auth.currentUser!.reload();
  await auth.currentUser!.getIdToken(true);
  return uid;
}

Future<void> seed(String uid, Iterable<int> indices) async {
  const base = 'projects/demo-2daopinion/databases/(default)/documents';
  final response = await http.post(
    Uri.parse('http://127.0.0.1:8080/v1/$base:commit'),
    headers: {
      'Authorization': 'Bearer owner',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'writes': [
        {
          'update': {
            'name': '$base/profiles/$uid',
            'fields': {
              'id': {'stringValue': 'fictitious-profile'},
              'countryCode': {'stringValue': 'CL'},
            },
          },
        },
        for (final index in indices)
          {
            'update': {
              'name':
                  '$base/patientNotices/$uid/items/${index.toRadixString(16).padLeft(64, '0')}',
              'fields': {
                'id': {'stringValue': index.toRadixString(16).padLeft(64, '0')},
                'recipientId': {'stringValue': uid},
                'schemaVersion': {'integerValue': '1'},
                'templateCode': {'stringValue': 'welcome'},
                'createdAt': {
                  'timestampValue': '2026-09-08T12:00:00.123456789Z',
                },
                'readAt': {'nullValue': null},
              },
            },
          },
      ],
    }),
  );
  expect(response.statusCode, 200);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FirebaseCoreWeb.registerWith(webPluginRegistrar);
  FirebaseAuthWeb.registerWith(webPluginRegistrar);
  FirebaseFirestoreWeb.registerWith(webPluginRegistrar);
  webPluginRegistrar.registerMessageHandler();
  test(
    'notices paginate precisely, persist read state, cap counts and isolate sessions',
    () async {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'demo-key',
          appId: '1:123456789:web:demo',
          messagingSenderId: '123456789',
          projectId: 'demo-2daopinion',
        ),
      );
      final auth = FirebaseAuth.instance;
      final database = FirebaseFirestore.instance;
      await auth.useAuthEmulator('127.0.0.1', 9099);
      database.useFirestoreEmulator('127.0.0.1', 8080);
      database.settings = const Settings(persistenceEnabled: false);
      final uid = await verifiedFixture(auth);
      await seed(uid, Iterable.generate(23, (index) => index + 1));
      final repository = FirebaseNoticeRepository(
        auth: () => auth,
        database: () => database,
      );
      expect(await repository.unreadCount(), 23);
      final first = await repository.page();
      expect(first.items.length, 20);
      expect(first.next!.timestampNanoseconds, 123456000);
      final second = await repository.page(after: first.next);
      expect(second.items.length, 3);
      expect(second.next, isNull);
      expect(
        {
          ...first.items.map((item) => item.id),
          ...second.items.map((item) => item.id),
        }.length,
        23,
      );
      final id = first.items.first.id;
      await repository.setRead(id, true);
      expect(await repository.unreadCount(), 22);
      final restored = FirebaseNoticeRepository(
        auth: () => auth,
        database: () => database,
      );
      expect((await restored.page()).items.first.isRead, isTrue);
      final reference = database
          .collection('patientNotices')
          .doc(uid)
          .collection('items')
          .doc(id);
      final readAt = (await reference.get()).data()!['readAt'];
      await restored.setRead(id, true);
      expect((await reference.get()).data()!['readAt'], readAt);
      await restored.setRead(id, false);
      expect(await restored.unreadCount(), 23);
      await seed(uid, Iterable.generate(80, (index) => index + 24));
      expect(await restored.unreadCount(), 100);
      await auth.signOut();
      await expectLater(restored.page(), throwsA(isA<NoticeFailure>()));
      final otherUid = await verifiedFixture(auth);
      await seed(otherUid, []);
      expect((await restored.page()).items, isEmpty);
      await expectLater(
        restored.page(after: first.next),
        throwsA(
          isA<NoticeFailure>().having(
            (error) => error.issue,
            'issue',
            NoticeIssue.session,
          ),
        ),
      );
      await expectLater(
        restored.setRead(id, true),
        throwsA(isA<NoticeFailure>()),
      );
      await auth.signOut();
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
