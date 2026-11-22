import 'package:flutter/foundation.dart';

class AppConstants {
  static const String appName = 'Smart H-EAT';
  static const String appTagline = 'Smart H-EAT';
  static const String operatorMode = 'OPERATOR MODE';

  // Base API URLs
  static const String apiBaseUrlMobile = 'http://10.0.2.2:8000/api';
  static const String apiBaseUrlDesktop = 'http://127.0.0.1:8000/api';

  /// Resolves the correct base URL based on the runtime platform
  static String get baseUrl {
    if (kIsWeb) {
      return apiBaseUrlDesktop;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return apiBaseUrlMobile;
    }
    return apiBaseUrlDesktop;
  }
}
