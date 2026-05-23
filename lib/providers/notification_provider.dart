import 'package:flutter/material.dart';

import '../models/notification_model.dart';
import '../services/api_service.dart';

class NotificationProvider extends ChangeNotifier {
  NotificationProvider({required this.apiService});

  final ApiService apiService;

  List<Notification> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<Notification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Carga notificaciones desde GET /notification/me.
  /// Nota: `ApiService` usa `http` package sin soporte para Bearer token.
  /// Para endpoints autenticados, usa Dio directamente desde el controller Riverpod.
  /// Por ahora, si la app no tiene auth, esto funciona; si necesita auth,
  /// reemplaza por un cliente Dio injectable.
  Future<void> cargarNotificaciones() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await apiService.get('/notification/me');

      if (res is List) {
        _notifications = res
            .whereType<Map<String, dynamic>>()
            .map(Notification.fromJson)
            .toList();
        // Ordenar por fecha descendente (más recientes primero).
        _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } else if (res is Map<String, dynamic>) {
        // Si la respuesta está envuelta: { data: [...] } o { notifications: [...] }
        final data = res['data'] ?? res['notifications'] ?? res['items'];
        if (data is List) {
          _notifications = data
              .whereType<Map<String, dynamic>>()
              .map(Notification.fromJson)
              .toList();
          _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        } else {
          _error = 'Respuesta inesperada del servidor';
        }
      } else {
        _error = 'Respuesta inesperada del servidor';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
