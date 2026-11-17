import 'package:firebase_messaging/firebase_messaging.dart';

import '../../services/notification_service.dart';
import '../../services/screen_service.dart';

class NotificationPayload {
  final NotificationType type;
  final MainScreenItem route;
  final DateTime sentAt;
  final String? localDate;
  final String? timezone;
  final DateTime? periodStart;
  final DateTime? periodEnd;

  const NotificationPayload({
    required this.type,
    required this.route,
    required this.sentAt,
    this.localDate,
    this.timezone,
    this.periodStart,
    this.periodEnd,
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

    final localDate = data['localDate'] is String ? data['localDate'] as String : null;
    final timezone = data['timezone'] is String ? data['timezone'] as String : null;
    final periodStart = parseSentAt(data['periodStart']);
    final periodEnd = parseSentAt(data['periodEnd']);

    if (type == NotificationType.dailySummaryPrepare && (localDate == null || timezone == null || periodStart == null || periodEnd == null || !periodStart.isBefore(periodEnd))) {
      return null;
    }

    return NotificationPayload(
      type: type,
      route: route,
      sentAt: sentAt,
      localDate: localDate,
      timezone: timezone,
      periodStart: periodStart,
      periodEnd: periodEnd,
    );
  }

  /// Parses the `ISO-8601` time at which the server sent the notification
  static DateTime? parseSentAt(Object? value) => value is String ? DateTime.tryParse(value) : null;
}
