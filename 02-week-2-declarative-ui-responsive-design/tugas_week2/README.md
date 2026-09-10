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

### Prompt desain

> Bandingkan dua tata letak dashboard akademik untuk Flutter: versi `GridView` dan versi `LayoutBuilder` + `Column`. Jelaskan trade-off responsif dan aksesibilitasnya.

**Keputusan:** `GridView` dipakai untuk kartu metrik yang homogen. `LayoutBuilder` memilih satu atau dua kolom berdasarkan constraint aktual. `Column` dipakai sebagai fallback dan untuk panel yang urutan bacanya penting.

### Prompt penguatan konsep

> Jelaskan kapan penggunaan `Expanded` justru menyebabkan overflow di dalam `Row`, beri contoh kode yang gagal dan perbaikannya.

`Expanded` aman ketika `Row` memiliki lebar terbatas. Ia bermasalah di dalam parent dengan lebar tak terbatas seperti horizontal scroll atau ketika child memiliki minimum width terlalu besar. Perbaikannya adalah memberi constraint dengan `ConstrainedBox`, memakai `Flexible`, atau berpindah ke `Column` pada breakpoint sempit. Portal ini memakai `Expanded` hanya di dalam row yang dibatasi `LayoutBuilder` dan `ConstrainedBox`.

### Verification prompt

> Periksa kembali rekomendasi layout di atas: apakah tetap responsif di bawah 600px, apakah mengurangi aksesibilitas, dan apakah ada widget yang tidak tersedia di Flutter stabil saat ini?

**Hasil:** layout diuji pada lebar `600px` dan `1200px`, navigasi berubah sesuai ruang, label penting menggunakan `Semantics`, dan widget yang digunakan tersedia pada Flutter stable.

## Run and verify

```powershell
cd tugas_week2
flutter pub get
flutter run -d chrome
flutter analyze
flutter test
```

Test mencakup login, empat kartu dashboard, navigasi mobile/desktop, profile, settings, sign out, dan theme control. Windows desktop builds additionally require Visual Studio with `Desktop development with C++`.
