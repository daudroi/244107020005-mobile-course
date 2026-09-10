# Campusly Student Portal

A complete responsive Flutter student portal for the Week 2 AI design exploration challenge.

## Features

- Login screen with email/password validation and password visibility toggle
- Pre-filled demo account: `student@campus.test` / `password123`
- Academic overview with four reusable metric cards
- Semester progress and activity panels
- Profile screen with program, semester, campus, and contact details
- Settings screen with dark theme, notifications summary, and sign out
- Bottom `NavigationBar` on narrow screens and labeled `NavigationRail` on wide screens
- Accessible `Semantics` labels and tooltips on important controls
- Theme colors sourced from `Theme.of(context)` and Material 3

## Responsive decisions

`kWideBreakpoint` is defined once at `800px`. Below it, the portal uses a bottom navigation bar; at or above it, it uses a navigation rail. Metric cards switch from one column below `650px` to two columns above it. Progress and activity panels stack below `700px` and sit side by side above it.

The implementation uses `LayoutBuilder`, `Row`, `Column`, `Expanded`, `Container`, `GridView`, `IndexedStack`, and reusable `MetricCard` widgets. Constraints and scroll views prevent narrow-screen overflow.

## AI Prompt Challenge

Bagian ini mendokumentasikan prompt yang digunakan, ringkasan output penting, keputusan yang dipilih, alasan teknis, dan bukti verifikasinya.

### Prompt desain

> Bandingkan dua tata letak dashboard akademik untuk Flutter: versi `GridView` dan versi `LayoutBuilder` + `Column`. Jelaskan trade-off responsif dan aksesibilitasnya.

**Output penting:**

- `GridView` cocok untuk kartu berulang yang memiliki struktur visual seragam.
- `LayoutBuilder` lebih tepat untuk memilih layout berdasarkan ukuran constraint aktual.
- `Column` memberikan urutan baca yang lebih jelas pada layar sempit.
- Responsivitas dan aksesibilitas harus diuji pada lebih dari satu ukuran layar.

**Keputusan yang dipilih:** `GridView` dipakai untuk metric cards yang homogen. `LayoutBuilder` memilih satu atau dua kolom berdasarkan constraint aktual. `Column` dipakai sebagai fallback dan untuk panel yang urutan bacanya penting.

**Alasan teknis:** kartu metrik memiliki pola yang sama sehingga grid mengurangi duplikasi layout. `LayoutBuilder` dipilih daripada mengecek ukuran layar secara global karena keputusan dibuat berdasarkan ruang yang benar-benar tersedia bagi widget. Pada layar sempit, urutan vertikal lebih mudah dipindai dan mengurangi risiko overflow.

### Prompt penguatan konsep

> Jelaskan kapan penggunaan `Expanded` justru menyebabkan overflow di dalam `Row`, beri contoh kode yang gagal dan perbaikannya.

**Output penting:** `Expanded` aman ketika `Row` memiliki lebar terbatas. Ia bermasalah di dalam parent dengan lebar tak terbatas seperti horizontal scroll atau ketika child memiliki minimum width terlalu besar. Perbaikannya adalah memberi constraint dengan `ConstrainedBox`, memakai `Flexible`, atau berpindah ke `Column` pada breakpoint sempit.

**Keputusan yang dipilih:** portal memakai `Expanded` hanya di dalam `Row` yang menerima constraint dari `LayoutBuilder` dan dibatasi `ConstrainedBox`/ruang layar.

**Alasan teknis:** `Expanded` membagi sisa ruang yang tersedia; tanpa batas utama, Flutter tidak dapat menentukan ukuran final child. Karena itu panel progress dan activity hanya memakai `Expanded` saat berada pada row layar lebar, sedangkan layar sempit menggunakan `Column`.

### Verification prompt

> Periksa kembali rekomendasi layout di atas: apakah tetap responsif di bawah 600px, apakah mengurangi aksesibilitas, dan apakah ada widget yang tidak tersedia di Flutter stabil saat ini?

**Output penting:**

- Layout diuji pada lebar `600px` dan `1200px`.
- Navigasi berubah dari `NavigationBar` ke `NavigationRail` sesuai ruang.
- Label penting menggunakan `Semantics` dan kontrol memiliki tooltip atau label.
- Widget yang digunakan tersedia pada Flutter stable yang digunakan.

**Keputusan akhir:** mempertahankan `NavigationBar` untuk perangkat sempit dan `NavigationRail` untuk desktop/tablet lebar. Pendekatan ini menjaga navigasi tetap mudah dijangkau tanpa mengorbankan ruang konten.

**Alasan teknis:** breakpoint `kWideBreakpoint = 800` didefinisikan satu kali sebagai sumber keputusan navigasi. Metric cards memiliki breakpoint lokal `650px` karena membutuhkan lebar minimum yang lebih kecil daripada navigation rail.

## Bukti Verifikasi

### Test

Widget test berada di [`test/widget_test.dart`](test/widget_test.dart) dan mencakup:

| Skenario | Bukti |
| --- | --- |
| Login valid membuka dashboard | Test login lulus |
| Empat metric cards tampil | `findsNWidgets(4)` |
| Layar `600px` memakai `NavigationBar` | Test narrow screen lulus |
| Layar `1200px` memakai `NavigationRail` | Test wide screen lulus |
| Profile, Settings, dan Sign out | Test navigasi lulus |
| Theme control tersedia | Test `CupertinoSwitch` lulus |

Hasil pemeriksaan:

```text
flutter analyze
No issues found!

flutter test
4 tests passed
```

### Screenshot

Screenshot tugas akhir tersimpan pada folder laporan Week 2:

- [Login](../screenshoot/login.png)
- [Dashboard](../screenshoot/dashboard.png)
- [Profile](../screenshoot/profil.png)
- [Settings](../screenshoot/settings.png)

Screenshot tersebut menjadi bukti visual bahwa alur login, dashboard, profile, dan settings sudah diimplementasikan.

## Run and verify

```powershell
cd tugas_week2
flutter pub get
flutter run -d chrome
flutter analyze
flutter test
```

Test mencakup login, empat kartu dashboard, navigasi mobile/desktop, profile, settings, sign out, dan theme control. Windows desktop builds additionally require Visual Studio with `Desktop development with C++`.
