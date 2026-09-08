import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'connected_app.dart';
import 'domain/country_config.dart';
import 'repositories/firebase_identity_repository.dart';
import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = FirebaseIdentityRepository(
    auth: () => FirebaseAuth.instance,
    database: () => FirebaseFirestore.instance,
    country: CountryConfig.chile,
    locale: 'es',
  );
  var initialized = false;
  runApp(
    ConnectedApp(
      identityRepository: repository,
      accountRepository: repository,
      initialize: () async {
        if (initialized) return;
        const emulators = bool.fromEnvironment('USE_FIREBASE_EMULATORS');
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
        }
        if (kIsWeb) {
          await FirebaseAuth.instance.setPersistence(Persistence.SESSION);
        }
        initialized = true;
      },
    ),
  );
}
