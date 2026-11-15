import 'package:flutter/foundation.dart';
import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';
import '../data/models/community_post_model.dart';
import '../data/models/community_comment_model.dart';

class CommunityProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient.instance;

  static const int _pageSize = 20;

  // Feed state
  int _activeTab = 0; // 0: Semua, 1: Populer, 2: Saya
  final List<CommunityPostModel> _posts = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = false;
  bool _initialized = false;
  String? _error;
  int _offset = 0;

  // Detail state
  final List<CommunityCommentModel> _comments = [];
  bool _isLoadingComments = false;
  bool _hasMoreComments = false;
  String? _commentsError;
  int _commentsOffset = 0;

  int get activeTab => _activeTab;
  List<CommunityPostModel> get posts => List.unmodifiable(_posts);
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  bool get initialized => _initialized;
  String? get error => _error;

  List<CommunityCommentModel> get comments => List.unmodifiable(_comments);
  bool get isLoadingComments => _isLoadingComments;
  bool get hasMoreComments => _hasMoreComments;
  String? get commentsError => _commentsError;

  String get _currentTabKey => switch (_activeTab) {
        1 => 'popular',
        2 => 'mine',
        _ => 'all',
      };

  /// Switches the visible tab and (re)loads its first page.
  Future<void> switchTab(int tab) async {
    if (tab == _activeTab && _initialized && _posts.isNotEmpty) return;
    _activeTab = tab;
    _posts.clear();
    _initialized = false;
    _offset = 0;
    _hasMore = false;
    _error = null;
    notifyListeners();
    await loadFeed(refresh: true);
  }

  Future<void> loadFeed({bool refresh = false}) async {
    if (_isLoading || _isLoadingMore) return;
    if (refresh) {
      _isLoading = true;
      _offset = 0;
    } else {
      _isLoadingMore = true;
    }
    _error = null;
    notifyListeners();

    final res = await _apiClient.get(
      ApiConstants.communityPosts,
      queryParams: {
        'tab': _currentTabKey,
        'limit': '$_pageSize',
        'offset': '$_offset',
      },
    );

    if (res.isSuccess && res.data is Map) {
      final data = res.data as Map<String, dynamic>;
      final rawList = data['posts'] as List<dynamic>? ?? const [];
      final list = rawList
          .whereType<Map<String, dynamic>>()
          .map(CommunityPostModel.fromJson)
          .toList();

      if (refresh) {
        _posts
          ..clear()
          ..addAll(list);
      } else {
        // De-duplicate in case of overlapping pages.
        final existingIds = _posts.map((p) => p.id).toSet();
        _posts.addAll(list.where((p) => !existingIds.contains(p.id)));
      }
      _hasMore = data['hasMore'] == true;
      _offset += list.length;
      _initialized = true;
    } else {
      _error = res.errorMessage ?? 'Gagal memuat komunitas.';
    }

    _isLoading = false;
    _isLoadingMore = false;
    notifyListeners();
  }

  void _applyLike(String postId, bool likedByMe, int likeCount) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;
    _posts[index] = _posts[index].copyWith(
      likedByMe: likedByMe,
      likeCount: likeCount,
    );
    notifyListeners();
  }

  /// Optimistically toggles a like and reverts on failure. Returns an error
  /// message, or null on success.
  Future<String?> toggleLike(CommunityPostModel post) async {
    final nextLiked = !post.likedByMe;
    final nextCount = post.likeCount + (nextLiked ? 1 : -1);
    _applyLike(post.id, nextLiked, nextCount);

    final res = await _apiClient.post(ApiConstants.communityLikeToggle(post.id));
    if (res.isSuccess && res.data is Map) {
      final data = res.data as Map<String, dynamic>;
      final liked = data['liked'] == true;
      final count = (data['likeCount'] as num?)?.toInt() ?? nextCount;
      _applyLike(post.id, liked, count);
      return null;
    }

    // Revert on failure.
    _applyLike(post.id, post.likedByMe, post.likeCount);
    return res.errorMessage ?? 'Gagal memperbarui dukungan.';
  }

  /// Creates a post. Returns an error message, or null on success.
  Future<String?> createPost(String title, String content) async {
    final res = await _apiClient.post(
      ApiConstants.communityPosts,
      body: {'title': title, 'content': content},
    );
    if (res.isSuccess) {
      await loadFeed(refresh: true);
      return null;
    }
    return res.errorMessage ?? 'Gagal membuat postingan.';
  }

  void _bumpCommentCount(String postId, int delta) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;
    _posts[index] = _posts[index].copyWith(
      commentCount: (_posts[index].commentCount + delta).clamp(0, 1 << 30),
    );
    notifyListeners();
  }

  Future<void> loadComments(String postId, {bool refresh = false}) async {
    if (_isLoadingComments) return;
    _isLoadingComments = true;
    if (refresh) _commentsOffset = 0;
    _commentsError = null;
    notifyListeners();

    final res = await _apiClient.get(
      ApiConstants.communityPostComments(postId),
      queryParams: {
        'limit': '$_pageSize',
        'offset': '$_commentsOffset',
      },
    );

    if (res.isSuccess && res.data is Map) {
      final data = res.data as Map<String, dynamic>;
      final rawList = data['comments'] as List<dynamic>? ?? const [];
      final list = rawList
          .whereType<Map<String, dynamic>>()
          .map(CommunityCommentModel.fromJson)
          .toList();
      if (refresh) {
        _comments
          ..clear()
          ..addAll(list);
      } else {
        _comments.addAll(list);
      }
      _hasMoreComments = data['hasMore'] == true;
      _commentsOffset += list.length;
    } else {
      _commentsError = res.errorMessage ?? 'Gagal memuat komentar.';
    }

    _isLoadingComments = false;
    notifyListeners();
  }

  /// Adds a comment. Returns an error message, or null on success.
  Future<String?> addComment(String postId, String content) async {
    final res = await _apiClient.post(
      ApiConstants.communityPostComments(postId),
      body: {'content': content},
    );
    if (res.isSuccess && res.data is Map) {
      final data = res.data as Map<String, dynamic>;
      final rawComment = data['comment'];
      if (rawComment is Map<String, dynamic>) {
        _comments.add(CommunityCommentModel.fromJson(rawComment));
      }
      _bumpCommentCount(postId, 1);
      return null;
    }
    return res.errorMessage ?? 'Gagal menambahkan komentar.';
  }

  /// Deletes the user's own post. Returns an error message, or null on success.
  Future<String?> deletePost(String postId) async {
    final res = await _apiClient.delete(ApiConstants.communityPost(postId));
    if (res.isSuccess) {
      _posts.removeWhere((p) => p.id == postId);
      notifyListeners();
      return null;
    }
    return res.errorMessage ?? 'Gagal menghapus postingan.';
  }

  /// Deletes the user's own comment. Returns an error message, or null on success.
  Future<String?> deleteComment(String postId, String commentId) async {
    final res = await _apiClient.delete(ApiConstants.communityComment(commentId));
    if (res.isSuccess) {
      _comments.removeWhere((c) => c.id == commentId);
      _bumpCommentCount(postId, -1);
      return null;
    }
    return res.errorMessage ?? 'Gagal menghapus komentar.';
  }
}
