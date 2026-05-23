import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notifica_asada/core/network/auth_interceptor.dart';
import 'package:notifica_asada/core/storage/secure_storage.dart';

class _MockStorage extends Mock implements SecureStorage {}

/// Handler que captura el request final y lo expone para assertions,
/// sin propagar al network real.
class _CapturingHandler extends RequestInterceptorHandler {
  RequestOptions? captured;

  @override
  void next(RequestOptions requestOptions) {
    captured = requestOptions;
  }
}

void main() {
  late _MockStorage storage;
  late AuthInterceptor interceptor;

  setUp(() {
    storage = _MockStorage();
    interceptor = AuthInterceptor(storage);
  });

  test('adjunta Bearer cuando hay token y no hay Authorization explícito',
      () async {
    when(() => storage.read(SecureKeys.authToken))
        .thenAnswer((_) async => 'jwt-abc');

    final opts = RequestOptions(path: '/me');
    final handler = _CapturingHandler();
    await interceptor.onRequest(opts, handler);

    expect(handler.captured!.headers['Authorization'], 'Bearer jwt-abc');
  });

  test('NO sobrescribe Authorization explícito (custom)', () async {
    when(() => storage.read(SecureKeys.authToken))
        .thenAnswer((_) async => 'jwt-abc');

    final opts = RequestOptions(
      path: '/x',
      headers: {'Authorization': 'Bearer custom-token'},
    );
    final handler = _CapturingHandler();
    await interceptor.onRequest(opts, handler);

    expect(handler.captured!.headers['Authorization'], 'Bearer custom-token');
  });

  test('NO sobrescribe Authorization explícito aunque venga en minúscula',
      () async {
    when(() => storage.read(SecureKeys.authToken))
        .thenAnswer((_) async => 'jwt-abc');

    final opts = RequestOptions(
      path: '/x',
      headers: {'authorization': 'Basic dXNlcjpwYXNz'},
    );
    final handler = _CapturingHandler();
    await interceptor.onRequest(opts, handler);

    final headers = handler.captured!.headers;
    final hasUpper = headers.containsKey('Authorization');
    expect(hasUpper, isFalse,
        reason: 'No debe duplicar el header con otro casing');
    expect(headers['authorization'], 'Basic dXNlcjpwYXNz');
  });

  test('NO envía header cuando no hay token (evita Bearer null)', () async {
    when(() => storage.read(SecureKeys.authToken))
        .thenAnswer((_) async => null);

    final opts = RequestOptions(path: '/public');
    final handler = _CapturingHandler();
    await interceptor.onRequest(opts, handler);

    expect(handler.captured!.headers.containsKey('Authorization'), isFalse);
    expect(handler.captured!.headers.containsKey('authorization'), isFalse);
  });

  test('NO envía header cuando el token es string vacío', () async {
    when(() => storage.read(SecureKeys.authToken))
        .thenAnswer((_) async => '   ');

    final opts = RequestOptions(path: '/public');
    final handler = _CapturingHandler();
    await interceptor.onRequest(opts, handler);

    expect(handler.captured!.headers.containsKey('Authorization'), isFalse);
  });
}
