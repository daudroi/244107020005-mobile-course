import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/comment.dart';
import 'package:week4_api/data/models/post.dart';
import 'package:week4_api/data/providers.dart';
import 'package:week4_api/data/repositories/comment_repository.dart';
import 'package:week4_api/data/repositories/post_repository.dart';
import 'package:week4_api/main.dart';

class FakePostRepository extends PostRepository {
  FakePostRepository()
      : super(
          Dio(),
        );

  @override
  Future<List<Post>> fetchPosts() async {
    return const [
      Post(userId: 1, id: 1, title: 'Belajar REST API', body: 'Dio + Riverpod'),
    ];
  }

  @override
  Future<List<Post>> fetchPostsPage({required int page, int limit = 10}) {
    return fetchPosts();
  }
}

class FakeCommentRepository extends CommentRepository {
  FakeCommentRepository()
      : super(
          Dio(),
        );

  @override
  Future<List<Comment>> fetchComments(int postId) async {
    return const [
      Comment(
        postId: 1,
        id: 1,
        name: 'Komentar pertama',
        email: 'tester@example.com',
        body: 'Isi komentar',
      ),
    ];
  }
}

void main() {
  testWidgets('shows posts page data from provider', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          postRepositoryProvider.overrideWithValue(FakePostRepository()),
          commentRepositoryProvider.overrideWithValue(FakeCommentRepository()),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pump();

    expect(find.text('Posts API'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Belajar REST API'), findsOneWidget);
    expect(find.text('Posts'), findsOneWidget);
    expect(find.text('Comments'), findsOneWidget);
  });
}
