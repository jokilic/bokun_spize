import 'dart:convert';

class ContactMessage {
  final String message;
  final String userUid;
  final String userEmail;
  final String appVersion;
  final String platform;
  final DateTime createdAt;

  ContactMessage({
    required this.message,
    required this.userUid,
    required this.userEmail,
    required this.appVersion,
    required this.platform,
    required this.createdAt,
  });

  factory ContactMessage.fromMap(
    Map<String, dynamic> map, {
    required DateTime createdAt,
  }) => ContactMessage(
    message: map['message'],
    userUid: map['userUid'],
    userEmail: map['userEmail'],
    appVersion: map['appVersion'],
    platform: map['platform'],
    createdAt: createdAt,
  );

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() => {
    'message': message,
    'userUid': userUid,
    'userEmail': userEmail,
    'appVersion': appVersion,
    'platform': platform,
    'createdAt': createdAt.toIso8601String(),
  };

  @override
  String toString() => 'ContactMessage(message: $message, userUid: $userUid, userEmail: $userEmail, appVersion: $appVersion, platform: $platform, createdAt: $createdAt)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactMessage &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          userUid == other.userUid &&
          userEmail == other.userEmail &&
          appVersion == other.appVersion &&
          platform == other.platform &&
          createdAt == other.createdAt;

  @override
  int get hashCode => message.hashCode ^ userUid.hashCode ^ userEmail.hashCode ^ appVersion.hashCode ^ platform.hashCode ^ createdAt.hashCode;
}
