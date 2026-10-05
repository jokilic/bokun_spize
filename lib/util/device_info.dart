import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

import '../models/contact_message/android_device_data.dart';
import '../models/contact_message/ios_device_data.dart';

/// Return the Android model, iOS machine identifier, or web user agent
Future<String?> getDeviceInfo() async {
  try {
    final deviceInfo = DeviceInfoPlugin();

    if (kIsWeb) {
      final webBrowserInfo = await deviceInfo.webBrowserInfo;
      return webBrowserInfo.userAgent;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidInfo = await deviceInfo.androidInfo;

      return AndroidDeviceData(
        brand: androidInfo.brand,
        device: androidInfo.device,
        manufacturer: androidInfo.manufacturer,
        model: androidInfo.model,
        name: androidInfo.name,
      ).toJson();
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosInfo = await deviceInfo.iosInfo;

      return IOSDeviceData(
        localizedModel: iosInfo.localizedModel,
        model: iosInfo.model,
        modelName: iosInfo.modelName,
        name: iosInfo.name,
        systemName: iosInfo.systemName,
      ).toJson();
    }

    return null;
  } catch (e) {
    return null;
  }
}
