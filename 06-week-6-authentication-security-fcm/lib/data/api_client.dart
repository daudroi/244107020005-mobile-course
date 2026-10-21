import 'package:dio/dio.dart';
import 'auth_repository.dart';
import 'token_store.dart';

Dio buildApiClient(TokenStore store, AuthRepository auth) {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://example-campus-api.test',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final access = await store.readAccess();
      if (access != null) {
        options.headers['Authorization'] = 'Bearer $access';
      }
      handler.next(options);
    },
    onError: (e, handler) async {
      if (e.response?.statusCode == 401) {
        final refresh = await store.readRefresh();
        if (refresh == null) return handler.next(e);
        try {
          // Segarkan access token menggunakan refresh token
          final renewed = await auth.refresh(refresh);
          await store.save(access: renewed, refresh: refresh);
          // Ulangi request satu kali dengan access token baru
          final options = e.requestOptions;
          options.headers['Authorization'] = 'Bearer $renewed';
          final retry = await dio.fetch(options);
          return handler.resolve(retry);
        } catch (_) {
          // Bila refresh token ikut mati/expired, bersihkan token dan paksa login ulang
          await store.clear();
        }
      }
      handler.next(e);
    },
  ));

  return dio;
}
