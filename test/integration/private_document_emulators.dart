import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:firebase_auth_web/firebase_auth_web.dart';
import 'package:cloud_firestore_web/cloud_firestore_web.dart';
import 'package:firebase_storage_web/firebase_storage_web.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:segunda_opinion_app/repositories/firebase_consultation_draft_repository.dart';
import 'package:segunda_opinion_app/repositories/firebase_private_document_repository.dart';
import 'package:segunda_opinion_app/domain/consultation_draft.dart';
import 'package:segunda_opinion_app/domain/pending_document.dart';
import 'package:segunda_opinion_app/domain/private_document.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FirebaseCoreWeb.registerWith(webPluginRegistrar);
  FirebaseAuthWeb.registerWith(webPluginRegistrar);
  FirebaseFirestoreWeb.registerWith(webPluginRegistrar);
  FirebaseStorageWeb.registerWith(webPluginRegistrar);
  webPluginRegistrar.registerMessageHandler();
  test(
    'real Flutter adapters reserve, upload, retry, reload, read, delete and deny signed out',
    () async {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'demo-key',
          appId: '1:123456789:web:demo',
          messagingSenderId: '123456789',
          projectId: 'demo-2daopinion',
          storageBucket: 'demo-2daopinion.appspot.com',
        ),
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw TimeoutException('Firebase initialization did not complete');
        },
      );
      final auth = FirebaseAuth.instance;
      final database = FirebaseFirestore.instance;
      final storage = FirebaseStorage.instance;
      await auth.useAuthEmulator('127.0.0.1', 9099);
      database.useFirestoreEmulator('127.0.0.1', 8080);
      database.settings = const Settings(persistenceEnabled: false);
      await storage.useStorageEmulator('127.0.0.1', 9199);
      final credential = await auth.createUserWithEmailAndPassword(
        email: 'storage-${DateTime.now().microsecondsSinceEpoch}@example.test',
        password: 'Fictitious-test-only-872!',
      );
      final uid = credential.user!.uid;
      final verification = await http.post(
        Uri.parse(
          'http://127.0.0.1:9099/identitytoolkit.googleapis.com/v1/accounts:update',
        ),
        headers: {
          'Authorization': 'Bearer owner',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'localId': uid, 'emailVerified': true}),
      );
      expect(verification.statusCode, 200);
      await auth.currentUser!.reload();
      await auth.currentUser!.getIdToken(true);
      final profileBatch = database.batch();
      final profile = database.collection('profiles').doc(uid);
      profileBatch.set(profile, {
        'id': 'AbCdEfGhIjKlMnOpQrSt',
        'authUserId': uid,
        'firstName': 'Prueba',
        'lastName': 'Ficticia',
        'countryCode': 'CL',
        'locale': 'es',
        'policyVersion': 'dev-access-2026-09-08',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      profileBatch
          .set(profile.collection('consents').doc('dev-access-2026-09-08'), {
            'authUserId': uid,
            'policyVersion': 'dev-access-2026-09-08',
            'context': 'development-registration',
            'accepted': true,
            'acceptedAt': FieldValue.serverTimestamp(),
          });
      await profileBatch.commit();
      final drafts = FirebaseConsultationDraftRepository(
        auth: () => auth,
        database: () => database,
      );
      final draft = await drafts.save(
        const ConsultationDraft(
          countryCode: 'CL',
          reason: 'Ficticio',
          details: '',
        ),
        expectedRevision: 0,
        acceptStorageTerms: true,
      );
      final repository = FirebasePrivateDocumentRepository(
        auth: () => auth,
        database: () => database,
        storage: () => storage,
      );
      final sample = PendingDocument(
        title: 'Informe ficticio',
        fileName: 'ficticio.pdf',
        bytes: Uint8List.fromList(
          utf8.encode('%PDF-1.4\nFictitious test only\n%%EOF'),
        ),
      );
      final uploaded = await repository.upload(
        draft.id,
        sample,
        accepted: true,
        cancellation: TransferCancellation(),
        onProgress: (_) {},
      );
      expect(uploaded.state, PrivateDocumentState.stored);
      expect(await repository.read(draft.id, uploaded.id), sample.bytes);
      final retried = await repository.upload(
        draft.id,
        sample,
        accepted: true,
        cancellation: TransferCancellation(),
        onProgress: (_) {},
      );
      expect(retried.id, uploaded.id);
      expect((await repository.list(draft.id)).length, 1);
      expect(
        (await database.collection('draftAttachments').doc(uid).get())
            .data()!['count'],
        1,
      );
      await repository.delete(draft.id, uploaded.id);
      expect(
        (await repository.list(draft.id)).single.state,
        PrivateDocumentState.missing,
      );
      await repository.upload(
        draft.id,
        sample,
        accepted: true,
        cancellation: TransferCancellation(),
        onProgress: (_) {},
      );
      expect(
        (await repository.list(draft.id)).single.state,
        PrivateDocumentState.stored,
      );
      await auth.signOut();
      await expectLater(
        repository.list(draft.id),
        throwsA(isA<DocumentFailure>()),
      );
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
