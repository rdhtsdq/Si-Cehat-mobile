/// Who authored a chat message.
enum ChatRole { user, assistant }

/// One turn of the "Tanya Si Cehat" conversation.
///
/// The conversation lives only in memory (see `ChatProvider`); the whole thread
/// is re-sent on every turn so the backend stays stateless for the mobile flow.
class ChatMessage {
  final ChatRole role;
  final String content;

  const ChatMessage({required this.role, required this.content});

  const ChatMessage.user(this.content) : role = ChatRole.user;

  const ChatMessage.assistant(this.content) : role = ChatRole.assistant;

  bool get isUser => role == ChatRole.user;

  /// Serializes to the wire format accepted by `POST /api/chat`.
  Map<String, dynamic> toJson() => {
    'role': isUser ? 'user' : 'assistant',
    'content': content,
  };

  @override
  String toString() => 'ChatMessage(${role.name}: $content)';
}
