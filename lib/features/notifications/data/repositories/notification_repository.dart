import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../models/notification_model.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationRepository {
  NotificationRepository(this._remote);

  final NotificationRemoteDataSource _remote;

  Future<List<Notification>> getNotifications() async {
    try {
      final list = await _remote.getNotifications();
      // Ordenar por fecha descendente.
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } on Exception {
      rethrow;
    }
  }

  Future<void> markNotificationAsRead(int userNotificationId) async {
    try {
      await _remote.markAsRead(userNotificationId);
    } on Exception {
      rethrow;
    }
  }
}

final notificationRemoteDataSourceProvider =
    Provider<NotificationRemoteDataSource>((ref) {
  return NotificationRemoteDataSource(ref.watch(notificationDioProvider));
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(
    ref.watch(notificationRemoteDataSourceProvider),
  );
});
