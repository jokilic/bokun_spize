import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// Return info about device running the app
Future<String?> getDeviceInfo() async {
  try {
    final deviceInfo = DeviceInfoPlugin();

    if (kIsWeb) {
      final webBrowserInfo = await deviceInfo.webBrowserInfo;
      return webBrowserInfo.userAgent;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.name;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.name;
    }

    return null;
  } catch (e) {
    return null;
  }
}
