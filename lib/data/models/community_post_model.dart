class CommunityPostModel {
  final String id;
  final String title;
  final String content;
  final String authorName;
  final bool isMine;
  final bool likedByMe;
  final int likeCount;
  final int commentCount;
  final String status;
  final DateTime createdAt;

  CommunityPostModel({
    required this.id,
    required this.title,
    required this.content,
    required this.authorName,
    this.isMine = false,
    this.likedByMe = false,
    this.likeCount = 0,
    this.commentCount = 0,
    this.status = 'PUBLISHED',
    required this.createdAt,
  });

  factory CommunityPostModel.fromJson(Map<String, dynamic> json) {
    return CommunityPostModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      authorName: (json['authorName'] ?? 'Ibu').toString(),
      isMine: json['isMine'] == true,
      likedByMe: json['likedByMe'] == true,
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
      status: (json['status'] ?? 'PUBLISHED').toString(),
      createdAt:
          DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }

  CommunityPostModel copyWith({
    bool? likedByMe,
    int? likeCount,
    int? commentCount,
  }) {
    return CommunityPostModel(
      id: id,
      title: title,
      content: content,
      authorName: authorName,
      isMine: isMine,
      likedByMe: likedByMe ?? this.likedByMe,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      status: status,
      createdAt: createdAt,
    );
  }

  String get authorInitial {
    final name = authorName.trim();
    if (name.isEmpty) return 'I';
    return name.substring(0, 1).toUpperCase();
  }
}
