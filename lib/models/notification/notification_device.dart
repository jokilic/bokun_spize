import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationDevice {
  final String token;
  final String platform;
  final String locale;
  final String timezone;
  final String appVersion;
  final DateTime expiresAt;

  const NotificationDevice({
    required this.token,
    required this.platform,
    required this.locale,
    required this.timezone,
    required this.appVersion,
    required this.expiresAt,
  });

  Map<String, dynamic> toMap({
    required bool includeCreatedAt,
  }) => {
    'token': token,
    'platform': platform,
    'locale': locale,
    'timezone': timezone,
    'appVersion': appVersion,
    'updatedAt': FieldValue.serverTimestamp(),
    'lastActiveAt': FieldValue.serverTimestamp(),
    'expiresAt': Timestamp.fromDate(expiresAt),
    if (includeCreatedAt) 'createdAt': FieldValue.serverTimestamp(),
  };
}
