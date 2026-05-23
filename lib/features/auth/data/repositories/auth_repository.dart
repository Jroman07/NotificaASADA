import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart' show authDioProvider;
import '../../../../core/storage/secure_storage.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_request.dart';

/// Errores normalizados de auth para que la UI pueda mapearlos a copy estable.
class AuthException implements Exception {
  const AuthException(this.code, this.message);
  final String code; // 'invalid_credentials' | 'network' | 'unknown'
  final String message;

  @override
  String toString() => 'AuthException($code): $message';
}

class AuthRepository {
  AuthRepository({
    required AuthRemoteDataSource remote,
    required SecureStorage storage,
  })  : _remote = remote,
        _storage = storage;

  final AuthRemoteDataSource _remote;
  final SecureStorage _storage;

  /// Realiza login. Si éxito → persiste token y devuelve el token.
  /// Si falla → lanza [AuthException].
  Future<String> login({required String email, required String password}) async {
    try {
      final res = await _remote.login(
        LoginRequest(email: email, password: password),
      );
      await _storage.write(SecureKeys.authToken, res.token);
      return res.token;
    } on DioException catch (e) {
      if (e.response != null) {
        final code = e.response!.statusCode ?? 0;
        if (code == 401 || code == 403 || code == 400) {
          throw const AuthException('invalid_credentials', 'Acceso denegado');
        }
        throw AuthException('unknown', 'Error del servidor ($code)');
      }
      throw const AuthException('network', 'No se pudo conectar al servidor');
    } on FormatException catch (e) {
      throw AuthException('unknown', e.message);
    } catch (e) {
      throw AuthException('unknown', e.toString());
    }
  }

  Future<String?> currentToken() => _storage.read(SecureKeys.authToken);

  Future<void> logout() => _storage.clearSession();
}

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(authDioProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    remote: ref.watch(authRemoteDataSourceProvider),
    storage: ref.watch(secureStorageProvider),
  );
});
