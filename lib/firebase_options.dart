// Reemplaza este archivo ejecutando en la raíz del proyecto:
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// Hasta entonces se usan valores de marcador de posición: la app compilará,
// pero Firebase solo funcionará tras configurar el proyecto real.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'Firebase no está configurado para esta plataforma.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REEMPLAZA_CON_TU_API_KEY',
    appId: '1:000000000000:android:reemplaza_app_id',
    messagingSenderId: '000000000000',
    projectId: 'reemplaza-proyecto-firebase',
    storageBucket: 'reemplaza-proyecto-firebase.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REEMPLAZA_CON_TU_API_KEY',
    appId: '1:000000000000:ios:reemplaza_app_id',
    messagingSenderId: '000000000000',
    projectId: 'reemplaza-proyecto-firebase',
    storageBucket: 'reemplaza-proyecto-firebase.appspot.com',
    iosBundleId: 'com.notifica.asada.notificaAsada',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REEMPLAZA_CON_TU_API_KEY',
    appId: '1:000000000000:web:reemplaza_app_id',
    messagingSenderId: '000000000000',
    projectId: 'reemplaza-proyecto-firebase',
    authDomain: 'reemplaza-proyecto-firebase.firebaseapp.com',
    storageBucket: 'reemplaza-proyecto-firebase.appspot.com',
  );
}
