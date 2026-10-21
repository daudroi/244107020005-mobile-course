# Praktikum 4 - Networking dan REST API

Project Flutter ini berisi implementasi codelab Week 4 mulai dari konfigurasi Dio, repository pattern, Riverpod `AsyncValue`, tampilan state loading/error/empty/success, pagination repository, sampai AI Prompt Challenge endpoint comments.

## Identitas

| Data | Keterangan |
|---|---|
| Nama | Achmad Daud Roichan |
| NIM | 244107020005 |
| Mata kuliah | Mobile Programming |
| Praktikum | Praktikum 4 - Networking dan REST API |

## Ringkasan Project

- Mengambil data posts dari JSONPlaceholder endpoint `GET /posts`.
- Mengambil data comments dari JSONPlaceholder endpoint `GET /comments?postId=1` sebagai bagian AI Challenge.
- Konfigurasi Dio dipusatkan di `lib/data/api_client.dart`.
- UI tidak memanggil Dio langsung; akses data melewati repository dan provider.
- State asynchronous ditangani dengan Riverpod `AsyncNotifier` dan `FutureProvider`.
- Aplikasi menampilkan state loading, error dengan tombol `Coba lagi`, empty, dan success.
- Repository posts memiliki method pagination `fetchPostsPage(page, limit)`.

## Struktur Project

```text
week4_api/
|-- lib/
|   |-- main.dart
|   |-- data/
|   |   |-- api_client.dart
|   |   |-- providers.dart
|   |   |-- models/
|   |   |   |-- post.dart
|   |   |   |-- comment.dart
|   |   |-- repositories/
|   |       |-- post_repository.dart
|   |       |-- comment_repository.dart
|   |-- pages/
|       |-- post_list_page.dart
|       |-- comment_list_page.dart
|-- screenshoot/
|   |-- posts.png
|   |-- comments.png
|-- test/
|   |-- widget_test.dart
|   |-- comment_test.dart
```

## Dokumentasi Screenshot

Halaman daftar posts dari endpoint `/posts`:

![Halaman Posts API](screenshoot/posts.png)

Halaman comments hasil AI Challenge dari endpoint `/comments?postId=1`:

![Halaman Comments Post 1](screenshoot/comments.png)

## Fitur Utama

- `Post.fromJson` dan `Comment.fromJson` memakai cast aman null agar tidak crash saat field hilang.
- `createDio()` mengatur `baseUrl`, timeout 10 detik, header `Accept: application/json`, dan `LogInterceptor`.
- `PostRepository` menyediakan `fetchPosts()` dan `fetchPostsPage()`.
- `CommentRepository` menyediakan `fetchComments(postId)`.
- `friendlyErrorMessage()` memetakan timeout, connection error, 404, 401/403, certificate error, cancel, dan error umum menjadi pesan pengguna.
- Bottom navigation memisahkan halaman `Posts` dan `Comments`.

## AI Prompt Challenge

Prompt challenge yang dikerjakan:

```text
Buatkan repository layer Flutter untuk endpoint GET /comments?postId={id}
dari JSONPlaceholder menggunakan Dio + flutter_riverpod.
Requirements:
- Model Comment dengan fromJson aman null (postId, id, name, email, body).
- CommentRepository dengan method fetchComments(postId) + timeout 10 detik.
- AsyncNotifierProvider dengan penanganan error otomatis (AsyncError)
  dan fungsi pesan error ramah pengguna untuk timeout, connection error, 404, dan 500.
- Satu unit test untuk fromJson dengan field yang hilang.
```

Hasil implementasi:

| Requirement | Status | File |
|---|---|---|
| Model `Comment` aman null | Selesai | `lib/data/models/comment.dart` |
| Repository `fetchComments(postId)` | Selesai | `lib/data/repositories/comment_repository.dart` |
| Provider comments | Selesai | `lib/data/providers.dart` |
| Pesan error ramah pengguna | Selesai | `lib/data/providers.dart` |
| Unit test field hilang | Selesai | `test/comment_test.dart` |

Catatan: timeout 10 detik dibuat terpusat pada Dio client, sehingga dipakai oleh posts dan comments.

## Cara Menjalankan

```powershell
cd 04-week-4-networking-rest-api/week4_api
flutter pub get
flutter run
```

Untuk membuka tab Comments langsung pada web:

```powershell
flutter run -d chrome --web-port 54641
```

Lalu buka:

```text
http://localhost:54641/?tab=comments
```

## Uji Skenario

1. Jalankan aplikasi dengan internet normal, amati loading lalu daftar posts tampil.
2. Buka tab `Comments`, pastikan komentar post 1 tampil.
3. Matikan internet atau ubah sementara `baseUrl` menjadi URL salah.
4. Tekan refresh, pastikan pesan error ramah pengguna dan tombol `Coba lagi` muncul.
5. Kembalikan koneksi atau `baseUrl`, lalu tekan `Coba lagi`.

## Verifikasi

Perintah yang sudah dijalankan:

```powershell
dart format lib test
flutter analyze
flutter test
flutter build web --web-renderer html
```

Hasil terakhir:

```text
flutter analyze: No issues found!
flutter test: All tests passed!
flutter build web: Success
```

App juga sudah dijalankan di Chrome dan request berikut berhasil dengan status `200`:

```text
GET https://jsonplaceholder.typicode.com/posts
GET https://jsonplaceholder.typicode.com/comments?postId=1
```

## Referensi

- [Codelab Week 4 - Networking & REST API](https://jti-polinema.github.io/flutter-codelab/04-minggu-4-networking-rest-api/)
- [JSONPlaceholder](https://jsonplaceholder.typicode.com/)
- [Dio package](https://pub.dev/packages/dio)
- [Riverpod](https://riverpod.dev/)
