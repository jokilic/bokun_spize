import 'package:firebase_messaging/firebase_messaging.dart';

import '../../services/notification_service.dart';
import '../../services/screen_service.dart';

class NotificationPayload {
  final NotificationType type;
  final MainScreenItem route;
  final DateTime sentAt;

  const NotificationPayload({
    required this.type,
    required this.route,
    required this.sentAt,
  });

  /// Parses the stable data contract from an FCM message
  static NotificationPayload? fromMessage(RemoteMessage message) => fromMap(message.data);

  /// Parses the stable data contract while rejecting missing or unknown values
  static NotificationPayload? fromMap(Map<String, dynamic> data) {
    final rawType = data['type'];
    final rawRoute = data['route'];
    final sentAt = parseSentAt(data['sentAt']);

    if (rawType is! String || rawRoute is! String || sentAt == null) {
      return null;
    }

    final type = NotificationType.values.asNameMap()[rawType];
    final route = MainScreenItem.values.asNameMap()[rawRoute];

    if (type == null || route == null) {
      return null;
    }

    return NotificationPayload(
      type: type,
      route: route,
      sentAt: sentAt,
    );
  }

  /// Parses the `ISO-8601` time at which the server sent the notification
  static DateTime? parseSentAt(Object? value) => value is String ? DateTime.tryParse(value) : null;
}
