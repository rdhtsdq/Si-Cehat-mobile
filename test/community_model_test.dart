import 'package:flutter_test/flutter_test.dart';
import 'package:si_cehat_mobile/data/models/community_post_model.dart';
import 'package:si_cehat_mobile/data/models/community_comment_model.dart';

void main() {
  group('CommunityPostModel', () {
    test('parses a full JSON payload', () {
      final post = CommunityPostModel.fromJson({
        'id': 'p1',
        'title': 'Tips Sehat',
        'content': 'Isi postingan.',
        'authorName': 'Ibu R***',
        'isMine': true,
        'likedByMe': false,
        'likeCount': 5,
        'commentCount': 2,
        'status': 'PUBLISHED',
        'createdAt': '2026-11-14T10:00:00.000Z',
      });

      expect(post.id, 'p1');
      expect(post.title, 'Tips Sehat');
      expect(post.authorName, 'Ibu R***');
      expect(post.isMine, isTrue);
      expect(post.likeCount, 5);
      expect(post.commentCount, 2);
      expect(post.authorInitial, 'I');
    });

    test('defaults missing fields safely', () {
      final post = CommunityPostModel.fromJson({'id': 'x'});
      expect(post.title, '');
      expect(post.authorName, 'Ibu');
      expect(post.isMine, isFalse);
      expect(post.likedByMe, isFalse);
      expect(post.likeCount, 0);
      expect(post.commentCount, 0);
    });

    test('copyWith toggles like fields', () {
      final post = CommunityPostModel.fromJson({
        'id': 'p1',
        'title': 'T',
        'content': 'C',
        'authorName': 'Ibu R***',
        'likeCount': 3,
        'commentCount': 1,
        'createdAt': '2026-11-14T10:00:00.000Z',
      });

      final liked = post.copyWith(likedByMe: true, likeCount: 4);
      expect(liked.likedByMe, isTrue);
      expect(liked.likeCount, 4);
      expect(liked.commentCount, 1);
      expect(liked.id, 'p1');
    });
  });

  group('CommunityCommentModel', () {
    test('parses a comment', () {
      final comment = CommunityCommentModel.fromJson({
        'id': 'c1',
        'postId': 'p1',
        'content': 'Komentar.',
        'authorName': 'Ibu R***',
        'isMine': true,
        'createdAt': '2026-11-14T10:00:00.000Z',
      });

      expect(comment.id, 'c1');
      expect(comment.postId, 'p1');
      expect(comment.content, 'Komentar.');
      expect(comment.isMine, isTrue);
      expect(comment.authorInitial, 'I');
    });
  });
}
