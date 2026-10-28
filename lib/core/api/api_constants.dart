import 'package:shared_preferences/shared_preferences.dart';

class ApiConstants {
  /// Production backend and web-game host. This is the default for every
  /// build, including debug, so `flutter run` talks to the real deployment.
  static const String productionUrl = 'https://sicehat.id';

  /// Convenience constant for local Android emulator testing.
  static const String defaultEmulatorUrl = 'http://10.0.2.2:3000';

  static const String _baseUrlPrefKey = 'custom_api_base_url';
  static String? _customBaseUrl;

  /// Loads a previously saved custom API base URL from SharedPreferences.
  /// Used for local/LAN testing without rebuilding the app.
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

  /// Allows changing and persisting the API base URL dynamically (e.g. for
  /// LAN IP testing or a debug settings screen).
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

    // Local override without touching source:
    //   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000
    const definedUrl = String.fromEnvironment('API_BASE_URL');
    if (definedUrl.isNotEmpty) {
      return _normalizeUrl(definedUrl);
    }

    return productionUrl;
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
  static const String trackerActivities = '/api/tracker/activities';
  static const String progress = '/api/progress';
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
  static String childAvatar(dynamic id) => '/api/children/$id/avatar';

  // Si-Cehat PlayLab (Mini-Game & Research)
  static const String games = '/api/games';
  static const String gameSessions = '/api/game-sessions';
  static String gameSessionEvents(String sessionId) =>
      '/api/game-sessions/$sessionId/events';
  static String gameSessionComplete(String sessionId) =>
      '/api/game-sessions/$sessionId/complete';
  static String gameSessionResult(String sessionId) =>
      '/api/game-sessions/$sessionId/result';

  /// Returns the base URL hosting the web game.
  /// Automatically derives the host and port from [baseUrl] (e.g. 192.168.x.x, 10.0.2.2, or localhost)
  /// so that when [baseUrl] is configured for physical device or emulator testing, the web game
  /// stays accessible and avoids 'net::ERR_CONNECTION_REFUSED' errors.
  static String get gameWebUrl {
    final baseUri = Uri.tryParse(baseUrl);
    if (baseUri != null && baseUri.hasAuthority) {
      final portPart = baseUri.hasPort ? ':${baseUri.port}' : '';
      return '${baseUri.scheme}://${baseUri.host}$portPart';
    }
    return baseUrl;
  }
}
