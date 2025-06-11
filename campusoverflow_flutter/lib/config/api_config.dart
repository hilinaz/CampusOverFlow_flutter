import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  static String get baseUrl {
    // For Android emulator, use 10.0.2.2 to access host machine
    // For physical device, use your computer's IP address
    const String emulatorIp = '10.0.2.2';
    const String physicalDeviceIp =
        '192.168.61.168'; // User's specific IP address

    if (kIsWeb) {
      // For web platform, localhost refers to the host machine
      return 'http://localhost:5500/api';
    } else if (Platform.isAndroid) {
      // Check if running on emulator or physical device
      if (Platform.environment.containsKey('ANDROID_EMULATOR')) {
        return 'http://$emulatorIp:5500/api';
      } else {
        return 'http://$physicalDeviceIp:5500/api';
      }
    } else if (Platform.isIOS) {
      // For iOS simulator, use localhost
      // For physical iOS device, use the host machine's IP
      if (Platform.environment.containsKey('IOS_SIMULATOR')) {
        return 'http://localhost:5500/api';
      } else {
        return 'http://$physicalDeviceIp:5500/api';
      }
    } else {
      // For desktop platforms (Windows, macOS, Linux)
      return 'http://localhost:5500/api';
    }
  }
}
