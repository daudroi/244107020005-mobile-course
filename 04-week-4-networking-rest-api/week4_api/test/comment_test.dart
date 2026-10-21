import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/comment.dart';
import 'package:week4_api/data/providers.dart';

void main() {
  test('Comment.fromJson aman terhadap field yang hilang', () {
    final comment = Comment.fromJson({'id': 9});

    expect(comment.id, 9);
    expect(comment.postId, 0);
    expect(comment.name, '');
    expect(comment.email, '');
    expect(comment.body, '');
  });

  test('friendlyErrorMessage menangani timeout', () {
    final error = DioException(
      requestOptions: RequestOptions(path: '/comments'),
      type: DioExceptionType.connectionTimeout,
    );

    expect(friendlyErrorMessage(error), contains('timeout'));
  });

  test('friendlyErrorMessage menangani 404', () {
    final error = DioException(
      requestOptions: RequestOptions(path: '/comments'),
      response: Response(
        requestOptions: RequestOptions(path: '/comments'),
        statusCode: 404,
      ),
      type: DioExceptionType.badResponse,
    );

    expect(friendlyErrorMessage(error), contains('404'));
  });
}
