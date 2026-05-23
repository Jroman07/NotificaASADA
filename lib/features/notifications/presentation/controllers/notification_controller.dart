import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';

/// Estados de carga de notificaciones.
sealed class NotificationState {
  const NotificationState();
}

class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

class NotificationLoaded extends NotificationState {
  const NotificationLoaded(this.notifications);
  final List<Notification> notifications;
}

class NotificationError extends NotificationState {
  const NotificationError(this.message);
  final String message;
}

class NotificationController extends StateNotifier<NotificationState> {
  NotificationController(this._repo) : super(const NotificationLoading());

  final NotificationRepository _repo;

  Future<void> loadNotifications() async {
    state = const NotificationLoading();
    try {
      final notifications = await _repo.getNotifications();
      state = NotificationLoaded(notifications);
    } catch (e) {
      state = NotificationError(e.toString());
    }
  }
}

final notificationControllerProvider =
    StateNotifierProvider<NotificationController, NotificationState>((ref) {
  return NotificationController(ref.watch(notificationRepositoryProvider));
});
