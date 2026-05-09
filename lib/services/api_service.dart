import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../data/solicitudes_demo.dart';
import '../models/solicitud_model.dart';

class ApiException implements Exception {
  ApiException(this.message, [this.statusCode]);

  final String message;
  final int? statusCode;

  @override
  String toString() =>
      statusCode != null ? '$message (código $statusCode)' : message;
}

/// Cliente HTTP para backend NestJS: `GET /solicitudes` y `GET /solicitudes/:id`.
class ApiService {
  ApiService({
    http.Client? httpClient,
    String? baseUrl,
    bool? useDemoData,
  })  : _client = httpClient ?? http.Client(),
        _baseUrl = (baseUrl ?? ApiConfig.baseUrl).replaceAll(RegExp(r'/+$'), ''),
        _useDemoData = useDemoData ?? ApiConfig.useDemoData;

  final http.Client _client;
  final String _baseUrl;
  final bool _useDemoData;

  Uri _uri(String path) {
    final p = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$_baseUrl$p');
  }

  /// GET /solicitudes
  Future<List<Solicitud>> fetchSolicitudes() async {
    if (_useDemoData) {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      return List<Solicitud>.from(solicitudesDemo);
    }
    final response = await _client.get(
      _uri('/solicitudes'),
      headers: {'Accept': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw ApiException(
        'No se pudo cargar el listado de solicitudes.',
        response.statusCode,
      );
    }
    final dynamic decoded = jsonDecode(response.body);
    final List<dynamic> list = _extractList(decoded);
    return list
        .map((e) => Solicitud.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// GET /solicitudes/:id
  Future<Solicitud> fetchSolicitudPorId(String id) async {
    if (_useDemoData) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      for (final s in solicitudesDemo) {
        if (s.id == id) return s;
      }
      throw ApiException('No hay solicitud de demostración con ese id.');
    }
    final encoded = Uri.encodeComponent(id);
    final response = await _client.get(
      _uri('/solicitudes/$encoded'),
      headers: {'Accept': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw ApiException(
        'No se pudo cargar el detalle de la solicitud.',
        response.statusCode,
      );
    }
    final dynamic decoded = jsonDecode(response.body);
    final Map<String, dynamic> map = _extractObject(decoded);
    return Solicitud.fromJson(map);
  }

  List<dynamic> _extractList(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'] ?? decoded['solicitudes'] ?? decoded['items'];
      if (data is List) return data;
    }
    return [];
  }

  Map<String, dynamic> _extractObject(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];
      if (data is Map<String, dynamic>) return data;
      return decoded;
    }
    throw ApiException('Respuesta JSON inválida para el detalle.');
  }
}
