class LoginResponse {
  const LoginResponse({required this.token});

  final String token;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    // Acepta variantes comunes: { token }, { access_token }, { accessToken }
    final raw = json['token'] ?? json['access_token'] ?? json['accessToken'];
    if (raw is! String || raw.trim().isEmpty) {
      throw const FormatException('Respuesta de login sin token válido.');
    }
    return LoginResponse(token: raw);
  }
}
