import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/auth_repository.dart';

/// Estados de sesión:
///   - unknown: aún no se restauró desde storage.
///   - unauthenticated: no hay token.
///   - authenticated: hay token (y opcionalmente metadata).
sealed class AuthState {
  const AuthState();
}

class AuthUnknown extends AuthState {
  const AuthUnknown();
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class Authenticated extends AuthState {
  const Authenticated(this.token);
  final String token;
}

/// Estado transitorio de la mutación de login (loading/error).
class LoginStatus {
  const LoginStatus({this.loading = false, this.errorMessage});
  final bool loading;
  final String? errorMessage;

  LoginStatus copyWith({bool? loading, String? errorMessage, bool clearError = false}) {
    return LoginStatus(
      loading: loading ?? this.loading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  static const idle = LoginStatus();
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repo) : super(const AuthUnknown());

  final AuthRepository _repo;

  /// Llamar al arrancar la app para restaurar sesión.
  Future<void> bootstrap() async {
    final token = await _repo.currentToken();
    if (token != null && token.isNotEmpty) {
      state = Authenticated(token);
    } else {
      state = const Unauthenticated();
    }
  }

  /// Devuelve `null` si éxito, o un mensaje de error si falló.
  Future<String?> login({required String email, required String password}) async {
    try {
      final token = await _repo.login(email: email, password: password);
      state = Authenticated(token);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'Acceso denegado';
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const Unauthenticated();
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});

/// Estado de la mutación de login (para mostrar loading/errores en UI).
final loginStatusProvider =
    StateNotifierProvider<LoginStatusController, LoginStatus>((ref) {
  return LoginStatusController();
});

class LoginStatusController extends StateNotifier<LoginStatus> {
  LoginStatusController() : super(LoginStatus.idle);

  void setLoading(bool v) => state = state.copyWith(loading: v, clearError: true);
  void setError(String? msg) =>
      state = state.copyWith(loading: false, errorMessage: msg);
  void reset() => state = LoginStatus.idle;
}
