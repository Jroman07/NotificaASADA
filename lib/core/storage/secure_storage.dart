import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Claves usadas dentro del almacenamiento seguro.
class SecureKeys {
  SecureKeys._();
  static const String authToken = 'auth_token';
  static const String userRole = 'user_role';
}

/// Wrapper testeable sobre [FlutterSecureStorage].
class SecureStorage {
  SecureStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  final FlutterSecureStorage _storage;

  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  Future<String?> read(String key) => _storage.read(key: key);

  Future<void> delete(String key) => _storage.delete(key: key);

  Future<void> clearSession() async {
    await _storage.delete(key: SecureKeys.authToken);
    await _storage.delete(key: SecureKeys.userRole);
  }
}

final secureStorageProvider = Provider<SecureStorage>((ref) => SecureStorage());
