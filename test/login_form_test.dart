import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:notifica_asada/features/auth/data/repositories/auth_repository.dart';
import 'package:notifica_asada/features/auth/presentation/screens/login_screen.dart';
import 'package:notifica_asada/features/auth/presentation/validators.dart';

class _FakeAuthRepo implements AuthRepository {
  String? lastEmail;
  String? lastPassword;
  bool shouldFail = false;

  @override
  Future<String> login({required String email, required String password}) async {
    lastEmail = email;
    lastPassword = password;
    if (shouldFail) {
      throw const AuthException('invalid_credentials', 'Acceso denegado');
    }
    return 'jwt-ok';
  }

  @override
  Future<String?> currentToken() async => null;

  @override
  Future<void> logout() async {}
}

void main() {
  group('LoginValidators', () {
    test('email vacío inválido', () {
      expect(LoginValidators.email(''), isNotNull);
    });
    test('email con formato inválido', () {
      expect(LoginValidators.email('no-arroba'), isNotNull);
    });
    test('email > 254 chars inválido', () {
      final long = '${'a' * 250}@b.co';
      expect(LoginValidators.email(long), isNotNull);
    });
    test('email válido', () {
      expect(LoginValidators.email('a@b.co'), isNull);
    });
    test('password vacía inválida', () {
      expect(LoginValidators.password(''), isNotNull);
    });
    test('password > 64 chars inválida', () {
      expect(LoginValidators.password('x' * 65), isNotNull);
    });
    test('password válida', () {
      expect(LoginValidators.password('123456'), isNull);
    });
  });

  testWidgets('Botón submit deshabilitado mientras formulario inválido y se habilita al validar',
      (tester) async {
    final fake = _FakeAuthRepo();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(fake),
        ],
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final submit = find.byKey(const Key('login-submit'));
    expect(submit, findsOneWidget);

    // Inicialmente deshabilitado (formulario vacío).
    final FilledButton btn0 = tester.widget(submit);
    expect(btn0.onPressed, isNull);

    // Email inválido + password vacía → sigue deshabilitado.
    await tester.enterText(find.byType(TextFormField).at(0), 'no-arroba');
    await tester.pump();
    expect((tester.widget(submit) as FilledButton).onPressed, isNull);

    // Datos válidos → se habilita.
    await tester.enterText(find.byType(TextFormField).at(0), 'user@test.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret123');
    await tester.pump();
    expect((tester.widget(submit) as FilledButton).onPressed, isNotNull);
  });

  testWidgets('Submit con credenciales inválidas muestra "Acceso denegado"',
      (tester) async {
    final fake = _FakeAuthRepo()..shouldFail = true;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(fake),
        ],
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'user@test.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'wrong');
    await tester.pump();

    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('login-error')), findsOneWidget);
    expect(find.text('Acceso denegado'), findsOneWidget);
  });
}
