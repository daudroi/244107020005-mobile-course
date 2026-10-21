# AI Prompt Challenge & Verification: Local Storage & Offline-First

## 1. Prompt yang Digunakan

```text
Aplikasi Flutter Offline Notes: CRUD catatan + preferensi tema.
Bandingkan SharedPreferences, Hive, sqflite (SQLite), dan Drift
untuk dua kebutuhan ini. Requirements:
- Kriteria: kompleksitas query, kebutuhan relasi, reaktivitas (stream),
  type-safety, ukuran boilerplate, dan kemudahan testing.
- Beri rekomendasi final: mana untuk preferensi, mana untuk catatan,
  beserta alasannya dalam 1 tabel.
- Tunjukkan skema tabel/kotak untuk 1000+ catatan.
Jelaskan trade-off setiap pilihan.
```

---

## 2. Tabel Perbandingan Pilihan Storage

| Kriteria | SharedPreferences | Hive | sqflite (SQLite) | Drift (Moor) |
|---|---|---|---|---|
| **Paradigma** | Key-Value primitif | NoSQL Key-Value / Box | Relasional SQL | Relasional Type-Safe (SQL generator) |
| **Kompleksitas Query** | Sangat rendah (hanya `get/set` per key) | Rendah (filter in-memory/box index) | Tinggi (SELECT, WHERE, JOIN, ORDER, GROUP, COUNT) | Sangat tinggi (type-safe query builder, Dart DSL) |
| **Kebutuhan Relasi** | Tidak mendukung | Manual linking via ID / reference | Kuat (Foreign Key, JOIN, indexing) | Kuat (Foreign Key, type-safe join & relations) |
| **Reaktivitas (Stream)** | Tidak ada (butuh manual wrapper) | Ada (`box.watch()`) | Tidak bawaan (butuh Riverpod / StreamController) | Sangat kuat (bawaan stream `watch()`) |
| **Type-Safety** | Rendah (casting manual String/int/bool) | Menengah (TypeAdapter code-gen) | Menengah (mapping Map<String, Object?>) | Sangat tinggi (kompilasi memverifikasi kolom & query) |
| **Ukuran Boilerplate** | Sangat kecil (siap pakai) | Sedang (TypeAdapter registration) | Sedang (SQL string, migrasi manual) | Besar (build_runner, *.g.dart, setup schema) |
| **Kemudahan Testing** | Sangat mudah (Mock / in-memory map) | Mudah (in-memory test directory) | Mudah dengan Fake repository / in-memory SQLite | Mudah (in-memory database Drift) |
| **Performa 1000+ Data** | Buruk jika JSON besar diserialisasi sekaligus | Cepat untuk read, memori terikat ukuran box | Sangat cepat & efisien (pagination, index B-Tree) | Sangat cepat (index, pagination, lazy stream) |

---

## 3. Skema Penyimpanan untuk 1000+ Catatan

### Skema SQLite (Pilihan Utama: `sqflite`)
```sql
CREATE TABLE notes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  body TEXT NOT NULL DEFAULT '',
  updated_at TEXT NOT NULL,
  dirty INTEGER NOT NULL DEFAULT 0
);

-- Indeks untuk mendukung query sorting dan sync queue berkinerja tinggi
CREATE INDEX idx_notes_updated_at ON notes(updated_at DESC);
CREATE INDEX idx_notes_dirty ON notes(dirty);

-- Tabel cache data jaringan
CREATE TABLE cached_posts (
  id INTEGER PRIMARY KEY,
  payload TEXT NOT NULL,
  cached_at TEXT NOT NULL
);
```

### Skema Hive Box (Alternatif NoSQL)
```dart
@HiveType(typeId: 0)
class NoteBoxItem extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String body;

  @HiveField(3)
  DateTime updatedAt;

  @HiveField(4)
  bool dirty;
}
```

---

## 4. AI Verification Checklist

| Pemeriksaan | Hasil Evaluasi | Catatan Analisis |
|---|---|---|
| **Apakah AI menempatkan daftar catatan di SharedPreferences?** | **DITOLAK** | AI sempat mengusulkan opsi menyimpan JSON string array catatan di SharedPreferences untuk simplisitas awal. Ini ditolak tegas karena membuat query parsial, sorting 1000+ catatan, dan update flag dirty menjadi rapuh dan memboroskan memori. |
| **Apakah skema AI mendukung antrean sync (dirty flag / updated_at)?** | **LULUS (Diperbaiki)** | Output awal AI hanya memiliki kolom CRUD biasa (`id`, `title`, `body`). Kami menambahkan kolom `updated_at TEXT NOT NULL` dan `dirty INTEGER NOT NULL DEFAULT 0` dengan indeks terpisah agar antrean sinkronisasi offline-first dapat berjalan deterministik. |
| **Apakah klaim "real-time" AI didukung stream atau asumsi?** | **DIVERIFIKASI** | Klaim real-time hanya valid bawaan pada Drift (`select().watch()`) dan Hive (`box.watch()`). Pada `sqflite`, reaktivitas dicapai melalui Riverpod state management (`ref.invalidate(notesProvider)` setelah mutasi data), bukan stream database langsung. |
| **Apakah estimasi boilerplate AI masuk akal?** | **DIVERIFIKASI** | Drift memiliki boilerplate terbesar karena memerlukan `drift`, `drift_dev`, dan `build_runner`. Untuk scope mata kuliah dan timeline praktikum, `sqflite` memberikan rasio terbaik antara kontrol SQL murni dan kesederhanaan setup tanpa code-gen. |
| **Keputusan Final** | **DISETUJUI** | **SharedPreferences** untuk preferensi sederhana (tema gelap, timestamp terakhir dibuka, status simulasi offline), dan **SQLite (`sqflite`)** untuk data catatan berelasi dan dirty flag offline-first. |

---

## 5. Keputusan Teknis Final & Justifikasi

1. **Preferensi: `SharedPreferences`**
   - Kebutuhan: Menyimpan 3 key sederhana: `dark_mode` (boolean), `force_offline` (boolean), dan `last_opened_at` (String ISO-8601).
   - Alasan: Sangat ringan, terintegrasi langsung dengan NSUserDefaults (iOS) dan SharedPreferences (Android), tanpa perlu skema atau DDL database.

2. **Catatan & Antrean Sinkronisasi: SQLite via `sqflite`**
   - Kebutuhan: Menyimpan catatan berstruktur, mendukung pengurutan waktu (`ORDER BY updated_at DESC`), penghitungan cepat catatan belum tersinkron (`COUNT(*) WHERE dirty = 1`), dan penyimpanan cache payload API eksternal (`cached_posts`).
   - Alasan: SQL adalah standar industri teruji. Penggunaan SQLite membiasakan mahasiswa memahami transaksi, indeks, query relasional, dan dirty flag sebelum naik ke Clean Architecture di minggu berikutnya.
