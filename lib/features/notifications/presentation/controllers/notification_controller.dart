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
    this.currentPage = 1,
    this.itemsPerPage = 5,
  });
  final List<Notification> notifications;
  final String searchQuery;
  final List<Notification>? filteredNotifications;
  final int currentPage;
  final int itemsPerPage;

  List<Notification> get displayedNotifications =>
      filteredNotifications ?? notifications;

  int get totalItems => displayedNotifications.length;
  int get totalPages => (totalItems / itemsPerPage).ceil();

  List<Notification> get pageNotifications {
    final start = (currentPage - 1) * itemsPerPage;
    final end = start + itemsPerPage;
    return displayedNotifications.sublist(
      start,
      end > displayedNotifications.length ? displayedNotifications.length : end,
    );
  }

  bool get canGoNext => currentPage < totalPages;
  bool get canGoPrevious => currentPage > 1;
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
      state = NotificationLoaded(
        current.notifications,
        searchQuery: query,
        currentPage: 1,
        itemsPerPage: current.itemsPerPage,
      );
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
        currentPage: 1,
        itemsPerPage: current.itemsPerPage,
      );
    }
  }

  Future<void> markAsRead(int userNotificationId) async {
    try {
      await _repo.markNotificationAsRead(userNotificationId);
      final current = state;
      if (current is! NotificationLoaded) return;

      final updated = current.notifications.map((n) {
        if (n.userNotificationId == userNotificationId) {
          return Notification(
            userNotificationId: n.userNotificationId,
            id: n.id,
            subject: n.subject,
            message: n.message,
            createdAt: n.createdAt,
            isRead: true,
          );
        }
        return n;
      }).toList();

      if (current.filteredNotifications != null) {
        final filteredUpdated = current.filteredNotifications!.map((n) {
          if (n.userNotificationId == userNotificationId) {
            return Notification(
              userNotificationId: n.userNotificationId,
              id: n.id,
              subject: n.subject,
              message: n.message,
              createdAt: n.createdAt,
              isRead: true,
            );
          }
          return n;
        }).toList();

        state = NotificationLoaded(
          updated,
          searchQuery: current.searchQuery,
          filteredNotifications: filteredUpdated,
          currentPage: current.currentPage,
          itemsPerPage: current.itemsPerPage,
        );
      } else {
        state = NotificationLoaded(
          updated,
          searchQuery: current.searchQuery,
          currentPage: current.currentPage,
          itemsPerPage: current.itemsPerPage,
        );
      }
    } catch (e) {
      state = NotificationError(e.toString());
    }
  }

  void nextPage() {
    final current = state;
    if (current is! NotificationLoaded || !current.canGoNext) return;
    state = NotificationLoaded(
      current.notifications,
      searchQuery: current.searchQuery,
      filteredNotifications: current.filteredNotifications,
      currentPage: current.currentPage + 1,
      itemsPerPage: current.itemsPerPage,
    );
  }

  void previousPage() {
    final current = state;
    if (current is! NotificationLoaded || !current.canGoPrevious) return;
    state = NotificationLoaded(
      current.notifications,
      searchQuery: current.searchQuery,
      filteredNotifications: current.filteredNotifications,
      currentPage: current.currentPage - 1,
      itemsPerPage: current.itemsPerPage,
    );
  }
}

final notificationControllerProvider =
    StateNotifierProvider<NotificationController, NotificationState>((ref) {
  return NotificationController(ref.watch(notificationRepositoryProvider));
});
