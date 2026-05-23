import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notifica_asada/core/storage/secure_storage.dart';
import 'package:notifica_asada/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:notifica_asada/features/auth/data/models/login_response.dart';
import 'package:notifica_asada/features/auth/data/repositories/auth_repository.dart';

class _MockRemote extends Mock implements AuthRemoteDataSource {}

class _MockStorage extends Mock implements SecureStorage {}

void main() {
  late _MockRemote remote;
  late _MockStorage storage;
  late AuthRepository repo;

  setUp(() {
    remote = _MockRemote();
    storage = _MockStorage();
    repo = AuthRepository(remote: remote, storage: storage);
    registerFallbackValue(const LoginResponse(token: 'x'));
  });

  test('login success: persiste el token y lo devuelve', () async {
    when(() => remote.login(any())).thenAnswer(
      (_) async => const LoginResponse(token: 'jwt-123'),
    );
    when(() => storage.write(any(), any())).thenAnswer((_) async {});

    final token = await repo.login(email: 'a@b.co', password: '1234');

    expect(token, 'jwt-123');
    verify(() => storage.write(SecureKeys.authToken, 'jwt-123')).called(1);
  });

  test('login 401 → AuthException invalid_credentials con mensaje Acceso denegado',
      () async {
    when(() => remote.login(any())).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        response: Response(
          requestOptions: RequestOptions(path: '/auth/login'),
          statusCode: 401,
        ),
        type: DioExceptionType.badResponse,
      ),
    );

    expect(
      () => repo.login(email: 'a@b.co', password: 'x'),
      throwsA(
        isA<AuthException>()
            .having((e) => e.code, 'code', 'invalid_credentials')
            .having((e) => e.message, 'message', 'Acceso denegado'),
      ),
    );
    verifyNever(() => storage.write(any(), any()));
  });

  test('login sin red → AuthException network', () async {
    when(() => remote.login(any())).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        type: DioExceptionType.connectionError,
      ),
    );

    expect(
      () => repo.login(email: 'a@b.co', password: 'x'),
      throwsA(
        isA<AuthException>().having((e) => e.code, 'code', 'network'),
      ),
    );
  });

  test('logout limpia la sesión', () async {
    when(() => storage.clearSession()).thenAnswer((_) async {});
    await repo.logout();
    verify(() => storage.clearSession()).called(1);
  });
}
