import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationDevice {
  final String fid;
  final String locale;
  final String timezone;
  final String appVersion;
  final String deviceInfo;

  const NotificationDevice({
    required this.fid,
    required this.locale,
    required this.timezone,
    required this.appVersion,
    required this.deviceInfo,
  });

  Map<String, dynamic> toMap({Timestamp? createdAt}) => {
    'fid': fid,
    'locale': locale,
    'timezone': timezone,
    'appVersion': appVersion,
    'deviceInfo': deviceInfo,
    'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    'lastActiveAt': FieldValue.serverTimestamp(),
  };
}
