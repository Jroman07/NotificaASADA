import 'package:dio/dio.dart';
import 'package:notifica_asada/models/notification_model.dart';

class NotificationRemoteDataSource {
  NotificationRemoteDataSource(this._dio);

  final Dio _dio;

  /// GET /notification/me — obtiene lista de notificaciones autenticadas.
  Future<List<Notification>> getNotifications() async {
    final res = await _dio.get<dynamic>('/me');
    final data = res.data;

    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(Notification.fromJson)
          .toList();
    } else if (data is Map<String, dynamic>) {
      final list = data['data'] ?? data['notifications'] ?? data['items'];
      if (list is List) {
        return list
            .whereType<Map<String, dynamic>>()
            .map(Notification.fromJson)
            .toList();
      }
    }

    throw const FormatException('Respuesta de notificaciones inválida.');
  }
}
