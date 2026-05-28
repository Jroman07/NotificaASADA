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
  const NotificationLoaded(
    this.notifications, {
    this.searchQuery = '',
    this.filteredNotifications,
  });
  final List<Notification> notifications;
  final String searchQuery;
  final List<Notification>? filteredNotifications;

  List<Notification> get displayedNotifications =>
      filteredNotifications ?? notifications;
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

  void searchNotifications(String query) {
    final current = state;
    if (current is! NotificationLoaded) return;

    if (query.isEmpty) {
      state = NotificationLoaded(current.notifications, searchQuery: query);
    } else {
      final filtered = current.notifications
          .where((notif) {
            final lowerQuery = query.toLowerCase();
            return notif.subject.toLowerCase().contains(lowerQuery) ||
                notif.message.toLowerCase().contains(lowerQuery);
          })
          .toList();

      state = NotificationLoaded(
        current.notifications,
        searchQuery: query,
        filteredNotifications: filtered,
      );
    }
  }
}

final notificationControllerProvider =
    StateNotifierProvider<NotificationController, NotificationState>((ref) {
  return NotificationController(ref.watch(notificationRepositoryProvider));
});
