import 'package:flutter/foundation.dart';
import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';
import '../data/models/chat_message.dart';

/// Transport seam so tests can drive the provider without HTTP.
typedef ChatTransport = Future<ApiResponse> Function(Map<String, dynamic> body);

/// In-memory state for the "Tanya Si Cehat" chat tab.
///
/// The backend is stateless for this flow: every send re-posts the tail of the
/// thread, which is why no session is loaded on open.
class ChatProvider extends ChangeNotifier {
  ChatProvider({ChatTransport? transport})
    : _transport = transport ?? _defaultTransport;

  static const int maxHistory = 20;
  static const int maxMessageLength = 1000;

  static Future<ApiResponse> _defaultTransport(Map<String, dynamic> body) {
    return ApiClient.instance.post(ApiConstants.chat, body: body);
  }

  final ChatTransport _transport;
  final List<ChatMessage> _messages = [];

  bool _isSending = false;
  String? _error;
  bool _isQuotaExceeded = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isEmpty => _messages.isEmpty;
  bool get hasMessages => _messages.isNotEmpty;
  bool get isSending => _isSending;
  String? get error => _error;

  /// True when the last failure was the daily quota (HTTP 429).
  bool get isQuotaExceeded => _isQuotaExceeded;

  /// Sends [text] and appends the assistant reply.
  ///
  /// Returns `true` when a reply was appended, `false` when the send was
  /// skipped or the request failed (see [error]).
  Future<bool> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isSending) return false;

    // The backend rejects content longer than 1000 characters.
    final content = trimmed.length > maxMessageLength
        ? trimmed.substring(0, maxMessageLength)
        : trimmed;

    _messages.add(ChatMessage.user(content));
    _error = null;
    _isQuotaExceeded = false;
    _isSending = true;
    notifyListeners();

    try {
      final response = await _transport({'messages': _historyPayload()});

      if (response.isSuccess) {
        _appendReply(response.data);
      } else {
        _error = response.errorMessage ?? 'Gagal menghubungi Si Cehat.';
        _isQuotaExceeded = response.statusCode == 429;
      }
    } catch (e) {
      debugPrint('[ChatProvider] send failed: $e');
      _error = 'Terjadi kesalahan. Coba lagi ya.';
    } finally {
      _isSending = false;
      notifyListeners();
    }

    return _error == null;
  }

  void clearError() {
    if (_error == null && !_isQuotaExceeded) return;
    _error = null;
    _isQuotaExceeded = false;
    notifyListeners();
  }

  void clearConversation() {
    if (_messages.isEmpty && _error == null) return;
    _messages.clear();
    _error = null;
    _isQuotaExceeded = false;
    _isSending = false;
    notifyListeners();
  }

  List<Map<String, dynamic>> _historyPayload() {
    final start = _messages.length > maxHistory
        ? _messages.length - maxHistory
        : 0;
    return _messages.sublist(start).map((m) => m.toJson()).toList();
  }

  void _appendReply(dynamic data) {
    final Object? raw = data is Map ? data['message'] : null;
    final reply = raw?.toString().trim() ?? '';
    if (reply.isEmpty) {
      _error = 'Si Cehat tidak mengirim balasan. Coba lagi ya.';
      return;
    }
    _messages.add(ChatMessage.assistant(reply));
  }
}
