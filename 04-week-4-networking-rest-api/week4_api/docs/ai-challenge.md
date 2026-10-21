# AI Challenge Week 4

## Prompt

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

## Hasil

- `Comment` dibuat di `lib/data/models/comment.dart`.
- `CommentRepository` dibuat di `lib/data/repositories/comment_repository.dart`.
- Provider comments ditambahkan sebagai `commentListProvider` di `lib/data/providers.dart`.
- UI comments dibuat di `lib/pages/comment_list_page.dart`.
- Test parsing dan error mapping dibuat di `test/comment_test.dart`.

## Verifikasi

```text
flutter analyze: No issues found!
flutter test: All tests passed!
```
