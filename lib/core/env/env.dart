/// Variables de entorno de la app.
///
/// Se sobrescriben en build/run con `--dart-define`:
///   flutter run --dart-define=API_AUTH_BASE_URL=https://api.redsanpablo.cloud
///   flutter run --dart-define=API_NOTIFICATION_BASE_URL=https://api.redsanpablo.cloud/notification
///
class Env {
  Env._();

  /// URL base para endpoints de autenticación.
  /// Endpoint: POST /auth/login
  static const String apiAuthBaseUrl = String.fromEnvironment(
    'API_AUTH_BASE_URL',
    defaultValue: 'https://api.redsanpablo.cloud',
  );

  /// URL base para endpoints de contenido/notificaciones.
  /// Endpoint: GET /notification/me (relativo a esta URL)
  static const String apiNotificationBaseUrl = String.fromEnvironment(
    'API_NOTIFICATION_BASE_URL',
    defaultValue: 'https://api.redsanpablo.cloud/notification',
  );

  /// Timeout por defecto de Dio (ms).
  static const int httpTimeoutMs = int.fromEnvironment(
    'HTTP_TIMEOUT_MS',
    defaultValue: 15000,
  );
}
