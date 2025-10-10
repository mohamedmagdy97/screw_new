import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

Future<String> getDeviceName() async {
  final deviceInfo = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    return '${androidInfo.brand} ${androidInfo.model}';
  } else if (Platform.isIOS) {
    final iosInfo = await deviceInfo.iosInfo;
    return '${iosInfo.name} (${iosInfo.model})';
  } else {
    return 'Unknown Device';
  }
}
