import 'dart:developer';

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
    // TODO: I've triggered a test notification in Firebase and got this error:
    //Handling a background FCM message failed
    // [log] _TypeError (type 'Null' is not a subtype of type 'String')
    // [log] #0      NotificationPayload.fromMap (package:bokun_spize/models/notification/notification_payload.dart:24:53)
    //       #1      NotificationPayload.fromMessage (package:bokun_spize/models/notification/notification_payload.dart:20:69)
    //       #2      firebaseMessagingBackgroundHandler (package:bokun_spize/services/notification_service.dart:25:41)
    //       <asynchronous suspension>
    //       #3      _firebaseMessagingCallbackDispatcher.<anonymous closure> (package:firebase_messaging_platform_interface/src/method_channel/method_channel_messaging.dart:47:9)
    //       <asynchronous suspension>
    //       #4      MethodChannel._handleAsMethodCall (package:flutter/src/services/platform_channel.dart:607:42)
    //       <asynchronous suspension>
    //       #5      _DefaultBinaryMessenger.setMessageHandler.<anonymous closure> (package:flutter/src/services/binding.dart:664:22)
    //       <asynchronous suspension>
    //
    // Logged this `data` and got this: `Heyy -> {}`

    log('Heyy -> $data');

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
