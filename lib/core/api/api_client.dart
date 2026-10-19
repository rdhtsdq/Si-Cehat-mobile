import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_constants.dart';

class ApiResponse {
  final bool isSuccess;
  final int statusCode;
  final dynamic data;
  final String? errorMessage;
  final bool isOffline;

  ApiResponse({
    required this.isSuccess,
    required this.statusCode,
    this.data,
    this.errorMessage,
    this.isOffline = false,
  });

  factory ApiResponse.success(dynamic data, {int statusCode = 200}) {
    return ApiResponse(isSuccess: true, statusCode: statusCode, data: data);
  }

  factory ApiResponse.failure(
    String message, {
    int statusCode = 400,
    bool isOffline = false,
  }) {
    return ApiResponse(
      isSuccess: false,
      statusCode: statusCode,
      errorMessage: message,
      isOffline: isOffline,
    );
  }
}

class ApiClient {
  static final ApiClient instance = ApiClient._internal();
  ApiClient._internal();

  static const String _tokenPrefKey = 'auth_jwt_token';
  static const String _cookiePrefKey = 'auth_session_cookie';
  static const String _guardianPrefKey = 'auth_guardian_data';

  String? _cachedToken;
  String? _cachedCookie;

  Future<String?> getToken() async {
    if (_cachedToken != null && _cachedToken!.isNotEmpty) return _cachedToken;
    try {
      final prefs = await SharedPreferences.getInstance();
      _cachedToken = prefs.getString(_tokenPrefKey);
      return _cachedToken;
    } catch (_) {
      return null;
    }
  }

  Future<String?> _getCookie() async {
    if (_cachedCookie != null && _cachedCookie!.isNotEmpty)
      return _cachedCookie;
    try {
      final prefs = await SharedPreferences.getInstance();
      _cachedCookie = prefs.getString(_cookiePrefKey);
      return _cachedCookie;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveToken(String token) async {
    _cachedToken = token;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenPrefKey, token);
    } catch (_) {}
  }

  Future<void> _saveCookie(String cookie) async {
    _cachedCookie = cookie;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cookiePrefKey, cookie);
    } catch (_) {}
  }

  Future<void> saveGuardianData(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_guardianPrefKey, jsonEncode(data));
    } catch (_) {}
  }

  Future<Map<String, dynamic>?> getSavedGuardianData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_guardianPrefKey);
      if (str != null) {
        return jsonDecode(str) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  Future<void> clearAuth() async {
    _cachedToken = null;
    _cachedCookie = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenPrefKey);
      await prefs.remove(_cookiePrefKey);
      await prefs.remove(_guardianPrefKey);
      await prefs.remove('active_child_id');
    } catch (_) {}
  }

  Uri _buildUri(String path, [Map<String, String>? queryParams]) {
    final base = ApiConstants.baseUrl;
    final fullUrl = '$base$path';
    final uri = Uri.parse(fullUrl);
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: queryParams);
    }
    return uri;
  }

  Future<Map<String, String>> _buildHeaders() async {
    final token = await getToken();
    final cookie = await _getCookie();
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json; charset=utf-8',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    if (cookie != null && cookie.isNotEmpty) {
      headers['Cookie'] = cookie;
    } else if (token != null && token.isNotEmpty) {
      headers['Cookie'] = 'sicehat_session=$token';
    }
    return headers;
  }

  void _captureResponseCookies(http.Response response) {
    final setCookie =
        response.headers['set-cookie'] ?? response.headers['Set-Cookie'];
    if (setCookie != null && setCookie.isNotEmpty) {
      final cookiePair = setCookie.split(';').first.trim();
      if (cookiePair.startsWith('sicehat_session=')) {
        _saveCookie(cookiePair);
        final tokenPart = cookiePair
            .substring('sicehat_session='.length)
            .trim();
        if (tokenPart.isNotEmpty) {
          saveToken(tokenPart);
        }
      }
    }

    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['token'] is String) {
          final t = (decoded['token'] as String).trim();
          if (t.isNotEmpty) {
            saveToken(t);
          }
        }
      } catch (_) {}
    }
  }

  Future<ApiResponse> get(
    String path, {
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = _buildUri(path, queryParams);
      final headers = await _buildHeaders();
      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 10));
      _captureResponseCookies(response);
      return _processResponse(response);
    } catch (e) {
      debugPrint('[ApiClient] GET $path error: $e');
      return ApiResponse.failure(
        'Tidak dapat terhubung ke server backend.',
        statusCode: 0,
        isOffline: true,
      );
    }
  }

  Future<ApiResponse> post(String path, {Map<String, dynamic>? body}) async {
    try {
      final uri = _buildUri(path);
      final headers = await _buildHeaders();
      final response = await http
          .post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 10));
      _captureResponseCookies(response);
      return _processResponse(response);
    } catch (e) {
      debugPrint('[ApiClient] POST $path error: $e');
      return ApiResponse.failure(
        'Tidak dapat terhubung ke server backend.',
        statusCode: 0,
        isOffline: true,
      );
    }
  }

  Future<ApiResponse> put(String path, {Map<String, dynamic>? body}) async {
    try {
      final uri = _buildUri(path);
      final headers = await _buildHeaders();
      final response = await http
          .put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 10));
      _captureResponseCookies(response);
      return _processResponse(response);
    } catch (e) {
      debugPrint('[ApiClient] PUT $path error: $e');
      return ApiResponse.failure(
        'Tidak dapat terhubung ke server backend.',
        statusCode: 0,
        isOffline: true,
      );
    }
  }

  Future<ApiResponse> patch(String path, {Map<String, dynamic>? body}) async {
    try {
      final uri = _buildUri(path);
      final headers = await _buildHeaders();
      final response = await http
          .patch(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 10));
      _captureResponseCookies(response);
      return _processResponse(response);
    } catch (e) {
      debugPrint('[ApiClient] PATCH $path error: $e');
      return ApiResponse.failure(
        'Tidak dapat terhubung ke server backend.',
        statusCode: 0,
        isOffline: true,
      );
    }
  }

  Future<ApiResponse> delete(String path) async {
    try {
      final uri = _buildUri(path);
      final headers = await _buildHeaders();
      final response = await http
          .delete(uri, headers: headers)
          .timeout(const Duration(seconds: 10));
      _captureResponseCookies(response);
      return _processResponse(response);
    } catch (e) {
      debugPrint('[ApiClient] DELETE $path error: $e');
      return ApiResponse.failure(
        'Tidak dapat terhubung ke server backend.',
        statusCode: 0,
        isOffline: true,
      );
    }
  }

  ApiResponse _processResponse(http.Response response) {
    dynamic decodedData;
    if (response.body.isNotEmpty) {
      try {
        decodedData = jsonDecode(response.body);
      } catch (_) {
        decodedData = response.body;
      }
    }

    final statusCode = response.statusCode;
    if (statusCode >= 200 && statusCode < 300) {
      return ApiResponse.success(decodedData, statusCode: statusCode);
    } else {
      String errorMsg = 'Permintaan gagal ($statusCode)';
      if (decodedData is Map && decodedData['error'] != null) {
        final err = decodedData['error'];
        if (err is Map && err['message'] != null) {
          errorMsg = err['message'].toString();
        } else if (err is String) {
          errorMsg = err;
        }
      }
      return ApiResponse.failure(errorMsg, statusCode: statusCode);
    }
  }
}
