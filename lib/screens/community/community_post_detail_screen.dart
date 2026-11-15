import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/models/community_post_model.dart';
import '../../data/models/community_comment_model.dart';
import '../../providers/app_providers.dart';

class CommunityPostDetailScreen extends ConsumerStatefulWidget {
  final CommunityPostModel post;

  const CommunityPostDetailScreen({super.key, required this.post});

  @override
  ConsumerState<CommunityPostDetailScreen> createState() =>
      _CommunityPostDetailScreenState();
}

class _CommunityPostDetailScreenState
    extends ConsumerState<CommunityPostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(communityProvider)
          .loadComments(widget.post.id, refresh: true);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
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

  Future<void> _onLike() async {
    if (!_canWrite) {
      _showLoginPrompt();
      return;
    }
    final error = await ref.read(communityProvider).toggleLike(widget.post);
    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _deletePost() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
        title: const Text('Hapus Postingan?'),
        content: const Text(
          'Postingan beserta komentarnya akan dihapus permanen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hapus', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final error = await ref.read(communityProvider).deletePost(widget.post.id);
    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _deleteComment(CommunityCommentModel comment) async {
    final error = await ref
        .read(communityProvider)
        .deleteComment(widget.post.id, comment.id);
    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _sendComment() async {
    if (!_canWrite) {
      _showLoginPrompt();
      return;
    }
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    setState(() => _sending = true);
    final error = await ref.read(communityProvider).addComment(
          widget.post.id,
          content,
        );
    setState(() => _sending = false);

    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(communityProvider);
    final comments = provider.comments;
    final post = widget.post;

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
          'Diskusi',
          style: AppTypography.headingScreen.copyWith(fontSize: 20),
        ),
        actions: [
          if (post.isMine)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') _deletePost();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'delete', child: Text('Hapus Postingan')),
              ],
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 8.0,
                ),
                children: [
                  _PostBody(post: post, onLike: _onLike),
                  const SizedBox(height: 20),
                  Text(
                    'Diskusi (${post.commentCount})',
                    style: AppTypography.titleCard.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (provider.isLoadingComments && comments.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                    )
                  else if (comments.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'Belum ada komentar. Jadilah yang pertama!',
                          style: AppTypography.bodySecondary,
                        ),
                      ),
                    )
                  else
                    for (final comment in comments)
                      _CommentTile(
                        comment: comment,
                        onDelete: comment.isMine
                            ? () => _deleteComment(comment)
                            : null,
                      ),
                  if (provider.hasMoreComments)
                    TextButton(
                      onPressed: () =>
                          ref.read(communityProvider).loadComments(post.id),
                      child: const Text('Muat komentar lainnya'),
                    ),
                ],
              ),
            ),
            _CommentInput(
              controller: _commentController,
              sending: _sending,
              onSend: _sendComment,
              onLoginRequired: _showLoginPrompt,
            ),
          ],
        ),
      ),
    );
  }
}

class _PostBody extends StatelessWidget {
  final CommunityPostModel post;
  final VoidCallback onLike;

  const _PostBody({required this.post, required this.onLike});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.fieldBackground,
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
                child: Text(
                  post.authorName,
                  style: AppTypography.bodySecondary.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            post.title,
            style: AppTypography.titleCard.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            post.content,
            style: AppTypography.bodyRegular.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              InkWell(
                onTap: onLike,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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
                        '${post.likeCount} Dukungan',
                        style: AppTypography.bodySecondary.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final CommunityCommentModel comment;
  final VoidCallback? onDelete;

  const _CommentTile({required this.comment, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.fieldBackground,
        borderRadius: AppRadius.card,
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            child: Text(
              comment.authorInitial,
              style: const TextStyle(
                fontSize: 10,
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
                  comment.authorName,
                  style: AppTypography.bodySecondary.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  comment.content,
                  style: AppTypography.bodyRegular.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          if (onDelete != null)
            IconButton(
              visualDensity: VisualDensity.compact,
              iconSize: 16,
              icon: const Icon(Icons.delete_outline, color: AppColors.textSecondary),
              onPressed: onDelete,
              tooltip: 'Hapus komentar',
            ),
        ],
      ),
    );
  }
}

class _CommentInput extends StatelessWidget {
  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;
  final VoidCallback onLoginRequired;

  const _CommentInput({
    required this.controller,
    required this.sending,
    required this.onSend,
    required this.onLoginRequired,
  });

  @override
  Widget build(BuildContext context) {
    final canWrite = !sending;
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: Color(0xFFE8EFEB))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: 'Tulis komentar...',
                hintStyle: AppTypography.bodySecondary,
                filled: true,
                fillColor: AppColors.greyCard,
                border: OutlineInputBorder(
                  borderRadius: AppRadius.input,
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: canWrite ? onSend : onLoginRequired,
            icon: sending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : const Icon(Icons.send_rounded, color: AppColors.primary),
            tooltip: 'Kirim',
          ),
        ],
      ),
    );
  }
}
