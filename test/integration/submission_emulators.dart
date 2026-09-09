import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:firebase_auth_web/firebase_auth_web.dart';
import 'package:cloud_firestore_web/cloud_firestore_web.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:segunda_opinion_app/repositories/firebase_consultation_draft_repository.dart';
import 'package:segunda_opinion_app/repositories/firebase_consultation_submission_repository.dart';
import 'package:segunda_opinion_app/domain/consultation_draft.dart';
import 'package:segunda_opinion_app/domain/clinical_context.dart';
import 'package:segunda_opinion_app/domain/consultation_submission.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FirebaseCoreWeb.registerWith(webPluginRegistrar);
  FirebaseAuthWeb.registerWith(webPluginRegistrar);
  FirebaseFirestoreWeb.registerWith(webPluginRegistrar);
  webPluginRegistrar.registerMessageHandler();
  test(
    'actual patient adapters save, reject stale version, submit once, restore receipt and deny signed-out',
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
      database.settings = const Settings(persistenceEnabled: false);
      database.useFirestoreEmulator('127.0.0.1', 8080);
      final credential = await auth.createUserWithEmailAndPassword(
        email:
            'submission-${DateTime.now().microsecondsSinceEpoch}@example.test',
        password: 'Test-only-Submission-391!',
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
      final batch = database.batch();
      final profile = database.collection('profiles').doc(uid);
      batch.set(profile, {
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
      batch.set(profile.collection('consents').doc('dev-access-2026-09-08'), {
        'authUserId': uid,
        'policyVersion': 'dev-access-2026-09-08',
        'context': 'development-registration',
        'accepted': true,
        'acceptedAt': FieldValue.serverTimestamp(),
      });
      await batch.commit();
      final drafts = FirebaseConsultationDraftRepository(
        auth: () => auth,
        database: () => database,
      );
      const content = ConsultationDraft(
        countryCode: 'CL',
        reason: 'Prueba ficticia',
        details: 'Contenido privado de prueba',
        clinicalContext: ClinicalContext(modality: 'document_review'),
      );
      final first = await drafts.save(
        content,
        expectedRevision: 0,
        acceptStorageTerms: true,
      );
      final current = await drafts.save(
        content,
        expectedRevision: 1,
        acceptStorageTerms: false,
      );
      final repository = FirebaseConsultationSubmissionRepository(
        auth: () => auth,
        database: () => database,
      );
      expect(await repository.load(), null);
      await expectLater(
        repository.submit(current, accepted: false),
        throwsA(isA<SubmissionFailure>()),
      );
      await expectLater(
        repository.submit(first, accepted: true),
        throwsA(
          isA<SubmissionFailure>().having(
            (error) => error.issue,
            'issue',
            SubmissionIssue.conflict,
          ),
        ),
      );
      final receipts = await Future.wait([
        repository.submit(current, accepted: true),
        repository.submit(current, accepted: true),
      ]);
      expect(receipts.map((receipt) => receipt.id).toSet(), {current.id});
      final restored = await FirebaseConsultationSubmissionRepository(
        auth: () => auth,
        database: () => database,
      ).load();
      expect(restored!.id, current.id);
      expect(restored.revision, 2);
      final copy = await database
          .collection('consultationSubmissions')
          .doc(uid)
          .get();
      expect(copy.data()!['draft']['details'], content.details);
      final summary = await database
          .collection('intakeRequests')
          .doc(current.id)
          .get();
      expect(summary.data()!.keys.toSet(), {
        'id',
        'countryCode',
        'mode',
        'createdAt',
        'status',
        'environment',
      });
      expect(summary.data()!['status'], 'received');
      await auth.signOut();
      await expectLater(repository.load(), throwsA(isA<SubmissionFailure>()));
    },
  );
}
