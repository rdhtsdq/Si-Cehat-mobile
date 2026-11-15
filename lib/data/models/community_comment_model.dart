class CommunityCommentModel {
  final String id;
  final String postId;
  final String content;
  final String authorName;
  final bool isMine;
  final DateTime createdAt;

  CommunityCommentModel({
    required this.id,
    required this.postId,
    required this.content,
    required this.authorName,
    this.isMine = false,
    required this.createdAt,
  });

  factory CommunityCommentModel.fromJson(Map<String, dynamic> json) {
    return CommunityCommentModel(
      id: (json['id'] ?? '').toString(),
      postId: (json['postId'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      authorName: (json['authorName'] ?? 'Ibu').toString(),
      isMine: json['isMine'] == true,
      createdAt:
          DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }

  String get authorInitial {
    final name = authorName.trim();
    if (name.isEmpty) return 'I';
    return name.substring(0, 1).toUpperCase();
  }
}
