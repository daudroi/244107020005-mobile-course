# Praktikum 3 - Navigation dan State Management

Project Flutter ini berisi aplikasi ToDo pada folder `week3_todo`. Praktikum berfokus pada navigasi menggunakan GoRouter dan pengelolaan state menggunakan Riverpod, termasuk simulasi state asynchronous `loading`, `error`, dan `data`.

## Identitas

| Data | Keterangan |
|---|---|
| Nama | Achmad Daud Roichan |
| NIM | 244107020005 |
| Mata kuliah | Mobile Programming |
| Praktikum | Praktikum 3 - Navigation dan State Management |

## Tujuan

- Membuat aplikasi ToDo dengan state terpusat.
- Memisahkan widget dan logika agar mudah diuji.
- Menerapkan navigasi dua halaman dengan GoRouter.
- Memahami tiga state `AsyncValue` pada proses asynchronous.
- Memverifikasi hasil implementasi dengan analyzer dan widget test.

## Fitur

- Menambah, mencentang, dan menghapus tugas.
- Provider turunan `incompleteTodoProvider` untuk menghitung tugas yang belum selesai.
- Halaman daftar ToDo pada route `/`.
- Halaman statistik pada route `/stats`.
- NavigationBar untuk berpindah antara daftar dan statistik.
- Statistik asynchronous dengan simulasi loading selama 2 detik.
- Tampilan error dan tombol `Coba lagi` yang menjalankan `ref.invalidate(statsProvider)`.
- Widget test untuk alur menambah tugas.

## Struktur Project

```text
03-week-3-navigation-state-management/
|-- README.md
|-- screenshots/
|-- week3_todo/
|   |-- lib/
|   |   |-- main.dart
|   |   |-- pages/
|   |   |   |-- todo_page.dart
|   |   |   |-- stats_page.dart
|   |   |-- providers/
|   |   |   |-- todo_provider.dart
|   |   |   |-- stats_provider.dart
|   |   |-- widgets/
|   |       |-- todo_tile.dart
|   |-- test/
|       |-- widget_test.dart
```

## Dokumentasi Screenshot

Folder `screenshots/` sekarang berisi dua screenshot lama dan tiga screenshot baru dari aplikasi `week3_todo`:

| File saat ini | Isi | Status |
|---|---|---|
| `screenshots/home.png` | Halaman `Home` dengan `Item 1` sampai `Item 10` | Contoh navigasi lama, bukan UI ToDo final |
| `screenshots/detail.png` | Halaman `Detail 1` pada route `/detail/1` | Contoh detail lama, bukan route aplikasi saat ini |
| `screenshots/todo-home.png` | Halaman utama `ToDo Riverpod` pada route `/` | Screenshot baru dari aplikasi ToDo |
| `screenshots/statistik.png` | Percobaan dokumentasi route statistik | Perlu dicek ulang manual karena browser debug mempertahankan tampilan halaman ToDo |
| `screenshots/stats-success.png` | Percobaan dokumentasi route statistik setelah menunggu proses async | Perlu dicek ulang manual karena browser debug mempertahankan tampilan halaman ToDo |

Kedua file tersebut sebaiknya diganti atau dilengkapi dengan screenshot dari aplikasi `week3_todo`. Rekomendasi nama dan isi screenshot:

| Prioritas | Nama file yang direkomendasikan | Isi yang perlu terlihat |
|---|---|---|
| 1 | `screenshots/todo-home.png` | Route `/`, minimal satu tugas, checkbox, tombol tambah, dan jumlah tugas belum selesai |
| 2 | `screenshots/stats-success.png` | Route `/stats` setelah loading selesai dan data statistik tampil |
| Tambahan | `screenshots/statistik.png` | Route `/stats` saat indikator loading 2 detik sedang tampil |
| Tambahan | `screenshots/stats-error.png` | Pesan error statistik dan tombol `Coba lagi` setelah simulasi error diaktifkan |

Jika hanya boleh mengumpulkan dua screenshot, gunakan `todo-home.png` dan `statistik.png`. Untuk melengkapi dokumentasi state `AsyncValue`, ambil juga `stats-error.png` secara manual dari halaman `/stats`. Pada percobaan otomatis saat ini, route `/stats` masih mempertahankan tampilan ToDo sehingga screenshot statistik perlu diverifikasi sebelum dikumpulkan.

## Stack Teknologi

- Flutter dan Dart
- Riverpod `flutter_riverpod`
- GoRouter `go_router`
- Material 3
- Flutter Test

## Cara Menjalankan

```powershell
cd week3_todo
flutter pub get
flutter run
```

## Uji Tiga State

1. Jalankan aplikasi, buka halaman `Statistik`, dan amati indikator loading selama sekitar 2 detik.
2. Untuk menguji error secara deterministik, buka `week3_todo/lib/providers/stats_provider.dart` dan ubah sementara isi `build()` setelah `Future.delayed` menjadi:

   ```dart
   throw Exception('Gagal terhubung ke server');
   ```

3. Jalankan ulang aplikasi. Halaman statistik harus menampilkan pesan error dan tombol `Coba lagi`.
4. Tekan `Coba lagi`. Pemanggilan `ref.invalidate(statsProvider)` menjalankan provider kembali.
5. Hapus kembali baris `throw`, jalankan aplikasi, dan pastikan data statistik tampil.

Kode saat ini sudah dikembalikan ke perilaku normal. Provider statistik juga memiliki peluang error acak 30% untuk membantu mengamati state error tanpa mengubah kode.

## Hasil Cross-check AI

| Pemeriksaan | Hasil | Temuan |
|---|---|---|
| State immutable | Lulus | Penambahan memakai list spread, toggle membuat salinan list dan `Todo.copyWith`, penghapusan membuat list baru. Tidak ada `state.add()` atau mutasi state langsung. |
| `ref.watch` dan `ref.read` | Lulus | `ref.watch` dipakai di `build()` pada halaman/provider turunan. `ref.read` dipakai pada callback tambah, toggle, dan hapus. |
| Tiga state `AsyncValue` | Lulus | `StatsPage` menangani `loading`, `error`, dan `data` melalui `.when(...)`. |
| Tipe provider eksplisit | Lulus | `NotifierProvider<TodoListNotifier, List<Todo>>`, `Provider<List<Todo>>`, dan `AsyncNotifierProvider<StatsNotifier, List<String>>` dideklarasikan eksplisit. Tidak ada provider duplikat untuk state yang sama. |
| API Riverpod lama | Lulus | Kode menggunakan `Notifier`, `AsyncNotifier`, `ConsumerWidget`, dan `ProviderScope`; tidak menggunakan `StateProvider` atau `StateNotifierProvider` usang. |
| Pemisahan `TodoTile` | Lulus | Widget baris ToDo berada di `lib/widgets/todo_tile.dart`. |
| Filter turunan | Lulus | `incompleteTodoProvider` membaca `todoListProvider` dan menghasilkan daftar tugas belum selesai. Hasilnya dipakai sebagai jumlah tugas pada AppBar. |
| GoRouter | Lulus | Route `/` dan `/stats` tersedia, dengan `NavigationBar` untuk perpindahan halaman. |
| ProviderScope root | Lulus | `main()` membungkus `MyApp` dengan `const ProviderScope`. |
| Test | Lulus | Test menambah tugas menggunakan `ProviderScope`, dialog, input, dan tombol `Tambah`. |

### Catatan batasan

- Project memiliki route utama `/` dan route statistik `/`; belum ada route detail tugas terpisah. Akses langsung ke `/stats` didukung oleh GoRouter.
- `context.go` dipakai untuk perpindahan top-level karena mengganti lokasi halaman. `context.push` belum diperlukan karena belum ada halaman detail yang perlu ditumpuk di atas halaman sebelumnya.
- Provider statistik saat refresh menampilkan state loading baru. Untuk aplikasi produksi, data lama dapat dipertahankan sambil menampilkan indikator refresh agar layar tidak berkedip atau kosong.
- `ProductPage` dan `productsProvider` adalah contoh tambahan yang tidak didaftarkan pada router utama.

## Refleksi

### Mengapa stale data dengan indikator refresh bisa lebih baik?

Mengosongkan layar ketika refresh membuat pengguna kehilangan konteks dan terlihat seperti aplikasi belum memiliki data. Menampilkan data lama sambil memberi indikator refresh mempertahankan konteks, membuat UI terasa lebih cepat, dan mengurangi kedipan layar.

Pola ini penting untuk dashboard, daftar transaksi, inbox, monitoring, dan halaman yang sering diperbarui ketika data lama masih berguna. Data lama harus diberi penanda bahwa sedang diperbarui dan tidak boleh dianggap sebagai hasil terbaru sampai request selesai.

### Kapan `setState` masih cukup?

`setState` cukup untuk state lokal dan sederhana, misalnya membuka dialog, mengubah pilihan tab pada satu widget, atau mengatur animasi. Riverpod lebih tepat ketika state dipakai beberapa halaman/widget, perlu diuji tanpa bergantung pada context, atau berasal dari proses asynchronous.

### Perbedaan `context.go` dan `context.push`

`context.go('/stats')` mengubah lokasi tujuan utama dan cocok untuk NavigationBar. `context.push('/detail')` menambahkan halaman baru ke stack sehingga tombol back kembali ke halaman sebelumnya. Karena project ini belum memiliki halaman detail, `context.go` sudah sesuai untuk dua route top-level yang tersedia.

### Mengapa `AsyncValue` lebih aman daripada tiga boolean?

`AsyncValue` menyatukan data, loading, dan error dalam satu state yang saling konsisten. Tiga boolean terpisah dapat menghasilkan kombinasi tidak valid, misalnya `isLoading == true` sekaligus `hasError == true` tanpa aturan yang jelas. Pola `AsyncValue.when` memaksa UI menangani seluruh keadaan yang relevan.

### Perbaikan terhadap hasil AI

Perbaikan yang dilakukan setelah cross-check:

- Menghapus parameter `retry` pada `ProviderScope` karena tidak tersedia pada versi Riverpod project ini.
- Mengganti test bawaan counter yang tidak sesuai aplikasi dan tidak memakai `ProviderScope`.
- Menambahkan `incompleteTodoProvider` dengan transformasi list immutable.
- Menyesuaikan tampilan jumlah tugas dengan API `AppBar` yang tersedia pada Flutter SDK lokal.
- Menambahkan `pumpAndSettle()` pada test agar animasi dialog selesai sebelum assertion.

## Verifikasi

Perintah dijalankan dari folder `week3_todo`:

```powershell
flutter analyze
flutter test
```

Hasil terakhir:

```text
flutter analyze: No issues found!
flutter test: All tests passed!
```

## Referensi

- [Slide Navigation & State Management](https://jti-polinema.github.io/flutter-codelab/00-slides/Week_03_Navigation_State_Management.html)
- [Flutter Navigation](https://docs.flutter.dev/ui/navigation)
- [GoRouter](https://pub.dev/packages/go_router)
- [Riverpod Getting Started](https://riverpod.dev/docs/introduction/getting_started)
- [Riverpod AsyncNotifier dan AsyncValue](https://riverpod.dev/docs/concepts/async_notifiers)
- [Learn Dart in Y Minutes](https://learnxinyminutes.com/docs/dart/)
