import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient.instance;

  bool _isLoading = true;
  bool _hasSeenOnboarding = false;
  bool _isLoggedIn = false;
  bool _isDemoMode = false;
  String? _currentUserEmail;
  String? _currentUserName;

  bool get isLoading => _isLoading;
  bool get hasSeenOnboarding => _hasSeenOnboarding;
  bool get isLoggedIn => _isLoggedIn;
  bool get isDemoMode => _isDemoMode;
  String? get currentUserEmail => _currentUserEmail;
  String? get currentUserName => _currentUserName;

  AuthProvider() {
    _loadState();
  }

  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
      final token = await _apiClient.getToken();

      if (token != null && token.isNotEmpty) {
        _isLoggedIn = true;
        _isDemoMode = false;
        final guardian = await _apiClient.getSavedGuardianData();
        if (guardian != null) {
          _currentUserEmail = guardian['email'] as String?;
          _currentUserName = guardian['name'] as String?;
        }
      } else {
        _isLoggedIn = prefs.getBool('is_logged_in') ?? false;
        _isDemoMode = prefs.getBool('is_demo_mode') ?? true;
      }
    } catch (_) {
      _hasSeenOnboarding = false;
      _isLoggedIn = false;
      _isDemoMode = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> completeOnboarding() async {
    _hasSeenOnboarding = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_seen_onboarding', true);
    } catch (_) {}
  }

  /// Real Backend Login via POST /api/auth/login
  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.post(
        ApiConstants.authLogin,
        body: {
          'identifier': identifier.trim(),
          'password': password.trim(),
        },
      );

      if (response.isSuccess && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final token = data['token'] as String?;
        final guardian = data['guardian'] as Map<String, dynamic>?;

        if (token != null) {
          await _apiClient.saveToken(token);
        }
        if (guardian != null) {
          await _apiClient.saveGuardianData(guardian);
          _currentUserEmail = guardian['email'] as String?;
          _currentUserName = guardian['name'] as String?;
        }

        _isLoggedIn = true;
        _isDemoMode = false;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);
        await prefs.setBool('is_demo_mode', false);

        _isLoading = false;
        notifyListeners();
        return {'success': true, 'guardian': guardian};
      } else {
        _isLoading = false;
        notifyListeners();
        return {
          'success': false,
          'message': response.errorMessage ?? 'Email atau kata sandi tidak valid.',
          'isOffline': response.isOffline,
        };
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Gagal menghubungkan ke server: $e'};
    }
  }

  /// Real Backend Register via POST /api/auth/register
  Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    String? childName,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.post(
        ApiConstants.authRegister,
        body: {
          'motherName': name.trim(),
          'name': name.trim(),
          'phone': phone.trim(),
          'email': email.trim(),
          'password': password.trim(),
          if (childName != null && childName.isNotEmpty) 'childName': childName.trim(),
        },
      );

      if (response.isSuccess && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final token = data['token'] as String?;
        final guardian = data['guardian'] as Map<String, dynamic>?;

        if (token != null) {
          await _apiClient.saveToken(token);
        }
        if (guardian != null) {
          await _apiClient.saveGuardianData(guardian);
          _currentUserEmail = guardian['email'] as String?;
          _currentUserName = guardian['name'] as String?;
        }

        _isLoggedIn = true;
        _isDemoMode = false;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);
        await prefs.setBool('is_demo_mode', false);

        _isLoading = false;
        notifyListeners();
        return {'success': true, 'guardian': guardian};
      } else {
        _isLoading = false;
        notifyListeners();
        return {
          'success': false,
          'message': response.errorMessage ?? 'Gagal mendaftar akun.',
          'isOffline': response.isOffline,
        };
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Gagal mendaftar: $e'};
    }
  }

  /// Offline / Simulated Demo Mode login
  Future<void> loginDemo({String identifier = '', String password = ''}) async {
    _isLoggedIn = true;
    _isDemoMode = true;
    _currentUserName = 'Ibu Rina (Mode Demo)';
    _currentUserEmail = 'demo@example.com';
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setBool('is_demo_mode', true);
    } catch (_) {}
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _isDemoMode = true;
    _currentUserName = null;
    _currentUserEmail = null;
    notifyListeners();
    try {
      await _apiClient.clearAuth();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', false);
      await prefs.setBool('is_demo_mode', true);
    } catch (_) {}
  }
}
