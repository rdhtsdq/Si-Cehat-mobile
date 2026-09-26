import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = true;
  bool _hasSeenOnboarding = false;
  bool _isLoggedIn = false;
  bool _isDemoMode = true;

  bool get isLoading => _isLoading;
  bool get hasSeenOnboarding => _hasSeenOnboarding;
  bool get isLoggedIn => _isLoggedIn;
  bool get isDemoMode => _isDemoMode;

  AuthProvider() {
    _loadState();
  }

  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
      _isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      _isDemoMode = prefs.getBool('is_demo_mode') ?? true;
    } catch (_) {
      // Fallback
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

  Future<void> loginDemo({String identifier = '', String password = ''}) async {
    _isLoggedIn = true;
    _isDemoMode = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setBool('is_demo_mode', true);
    } catch (_) {}
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', false);
    } catch (_) {}
  }
}
