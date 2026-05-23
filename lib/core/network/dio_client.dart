import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../env/env.dart';
import '../storage/secure_storage.dart';
import 'auth_interceptor.dart';

Dio buildDio({
  required SecureStorage storage,
  required String baseUrl,
  String name = 'default',
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(milliseconds: Env.httpTimeoutMs),
      receiveTimeout: Duration(milliseconds: Env.httpTimeoutMs),
      sendTimeout: Duration(milliseconds: Env.httpTimeoutMs),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      responseType: ResponseType.json,
    ),
  );

  dio.interceptors.add(AuthInterceptor(storage));
  return dio;
}

/// Cliente Dio para endpoints de autenticación (POST /auth/login).
final authDioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return buildDio(
    storage: storage,
    baseUrl: Env.apiAuthBaseUrl,
    name: 'auth',
  );
});

/// Cliente Dio para endpoints de notificaciones (GET /notification/me, etc).
final notificationDioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return buildDio(
    storage: storage,
    baseUrl: Env.apiNotificationBaseUrl,
    name: 'notification',
  );
});
