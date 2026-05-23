import 'package:dio/dio.dart';

import '../storage/secure_storage.dart';

/// Interceptor que adjunta `Authorization: Bearer <token>` cuando:
///   1) El request no trae Authorization explícito.
///   2) Existe un token válido en el almacenamiento seguro.
///
/// Reglas:
///   - Si el request YA trae Authorization, NO se sobrescribe.
///   - Si no hay token o el token está vacío, NO se envía el header
///     (evita `Bearer null` / `Bearer undefined`).
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage);

  final SecureStorage _storage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final existing = _firstHeader(options.headers, 'authorization');
    if (existing != null && existing.toString().trim().isNotEmpty) {
      // Respeta el Authorization explícito.
      return handler.next(options);
    }

    final token = await _storage.read(SecureKeys.authToken);
    if (token != null && token.trim().isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    } else {
      // Nunca enviar Bearer vacío.
      options.headers.remove('Authorization');
      options.headers.remove('authorization');
    }

    return handler.next(options);
  }

  Object? _firstHeader(Map<String, dynamic> headers, String name) {
    for (final entry in headers.entries) {
      if (entry.key.toLowerCase() == name.toLowerCase()) {
        return entry.value;
      }
    }
    return null;
  }
}
