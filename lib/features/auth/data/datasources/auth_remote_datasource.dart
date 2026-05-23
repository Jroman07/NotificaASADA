import 'package:dio/dio.dart';

import '../models/login_request.dart';
import '../models/login_response.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);

  final Dio _dio;

  /// POST /auth/login (relativo a baseUrl).
  Future<LoginResponse> login(LoginRequest req) async {
    final res = await _dio.post<dynamic>(
      '/auth/login',
      data: req.toJson(),
    );

    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Respuesta de login inválida.');
    }
    return LoginResponse.fromJson(data);
  }
}
