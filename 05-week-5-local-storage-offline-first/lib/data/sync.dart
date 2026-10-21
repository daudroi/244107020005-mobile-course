import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'local/db.dart';
import 'repositories/note_repository.dart';

class CachedPost {
  const CachedPost({
    required this.id,
    required this.title,
    required this.body,
    required this.cachedAt,
  });

  final int id;
  final String title;
  final String body;
  final DateTime cachedAt;

  factory CachedPost.fromJson(Map<String, dynamic> json) {
    return CachedPost(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      cachedAt: DateTime.now(),
    );
  }
}

Future<int> syncNotes(NoteRepository repo) async {
  final dirtyCount = await repo.countDirty();
  if (dirtyCount == 0) return 0;
  // Simulasi upload: kirim setiap catatan dirty ke server
  await Future.delayed(const Duration(seconds: 1));
  await repo.markAllSynced();
  return dirtyCount;
}

final List<CachedPost> _webCachedPosts = [
  CachedPost(
    id: 1,
    title: 'sunt aut facere repellat provident occaecati excepturi',
    body: 'quia et suscipit suscipit recusandae consequuntur expedita et cum',
    cachedAt: DateTime.now(),
  ),
  CachedPost(
    id: 2,
    title: 'qui est esse',
    body: 'est rerum tempore vitae sequi sint nihil reprehenderit dolor beatae',
    cachedAt: DateTime.now(),
  ),
  CachedPost(
    id: 3,
    title: 'ea molestias quasi exercitationem repellat qui ipsa sit aut',
    body: 'et iusto sed quo iure voluptatem occaecati omnis eligendi aut ad',
    cachedAt: DateTime.now(),
  ),
];

Future<List<CachedPost>> readCachedPosts({
  Future<Database> Function()? openDb,
}) async {
  if (kIsWeb) {
    return List.of(_webCachedPosts);
  }
  final db = await (openDb ?? openNotesDb)();
  final rows = await db.query('cached_posts', orderBy: 'id ASC');
  return rows.map((r) {
    final payloadStr = r['payload'] as String? ?? '{}';
    final payload = jsonDecode(payloadStr) as Map<String, dynamic>;
    final cachedAt = DateTime.tryParse(r['cached_at'] as String? ?? '') ??
        DateTime.now();
    return CachedPost(
      id: (r['id'] as num?)?.toInt() ?? 0,
      title: payload['title'] as String? ?? '',
      body: payload['body'] as String? ?? '',
      cachedAt: cachedAt,
    );
  }).toList();
}

Future<void> saveCachedPosts(
  List<Map<String, dynamic>> posts, {
  Future<Database> Function()? openDb,
}) async {
  if (kIsWeb) return;
  final db = await (openDb ?? openNotesDb)();
  final batch = db.batch();
  final nowStr = DateTime.now().toIso8601String();
  for (final post in posts) {
    final id = (post['id'] as num?)?.toInt() ?? 0;
    batch.insert(
      'cached_posts',
      {
        'id': id,
        'payload': jsonEncode(post),
        'cached_at': nowStr,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  await batch.commit(noResult: true);
}

Future<List<CachedPost>> loadPostsCacheFirst({
  Dio? dio,
  Future<Database> Function()? openDb,
  bool forceOffline = false,
  void Function()? onBackgroundRefreshed,
}) async {
  final cached = await readCachedPosts(openDb: openDb);

  if (!forceOffline) {
    _refreshPostsInBackground(
      dio: dio,
      openDb: openDb,
      onComplete: onBackgroundRefreshed,
    );
  }

  return cached;
}

void _refreshPostsInBackground({
  Dio? dio,
  Future<Database> Function()? openDb,
  void Function()? onComplete,
}) {
  Future<void>(() async {
    try {
      final client = dio ??
          Dio(BaseOptions(
            baseUrl: 'https://jsonplaceholder.typicode.com',
            connectTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 5),
          ));
      final response = await client.get('/posts?_limit=10');
      if (response.statusCode == 200 && response.data is List) {
        final list = (response.data as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        await saveCachedPosts(list, openDb: openDb);
        onComplete?.call();
      }
    } catch (_) {
      // Abaikan error pada background refresh agar UI cache tidak crash
    }
  });
}
