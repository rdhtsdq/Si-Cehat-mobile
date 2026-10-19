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
  Future<void>? _initFuture;

  bool get isLoading => _isLoading;
  bool get hasSeenOnboarding => _hasSeenOnboarding;
  bool get isLoggedIn => _isLoggedIn;
  bool get isDemoMode => _isDemoMode;
  String? get currentUserEmail => _currentUserEmail;
  String? get currentUserName => _currentUserName;

  AuthProvider() {
    _initFuture = _loadState();
  }

  Future<void> ensureInitialized() async {
    if (_initFuture != null) {
      await _initFuture;
    }
  }

  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
      final token = await _apiClient.getToken();

      if (token != null && token.isNotEmpty) {
        // Verify active session with backend if reachable
        final meRes = await _apiClient.get(ApiConstants.authMe);
        if (meRes.isSuccess && meRes.data is Map<String, dynamic>) {
          final data = meRes.data as Map<String, dynamic>;
          final user =
              (data['guardian'] ?? data['user']) as Map<String, dynamic>?;
          if (user != null && user['id'] != null) {
            await _apiClient.saveGuardianData(user);
            _currentUserEmail = user['email'] as String?;
            _currentUserName = user['name'] as String?;
            _isLoggedIn = true;
            _isDemoMode = false;
            await prefs.setBool('is_logged_in', true);
            await prefs.setBool('is_demo_mode', false);
          } else {
            // Session expired or user no longer exists on server
            await _apiClient.clearAuth();
            await prefs.setBool('is_logged_in', false);
            await prefs.setBool('is_demo_mode', false);
            _isLoggedIn = false;
            _isDemoMode = false;
          }
        } else if (meRes.statusCode == 401) {
          await _apiClient.clearAuth();
          await prefs.setBool('is_logged_in', false);
          await prefs.setBool('is_demo_mode', false);
          _isLoggedIn = false;
          _isDemoMode = false;
        } else {
          // Offline fallback: trust locally cached token & guardian data
          _isLoggedIn = true;
          _isDemoMode = false;
          final guardian = await _apiClient.getSavedGuardianData();
          if (guardian != null) {
            _currentUserEmail = guardian['email'] as String?;
            _currentUserName = guardian['name'] as String?;
          }
        }
      } else {
        final savedDemo = prefs.getBool('is_demo_mode') ?? false;
        final savedLogged = prefs.getBool('is_logged_in') ?? false;
        if (savedLogged && savedDemo) {
          _isLoggedIn = true;
          _isDemoMode = true;
          _currentUserName = 'Mode Demo';
        } else {
          _isLoggedIn = false;
          _isDemoMode = false;
        }
      }
    } catch (_) {
      _hasSeenOnboarding = false;
      _isLoggedIn = false;
      _isDemoMode = false;
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
      final trimmedId = identifier.trim();
      final response = await _apiClient.post(
        ApiConstants.authLogin,
        body: {
          'email': trimmedId,
          'identifier': trimmedId,
          'password': password.trim(),
        },
      );

      if (response.isSuccess && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final token = data['token'] as String?;
        final guardian =
            (data['guardian'] ?? data['user']) as Map<String, dynamic>?;

        if (token != null && token.isNotEmpty) {
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
          'message':
              response.errorMessage ?? 'Email atau kata sandi tidak valid.',
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
          if (childName != null && childName.isNotEmpty)
            'childName': childName.trim(),
        },
      );

      if (response.isSuccess && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final token = data['token'] as String?;
        final guardian =
            (data['guardian'] ?? data['user']) as Map<String, dynamic>?;

        if (token != null && token.isNotEmpty) {
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
    await _apiClient.clearAuth();
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
    try {
      await _apiClient.post(ApiConstants.authLogout);
    } catch (_) {}
    _isLoggedIn = false;
    _isDemoMode = false;
    _currentUserName = null;
    _currentUserEmail = null;
    notifyListeners();
    try {
      await _apiClient.clearAuth();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', false);
      await prefs.setBool('is_demo_mode', false);
    } catch (_) {}
  }
}
