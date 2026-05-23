/// Validadores puros — reutilizables y testeables.
class LoginValidators {
  LoginValidators._();

  // Regex pragmático para email; no RFC-completo pero suficiente para UI.
  static final RegExp _emailRegex =
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  static String? email(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'El email es obligatorio';
    if (v.length > 254) return 'El email no puede superar 254 caracteres';
    if (!_emailRegex.hasMatch(v)) return 'Email con formato inválido';
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'La contraseña es obligatoria';
    if (v.length > 64) return 'La contraseña no puede superar 64 caracteres';
    return null;
  }
}
