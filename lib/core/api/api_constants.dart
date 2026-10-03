import 'package:flutter/foundation.dart';

class ApiConstants {
  static String? _customBaseUrl;

  /// Allows changing the API Base URL dynamically (e.g. from Settings or for LAN IP testing)
  static void setCustomBaseUrl(String url) {
    _customBaseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  static String get baseUrl {
    if (_customBaseUrl != null && _customBaseUrl!.isNotEmpty) {
      return _customBaseUrl!;
    }
    if (kIsWeb) {
      return 'http://localhost:3000';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Android emulator loopback to host PC
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  // Auth endpoints
  static const String authLogin = '/api/auth/login';
  static const String authRegister = '/api/auth/register';

  // Parent / Family endpoints
  static const String parentProfile = '/api/parent/profile';
  static const String children = '/api/children';

  // Health tracker & screening
  static const String trackerGrowth = '/api/tracker/growth';
  static const String screening = '/api/screening';
  static const String reminders = '/api/reminders';

  // Nutrition & Food Diary
  static const String foodDiary = '/api/food-diary';
  static const String nutritionCalculate = '/api/nutrition/calculate';

  // Catalog & Education
  static const String recipes = '/api/recipes';
  static const String educationArticles = '/api/education/articles';
  static const String content = '/api/content';

  // Consultations
  static const String specialists = '/api/consultations/specialists';
  static const String consultations = '/api/consultations';
}
