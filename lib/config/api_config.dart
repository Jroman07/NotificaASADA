import 'package:flutter/foundation.dart';

/// URL base del API NestJS. Sobrescribe con:
/// `flutter run --dart-define=API_BASE_URL=https://tu-servidor.com`
///
/// Datos de demostración (listado y detalle sin backend):
/// `USE_DEMO_DATA` por defecto es `true`. API real:
/// `flutter run --dart-define=USE_DEMO_DATA=false`
class ApiConfig {
  ApiConfig._();

  static const bool useDemoData = bool.fromEnvironment(
    'USE_DEMO_DATA',
    defaultValue: true,
  );

  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (kIsWeb) return 'http://localhost:3000';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }
}
