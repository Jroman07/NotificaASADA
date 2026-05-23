import 'package:flutter_test/flutter_test.dart';
import 'package:notifica_asada/features/auth/data/models/login_request.dart';

void main() {
  test('LoginRequest serializa Email y Password con mayúscula inicial', () {
    const request = LoginRequest(email: 'user@test.com', password: 'secret123');

    expect(request.toJson(), {
      'Email': 'user@test.com',
      'Password': 'secret123',
    });
  });
}