# AI Prompt Challenge & Verification: Clean Architecture (Feature-First)

## 1. Prompt yang Digunakan

```text
Project Flutter saya: campus_notify (auth + FCM + daftar pengumuman).
Kondisi kini: folder lib/{data, providers, pages, messaging},
repository tercampur dengan implementasi, widget memanggil Dio langsung.
Tugas:
1. Usulkan struktur feature-first Clean Architecture
   (presentation/domain/data) untuk fitur auth + announcements.
2. Untuk tiap file lama, sebutkan tujuan barunya (pindah/pecah/hapus).
3. Tandai bagian yang over-engineering bila diterapkan ke CRUD sederhana,
   dan kapan use case benar-benar dibutuhkan vs repository langsung.
4. Tunjukkan wiring DI dengan Riverpod (tanpa package DI tambahan).
Jelaskan trade-off setiap keputusan.
```

---

## 2. Tabel Pemetaan File: Struktur Lama vs Clean Architecture Target

| File Lama | Tujuan Baru di Clean Architecture | Alasan Arsitektural |
|---|---|---|
| `data/models/note.dart` | Dipecah menjadi:<br>1. `features/notes/domain/entities/note.dart`<br>2. `features/notes/data/models/note_model.dart` | Memisahkan entitas bisnis murni dari serialisasi database (`toMap/fromMap`). Domain tidak boleh terikat format SQLite atau JSON. |
| `data/repositories/note_repository.dart` | Dipecah menjadi:<br>1. `features/notes/domain/repositories/note_repository.dart` (Interface)<br>2. `features/notes/data/repositories/note_repository_impl.dart` (Implementasi) | Mematuhi **Dependency Inversion Principle** (DIP): domain menentukan kontrak (interface), layer data yang mengimplementasikan detail teknisnya. |
| `data/providers.dart` | Dipindahkan ke `features/notes/presentation/providers/notes_providers.dart` | Menjaga modularitas *feature-first*: provider milik fitur notes tidak boleh bercampur dengan konfigurasi global atau fitur lain. |
| Logika validasi CRUD di Notifier | Dibuatkan Use Case di `domain/usecases/`: `AddNote`, `GetNotes`, `DeleteNote` | Logika aturan bisnis (misalnya: judul catatan tidak boleh kosong) hidup di domain, dapat diuji murni tanpa widget atau Riverpod. |
| Formatting tanggal di Widget | Dipindahkan ke `core/format.dart` | Mematuhi **Single Responsibility Principle** (SRP): widget hanya merender UI, helper murni terbebas dari siklus hidup widget. |

---

## 3. Analisis Over-Engineering vs Kapan Use Case Dibutuhkan

| Skenario Operasi | Rekomendasi Alur | Alasan Teknis |
|---|---|---|
| **CRUD Sederhana 1-Baris** (misal: `deleteNote(id)`) | **Boleh Langsung Notifier -> Repository** | Membuat kelas Use Case terpisah hanya untuk memanggil 1 baris method repository tanpa validasi adalah *over-engineering* bagi tim kecil yang menambah kompleksitas berkas tanpa nilai bisnis nyata. |
| **Operasi dengan Validasi Bisnis** (misal: `addNote`) | **Wajib Use Case** | Memastikan aturan bisnis (judul minimal panjang tertentu, sanitasi input) tidak bocor ke presentation dan dapat diuji dalam hitungan milidetik pada unit test. |
| **Operasi Agregasi Multi-Repository** (misal: `SyncNotes`) | **Sangat Wajib Use Case** | Menggabungkan data dari `NoteRepository` dan `RemoteApiRepository` serta menerapkan aturan resolusi konflik (*Last-Write-Wins*) harus dipusatkan di Use Case, bukan di widget. |

---

## 4. AI Verification Checklist & Temuan Teknis

| Pemeriksaan | Status Evaluasi | Bukti Verifikasi |
|---|---|---|
| **Interface di Domain, Impl di Data** | **LULUS** | `NoteRepository` adalah abstract interface di `domain/repositories/`. Implementasi konkret `NoteRepositoryImpl` berada di `data/repositories/`. |
| **Domain Bebas Import Framework (Steril)** | **LULUS** | Pemeriksaan grep pada seluruh folder `domain` membuktikan **0 import** dari `flutter`, `dio`, `sqflite`, maupun `firebase`. Domain 100% pure Dart. |
| **Entity Bebas Mapping** | **LULUS** | `Note` di domain hanya berisi properti immutable. Seluruh method `toMap()`, `fromMap()`, dan `toEntity()` hanya ada di `NoteModel` pada data layer. |
| **Dependency Injection Terpusat via Riverpod** | **LULUS** | Seluruh dependensi disuntikkan lewat `Provider<NoteRepository>` dan `Provider<GetNotes>`. Widget presentation tidak pernah memanggil keyword `new` untuk repositori. |
| **Keputusan Final** | **DISETUJUI** | Menerapkan Clean Architecture feature-first untuk dua fitur penuh (`notes` dan `announcements`), membuktikan fleksibilitas dan pemisahan tanggung jawab yang teruji. |
