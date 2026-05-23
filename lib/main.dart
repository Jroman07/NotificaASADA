import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'core/router/app_router.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'firebase_options.dart';
import 'services/push_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await PushNotificationService.init();
  } catch (e, stack) {
    debugPrint('Firebase no disponible (configura flutterfire / opciones): $e');
    debugPrint('$stack');
  }

  runApp(const ProviderScope(child: VoluntariadoApp()));
}

class VoluntariadoApp extends ConsumerStatefulWidget {
  const VoluntariadoApp({super.key});

  @override
  ConsumerState<VoluntariadoApp> createState() => _VoluntariadoAppState();
}

class _VoluntariadoAppState extends ConsumerState<VoluntariadoApp> {
  @override
  void initState() {
    super.initState();
    // Restaurar sesión al arrancar.
    Future.microtask(
      () => ref.read(authControllerProvider.notifier).bootstrap(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'NotificaASADA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0A5C6E)),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
