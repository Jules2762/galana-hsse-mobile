import 'package:flutter/foundation.dart';
import 'package:gestion_hsse/cores/api/api_client.dart';

class NotificationItemData {
  final String id;
  final String title;
  final String description;
  final String type;
  final String link;
  final bool viewed;
  final String ago;
  final String? createdAt;

  const NotificationItemData({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.link,
    required this.viewed,
    required this.ago,
    this.createdAt,
  });

  factory NotificationItemData.fromJson(Map<String, dynamic> json) {
    return NotificationItemData(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Notification',
      description: json['description']?.toString() ?? '',
      type: json['type']?.toString() ?? 'SYSTEM',
      link: json['link']?.toString() ?? 'DASHBOARD',
      viewed: json['viewed'] == true,
      ago: json['ago']?.toString() ?? '',
      createdAt: json['created_at']?.toString(),
    );
  }

  NotificationItemData copyWith({bool? viewed}) {
    return NotificationItemData(
      id: id,
      title: title,
      description: description,
      type: type,
      link: link,
      viewed: viewed ?? this.viewed,
      ago: ago,
      createdAt: createdAt,
    );
  }
}

class NotificationService {
  /// Notifier réactif du nombre de notifications non lues pour les badges
  static final ValueNotifier<int> unreadCountNotifier = ValueNotifier<int>(0);

  /// Récupère la liste des notifications depuis l'API
  static Future<List<NotificationItemData>> getNotifications() async {
    try {
      await ApiClient.ensureAuthenticated();
      final response = await ApiClient.dio.get('/home/notifications');

      if (response.statusCode == 200 && response.data != null) {
        final unread = response.data['unread_count'];
        if (unread is num) {
          unreadCountNotifier.value = unread.toInt();
        }

        final rawList = response.data['data'];
        if (rawList is List) {
          return rawList
              .map((item) => NotificationItemData.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      }
    } catch (_) {}

    return [];
  }

  /// Marque toutes les notifications comme lues
  static Future<bool> markAllRead() async {
    try {
      await ApiClient.ensureAuthenticated();
      final response = await ApiClient.dio.post('/home/notifications/mark-all-read');
      if (response.statusCode == 200) {
        unreadCountNotifier.value = 0;
        return true;
      }
    } catch (_) {}
    return false;
  }

  /// Marque une notification spécifique comme lue
  static Future<bool> markAsRead(String id) async {
    try {
      await ApiClient.ensureAuthenticated();
      final response = await ApiClient.dio.put('/home/notifications/$id/read');
      if (response.statusCode == 200) {
        if (unreadCountNotifier.value > 0) {
          unreadCountNotifier.value--;
        }
        return true;
      }
    } catch (_) {}
    return false;
  }
}
