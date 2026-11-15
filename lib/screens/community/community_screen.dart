import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/models/community_post_model.dart';
import '../../providers/app_providers.dart';
import 'community_post_detail_screen.dart';
import 'community_create_post_screen.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  static const List<String> _tabs = ['Semua', 'Populer', 'Saya'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(communityProvider).loadFeed(refresh: true);
    });
  }

  bool get _canWrite {
    final auth = ref.read(authProvider);
    return auth.isLoggedIn && !auth.isDemoMode;
  }

  void _showLoginPrompt() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
        title: const Text('Masuk Diperlukan'),
        content: const Text(
          'Masuk dengan akun asli untuk ikut berdiskusi di komunitas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  Future<void> _onLike(CommunityPostModel post) async {
    if (!_canWrite) {
      _showLoginPrompt();
      return;
    }
    final error = await ref.read(communityProvider).toggleLike(post);
    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  Future<void> _onCreate() async {
    if (!_canWrite) {
      _showLoginPrompt();
      return;
    }
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const CommunityCreatePostScreen()),
    );
    if (created == true) {
      await ref.read(communityProvider).loadFeed(refresh: true);
    }
  }

  void _openDetail(CommunityPostModel post) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CommunityPostDetailScreen(post: post),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(communityProvider);
    final posts = provider.posts;
    final activeTab = provider.activeTab;
    final isLoading = provider.isLoading;
    final isLoadingMore = provider.isLoadingMore;
    final error = provider.error;
    final hasMore = provider.hasMore;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Komunitas',
          style: AppTypography.headingScreen.copyWith(fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  for (var i = 0; i < _tabs.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Expanded(
                      child: _buildTabButton(
                        title: _tabs[i],
                        isActive: activeTab == i,
                        onTap: () => ref.read(communityProvider).switchTab(i),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: _buildBody(
                  posts,
                  isLoading,
                  isLoadingMore,
                  error,
                  hasMore,
                  activeTab,
                ),
              ),
              PrimaryButton(
                text: '+ Buat Postingan',
                onPressed: _onCreate,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    List<CommunityPostModel> posts,
    bool isLoading,
    bool isLoadingMore,
    String? error,
    bool hasMore,
    int activeTab,
  ) {
    if (isLoading && posts.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (error != null && posts.isEmpty) {
      return _CenteredMessage(
        icon: Icons.cloud_off_outlined,
        message: error,
        actionLabel: 'Coba Lagi',
        onAction: () => ref.read(communityProvider).loadFeed(refresh: true),
      );
    }

    if (posts.isEmpty) {
      return _CenteredMessage(
        icon: Icons.forum_outlined,
        message: activeTab == 2
            ? 'Belum ada postingan kamu.'
            : 'Belum ada postingan. Jadilah yang pertama berbagi tips!',
        actionLabel: null,
        onAction: null,
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => ref.read(communityProvider).loadFeed(refresh: true),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: posts.length + (hasMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == posts.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: TextButton(
                onPressed: isLoadingMore
                    ? null
                    : () => ref.read(communityProvider).loadFeed(),
                child: isLoadingMore
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : const Text('Muat lebih banyak'),
              ),
            );
          }
          final post = posts[index];
          return _PostCard(
            post: post,
            onLike: () => _onLike(post),
            onTap: () => _openDetail(post),
          );
        },
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isActive ? AppColors.primary : AppColors.fieldBackground,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 42,
          alignment: Alignment.center,
          child: Text(
            title,
            style: AppTypography.buttonText.copyWith(
              color: isActive ? Colors.white : AppColors.textDark,
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final CommunityPostModel post;
  final VoidCallback onLike;
  final VoidCallback onTap;

  const _PostCard({
    required this.post,
    required this.onLike,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.fieldBackground,
      borderRadius: AppRadius.card,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.card,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: AppRadius.card,
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                    child: Text(
                      post.authorInitial,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGreenDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.authorName,
                          style: AppTypography.bodySecondary.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          _relativeTime(post.createdAt),
                          style: AppTypography.micro,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                post.title,
                style: AppTypography.titleCard.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                post.content,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySecondary.copyWith(
                  fontSize: 13,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  InkWell(
                    onTap: onLike,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            post.likedByMe
                                ? Icons.thumb_up_alt
                                : Icons.thumb_up_alt_outlined,
                            size: 15,
                            color: post.likedByMe
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${post.likeCount}',
                            style: AppTypography.bodySecondary.copyWith(
                              fontSize: 11,
                              fontWeight:
                                  post.likedByMe ? FontWeight.w700 : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Icon(
                    Icons.chat_bubble_outline,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${post.commentCount}',
                    style: AppTypography.bodySecondary.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _relativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 30) return '${diff.inDays} hari lalu';
    return '${time.day}/${time.month}/${time.year}';
  }
}

class _CenteredMessage extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _CenteredMessage({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodySecondary,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: onAction,
                child: Text(
                  actionLabel!,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
