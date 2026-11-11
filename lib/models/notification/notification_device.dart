import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationDevice {
  final String token;
  final String locale;
  final String timezone;
  final String appVersion;
  final String deviceInfo;

  const NotificationDevice({
    required this.token,
    required this.locale,
    required this.timezone,
    required this.appVersion,
    required this.deviceInfo,
  });

  Map<String, dynamic> toMap({Timestamp? createdAt}) => {
    'token': token,
    'locale': locale,
    'timezone': timezone,
    'appVersion': appVersion,
    'deviceInfo': deviceInfo,
    'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    'lastActiveAt': FieldValue.serverTimestamp(),
  };
}
