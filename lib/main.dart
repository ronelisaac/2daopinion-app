import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'connected_app.dart';
import 'repositories/firebase_consultation_submission_repository.dart';
import 'domain/country_config.dart';
import 'repositories/firebase_identity_repository.dart';
import 'repositories/firebase_consultation_draft_repository.dart';
import 'firebase_options.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'repositories/firebase_private_document_repository.dart';
import 'repositories/firebase_notice_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = FirebaseIdentityRepository(
    auth: () => FirebaseAuth.instance,
    database: () => FirebaseFirestore.instance,
    country: CountryConfig.chile,
    locale: 'es',
    googleEnabled: const bool.fromEnvironment('ENABLE_GOOGLE_SIGN_IN'),
  );
  var initialized = false;
  const emulators = bool.fromEnvironment('USE_FIREBASE_EMULATORS');
  runApp(
    ConnectedApp(
      submissionRepository: emulators
          ? FirebaseConsultationSubmissionRepository(
              auth: () => FirebaseAuth.instance,
              database: () => FirebaseFirestore.instance,
            )
          : null,
      noticeRepository: emulators
          ? FirebaseNoticeRepository(
              auth: () => FirebaseAuth.instance,
              database: () => FirebaseFirestore.instance,
            )
          : null,
      privateDocumentRepository: emulators
          ? FirebasePrivateDocumentRepository(
              auth: () => FirebaseAuth.instance,
              database: () => FirebaseFirestore.instance,
              storage: () => FirebaseStorage.instance,
            )
          : null,
      identityRepository: repository,
      accountRepository: repository,
      draftRepository: FirebaseConsultationDraftRepository(
        auth: () => FirebaseAuth.instance,
        database: () => FirebaseFirestore.instance,
      ),
      initialize: () async {
        if (initialized) return;
        if (emulators && !kDebugMode) {
          throw StateError('Emulators require a local debug build.');
        }
        if (Firebase.apps.isEmpty) {
          await Firebase.initializeApp(
            options: emulators
                ? const FirebaseOptions(
                    apiKey: 'demo-key',
                    appId: '1:123456789:web:demo',
                    messagingSenderId: '123456789',
                    projectId: 'demo-2daopinion',
                    storageBucket: 'demo-2daopinion.appspot.com',
                  )
                : DefaultFirebaseOptions.currentPlatform,
          );
        }
        FirebaseFirestore.instance.settings = const Settings(
          persistenceEnabled: false,
        );
        if (emulators) {
          await FirebaseAuth.instance.useAuthEmulator('127.0.0.1', 9099);
          FirebaseFirestore.instance.useFirestoreEmulator('127.0.0.1', 8080);
          await FirebaseStorage.instance.useStorageEmulator('127.0.0.1', 9199);
        }
        if (kIsWeb) {
          await FirebaseAuth.instance.setPersistence(Persistence.SESSION);
        }
        initialized = true;
      },
    ),
  );
}
