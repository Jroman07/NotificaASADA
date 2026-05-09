import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';

/// Handler en segundo plano (debe ser función de nivel superior).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kDebugMode) {
    debugPrint('FCM (background): ${message.messageId}');
  }
}

/// Base para FCM: permisos, token y escucha de mensajes en primer plano.
class PushNotificationService {
  PushNotificationService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> init() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (kDebugMode) {
      debugPrint('FCM permiso: ${settings.authorizationStatus}');
    }

    try {
      final token = await _messaging.getToken();
      if (kDebugMode) {
        debugPrint('FCM token: $token');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FCM getToken: $e');
      }
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        debugPrint(
          'FCM (foreground): ${message.notification?.title} — ${message.notification?.body}',
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        debugPrint('FCM abierto desde notificación: ${message.messageId}');
      }
    });
  }
}
