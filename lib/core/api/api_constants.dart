import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiConstants {
  static const String _baseUrlPrefKey = 'custom_api_base_url';
  static const String defaultLanUrl = 'http://192.168.1.3:3000';

  static String? _customBaseUrl;

  /// Loads any previously saved custom API Base URL from SharedPreferences.
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_baseUrlPrefKey);
      if (saved != null && saved.trim().isNotEmpty) {
        _customBaseUrl = _normalizeUrl(saved.trim());
      }
    } catch (_) {}
  }

  static String _normalizeUrl(String url) {
    var trimmed = url.trim();
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      trimmed = 'http://$trimmed';
    }
    return trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
  }

  /// Allows changing and persisting the API Base URL dynamically (e.g. from Settings or for LAN IP testing)
  static Future<void> setCustomBaseUrl(String? url) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (url == null || url.trim().isEmpty) {
        _customBaseUrl = null;
        await prefs.remove(_baseUrlPrefKey);
      } else {
        final normalized = _normalizeUrl(url);
        _customBaseUrl = normalized;
        await prefs.setString(_baseUrlPrefKey, normalized);
      }
    } catch (_) {
      if (url == null || url.trim().isEmpty) {
        _customBaseUrl = null;
      } else {
        _customBaseUrl = _normalizeUrl(url);
      }
    }
  }

  static String get baseUrl {
    if (_customBaseUrl != null && _customBaseUrl!.isNotEmpty) {
      return _customBaseUrl!;
    }
    if (kIsWeb) {
      return 'http://localhost:3000';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      // LAN IP of this host machine on port 3000
      return defaultLanUrl;
    }
    return 'http://localhost:3000';
  }

  // Auth endpoints
  static const String authLogin = '/api/auth/login';
  static const String authRegister = '/api/auth/register';
  static const String authLogout = '/api/auth/logout';
  static const String authMe = '/api/auth/me';

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

  // Catalog, Meal Plan & Education
  static const String recipes = '/api/recipes';
  static const String mealPlan = '/api/meal-plan';
  static const String educationArticles = '/api/education/articles';
  static const String content = '/api/content';

  // Consultations & Notifications
  static const String specialists = '/api/consultations/specialists';
  static const String consultations = '/api/consultations';
  static const String notifications = '/api/notifications';
  static const String notificationsReadAll = '/api/notifications/read-all';

  // Profile Avatar
  static const String parentProfileAvatar = '/api/parent/profile/avatar';
}
