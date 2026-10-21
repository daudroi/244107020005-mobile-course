import 'package:dio/dio.dart';

String friendlyErrorMessage(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Waktu koneksi habis. Silakan periksa jaringan internet Anda.';
      case DioExceptionType.connectionError:
        return 'Gagal terhubung ke server kampus. Periksa koneksi internet Anda.';
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        if (code == 401) {
          return 'Sesi login telah kedaluwarsa. Silakan masuk kembali.';
        } else if (code == 403) {
          return 'Akses ditolak. Anda tidak memiliki izin untuk pengumuman ini.';
        } else if (code == 404) {
          return 'Pengumuman yang dicari tidak ditemukan.';
        } else if (code != null && code >= 500) {
          return 'Terjadi gangguan internal pada server kampus ($code).';
        }
        return 'Respons server tidak valid ($code).';
      case DioExceptionType.cancel:
        return 'Permintaan dibatalkan.';
      default:
        return 'Terjadi kendala jaringan: ${error.message ?? 'Unknown'}';
    }
  }
  return error.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
}
