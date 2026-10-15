import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/services/notification_service.dart';
import 'package:gestion_hsse/cores/themes/app_colors.dart';
import 'package:gestion_hsse/views/home/notification/widget/notification_card.dart';
import 'package:gestion_hsse/views/home/notification/widget/notification_filter_chip.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  int selectedFilter = 0;
  bool _isLoading = true;
  List<NotificationItemData> _allNotifications = [];

  final filters = const [
    "Toutes",
    "Inspections",
    "Actions",
    "Système",
  ];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    final list = await NotificationService.getNotifications();
    if (mounted) {
      setState(() {
        _allNotifications = list;
        _isLoading = false;
      });
    }
  }

  List<NotificationItemData> get _filteredNotifications {
    if (selectedFilter == 0) return _allNotifications;

    final filter = filters[selectedFilter].toLowerCase();
    return _allNotifications.where((n) {
      final t = n.type.toUpperCase();
      if (filter.contains('inspection')) {
        return t.contains('INSPECTION') || t.contains('CHECKLIST') || t.contains('VMC');
      } else if (filter.contains('action')) {
        return t.contains('ACTION');
      } else if (filter.contains('système') || filter.contains('systeme')) {
        return t.contains('SYSTEM') || t.contains('USER') || t.contains('AUTH');
      }
      return true;
    }).toList();
  }

  IconData _getIconForType(String type) {
    final t = type.toUpperCase();
    if (t.contains('ACTION')) return Icons.warning_amber_rounded;
    if (t.contains('VMC')) return Icons.shield_outlined;
    if (t.contains('CHECKLIST') || t.contains('INSPECTION')) return Icons.fact_check_outlined;
    return Icons.notifications_outlined;
  }

  Color _getColorForType(String type) {
    final t = type.toUpperCase();
    if (t.contains('ACTION')) return const Color(0xFFEF4444);
    if (t.contains('VMC')) return const Color(0xFF0F9D58);
    if (t.contains('CHECKLIST') || t.contains('INSPECTION')) return const Color(0xFF3B82F6);
    return const Color(0xFFF59E0B);
  }

  Future<void> _markAllAsRead() async {
    final success = await NotificationService.markAllRead();
    if (success && mounted) {
      setState(() {
        _allNotifications = _allNotifications.map((n) => n.copyWith(viewed: true)).toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Toutes les notifications sont marquées comme lues."),
          backgroundColor: Color(0xFF15803D),
        ),
      );
    }
  }

  Future<void> _onNotificationTap(NotificationItemData item) async {
    if (!item.viewed) {
      await NotificationService.markAsRead(item.id);
      if (mounted) {
        setState(() {
          final idx = _allNotifications.indexWhere((n) => n.id == item.id);
          if (idx != -1) {
            _allNotifications[idx] = _allNotifications[idx].copyWith(viewed: true);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER ACTION
            Row(
              children: [
                ValueListenableBuilder<int>(
                  valueListenable: NotificationService.unreadCountNotifier,
                  builder: (context, count, _) {
                    return Text(
                      count > 0 ? "$count non lue(s)" : "Toutes lues",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    );
                  },
                ),
                const Spacer(),
                TextButton(
                  onPressed: _allNotifications.any((n) => !n.viewed) ? _markAllAsRead : null,
                  child: const Text("Tout marquer lu"),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // FILTERS
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  filters.length,
                  (index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: NotificationFilterChip(
                        label: filters[index],
                        selected: selectedFilter == index,
                        onTap: () {
                          setState(() {
                            selectedFilter = index;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // NOTIFICATIONS LIST
            if (_isLoading) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: CircularProgressIndicator(),
                ),
              )
            ] else if (_filteredNotifications.isEmpty) ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(Icons.notifications_none, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text(
                        "Aucune notification pour le moment",
                        style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              )
            ] else ...[
              ..._filteredNotifications.map((notif) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => _onNotificationTap(notif),
                    child: NotificationCard(
                      title: notif.title,
                      description: notif.description,
                      time: notif.ago.isNotEmpty ? notif.ago : "Récent",
                      icon: _getIconForType(notif.type),
                      color: _getColorForType(notif.type),
                      unread: !notif.viewed,
                    ),
                  ),
                );
              }),
            ],

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}