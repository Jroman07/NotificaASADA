import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/solicitud_provider.dart';
import 'screens/home_screen.dart';
import 'services/api_service.dart';
import 'services/push_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await PushNotificationService.init();
  } catch (e, stack) {
    debugPrint('Firebase no disponible (configura flutterfire / opciones): $e');
    debugPrint('$stack');
  }

  final apiService = ApiService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SolicitudProvider(apiService: apiService),
        ),
      ],
      child: const VoluntariadoApp(),
    ),
  );
}

class VoluntariadoApp extends StatelessWidget {
  const VoluntariadoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NotificaASADA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0A5C6E)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
