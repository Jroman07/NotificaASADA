import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/notifications/presentation/controllers/notification_controller.dart';
import '../models/notification_model.dart' as notif_model;

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(notificationControllerProvider.notifier).loadNotifications();
    });
  }

  String _formatFecha(DateTime d) {
    if (d.millisecondsSinceEpoch == 0) return '—';
    final local = d.toLocal();
    final hoy = DateTime.now();
    final ayer = hoy.subtract(const Duration(days: 1));

    if (local.year == hoy.year &&
        local.month == hoy.month &&
        local.day == hoy.day) {
      return 'Hoy ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    }
    if (local.year == ayer.year &&
        local.month == ayer.month &&
        local.day == ayer.day) {
      return 'Ayer ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    }

    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final notifState = ref.watch(notificationControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F5F8),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 16,
        title: const Text(
          'NotificaASADA',
          style: TextStyle(
            color: Color(0xFF0B1220),
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () =>
                ref.read(authControllerProvider.notifier).logout(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        top: false,
        child: _buildBody(context, notifState),
      ),
    );
  }

  Widget _buildBody(BuildContext context, NotificationState state) {
    return switch (state) {
      NotificationLoading() => const Center(child: CircularProgressIndicator()),
      NotificationError(:final message) => _errorWidget(context, message),
      NotificationLoaded(:final notifications) =>
        notifications.isEmpty
            ? _emptyWidget(context)
            : _listWidget(context, state),
    };
  }

  Widget _errorWidget(BuildContext context, String error) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(22),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD9E0EA)),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.cloud_off,
                size: 56,
                color: Color(0xFF0B1730),
              ),
              const SizedBox(height: 16),
              Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF4B5563),
                  fontSize: 16,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0B1730),
                  foregroundColor: Colors.white,
                ),
                onPressed: () =>
                    ref.read(notificationControllerProvider.notifier).loadNotifications(),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _emptyWidget(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(22),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD9E0EA)),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.notifications_none,
                size: 56,
                color: Color(0xFF6B7280),
              ),
              const SizedBox(height: 16),
              const Text(
                'No hay notificaciones',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0B1730),
                  foregroundColor: Colors.white,
                ),
                onPressed: () =>
                    ref.read(notificationControllerProvider.notifier).loadNotifications(),
                icon: const Icon(Icons.refresh),
                label: const Text('Recargar'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _listWidget(
    BuildContext context,
    NotificationLoaded state,
  ) {
    final notifications = state.notifications;
    final pageNotifications = state.pageNotifications;
    final recentCount = notifications.where((n) {
      final now = DateTime.now();
      final local = n.createdAt.toLocal();
      return local.year == now.year && local.month == now.month;
    }).length;

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(notificationControllerProvider.notifier).loadNotifications(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontal = constraints.maxWidth < 420 ? 14.0 : 22.0;

          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(horizontal, 10, horizontal, 16),
            itemCount: pageNotifications.length + 3,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _StatsRow(
                    total: notifications.length,
                    recent: recentCount,
                  ),
                );
              }

              if (index == 1) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _SearchBox(
                    onChanged: (query) => ref
                        .read(notificationControllerProvider.notifier)
                        .searchNotifications(query),
                  ),
                );
              }

              if (index == pageNotifications.length + 2) {
                return Padding(
                  padding: const EdgeInsets.only(top: 14, bottom: 8),
                  child: _PaginationSummary(
                    total: state.displayedNotifications.length,
                    showing: pageNotifications.length,
                    currentPage: state.currentPage,
                    totalPages: state.totalPages,
                    onPreviousPage: state.canGoPrevious
                        ? () => ref
                            .read(notificationControllerProvider.notifier)
                            .previousPage()
                        : null,
                    onNextPage: state.canGoNext
                        ? () => ref
                            .read(notificationControllerProvider.notifier)
                            .nextPage()
                        : null,
                  ),
                );
              }

              final n = pageNotifications[index - 2];

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () {
                    if (!n.isRead) {
                      ref
                          .read(notificationControllerProvider.notifier)
                          .markAsRead(n.userNotificationId);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBFCFD),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFD6DEE8)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  n.subject.isEmpty ? 'Sin asunto' : n.subject,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF0B1220),
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _StatusChip(isRead: n.isRead),
                              if (!n.isRead)
                                Padding(
                                  padding: const EdgeInsets.only(left: 6, top: 2),
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF0D5CCC),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            n.message,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF3F4652),
                              fontSize: 17,
                              height: 1.35,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(
                                Icons.schedule_outlined,
                                size: 22,
                                color: Color(0xFF6B7280),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  _formatFecha(n.createdAt),
                                  style: const TextStyle(
                                    color: Color(0xFF616B7B),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.total, required this.recent});

  final int total;
  final int recent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'NOTIFICACIONES\nTOTALES',
            value: total.toString(),
            icon: Icons.notifications_none_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'RECIENTES (ESTE\nMES)',
            value: recent.toString(),
            icon: Icons.done_all,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value, required this.icon});

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFCFD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD6DEE8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF313844),
                    fontSize: 12,
                    height: 1.32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Icon(icon, size: 20, color: const Color(0xFF6E7481)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF051B59),
              fontSize: 40,
              height: 1,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBox extends StatefulWidget {
  const _SearchBox({required this.onChanged});

  final Function(String) onChanged;

  @override
  State<_SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<_SearchBox> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() {
      widget.onChanged(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFCFD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD6DEE8)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 26, color: Color(0xFF707784)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Buscar por asunto o descripcion...',
                hintStyle: TextStyle(
                  color: Color(0xFF656D7A),
                  fontSize: 16,
                  letterSpacing: 0.3,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
              style: const TextStyle(
                color: Color(0xFF0B1220),
                fontSize: 16,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.isRead});

  final bool isRead;

  @override
  Widget build(BuildContext context) {
    final bg = isRead ? const Color(0xFFDCEFE4) : const Color(0xFFFFC107);
    final fg = isRead ? const Color(0xFF12954A) : const Color(0xFF111827);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isRead ? 'LEIDA' : 'NO LEIDA',
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _PaginationSummary extends StatelessWidget {
  const _PaginationSummary({
    required this.total,
    required this.showing,
    required this.currentPage,
    required this.totalPages,
    this.onPreviousPage,
    this.onNextPage,
  });

  final int total;
  final int showing;
  final int currentPage;
  final int totalPages;
  final VoidCallback? onPreviousPage;
  final VoidCallback? onNextPage;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: onPreviousPage,
          icon: const Icon(Icons.chevron_left_rounded),
          color: onPreviousPage != null
              ? const Color(0xFF0D5CCC)
              : const Color(0xFFA8B0BC),
        ),
        Text(
          '$currentPage / $totalPages',
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        IconButton(
          onPressed: onNextPage,
          icon: const Icon(Icons.chevron_right_rounded),
          color: onNextPage != null
              ? const Color(0xFF0D5CCC)
              : const Color(0xFFA8B0BC),
        ),
      ],
    );
  }
}
