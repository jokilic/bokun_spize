import 'package:firebase_messaging/firebase_messaging.dart';

import '../../services/notification_service.dart';
import '../../services/screen_service.dart';

class NotificationPayload {
  final NotificationType type;
  final MainScreenItem route;
  final String? entityId;
  final DateTime sentAt;

  const NotificationPayload({
    required this.type,
    required this.route,
    required this.sentAt,
    this.entityId,
  });

  /// Parses the stable data contract from an FCM message
  static NotificationPayload? fromMessage(RemoteMessage message) => fromMap(message.data);

  /// Parses the stable data contract while rejecting missing or unknown values
  static NotificationPayload? fromMap(Map<String, dynamic> data) {
    final type = NotificationType.values.byName(data['type']);
    final route = MainScreenItem.values.byName(data['route']);
    final sentAt = parseSentAt(data['sentAt']);
    final rawEntityId = data['entityId'];

    if (sentAt == null) {
      return null;
    }

    if (rawEntityId != null && (rawEntityId is! String || rawEntityId.trim().isEmpty)) {
      return null;
    }

    return NotificationPayload(
      type: type,
      route: route,
      entityId: rawEntityId as String?,
      sentAt: sentAt,
    );
  }

  /// Parses the `ISO-8601` time at which the server sent the notification
  static DateTime? parseSentAt(Object? value) => value is String ? DateTime.tryParse(value) : null;
}
