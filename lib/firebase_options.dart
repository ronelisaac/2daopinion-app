import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

abstract final class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    throw UnsupportedError('Firebase is configured for web only.');
  }

  static const web = FirebaseOptions(
    apiKey: 'AIzaSyAPtjO1yd3QtxnZJCU5wZhsY3Fkq8EGkDo',
    appId: '1:638989286509:web:29bbf8428c2ba4c5ec5364',
    messagingSenderId: '638989286509',
    projectId: 'segundaopinion-ea0c8',
    authDomain: 'segundaopinion-ea0c8.firebaseapp.com',
    storageBucket: 'segundaopinion-ea0c8.firebasestorage.app',
  );
}
