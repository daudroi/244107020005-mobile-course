# AI Prompt Challenge & Verification: Authentication, Security & FCM

## 1. Prompt yang Digunakan

```text
Aplikasi Flutter Campus Notification App.
Stack: firebase_messaging, flutter_local_notifications,
flutter_secure_storage, go_router, Riverpod.
Buatkan PushService dengan:
- requestPermission + getToken + onTokenRefresh (kirim ke POST /devices)
- onMessage (tampilkan local notification manual)
- onMessageOpenedApp + getInitialMessage (navigasi ke data.route)
- subscribe/unsubscribe topic pengumuman-kampus
- background handler top-level dengan @pragma('vm:entry-point')
Tandai bagian yang BERBEDA untuk Android 13+ vs iOS,
dan bagian yang tidak boleh mengakses BuildContext.
```

---

## 2. AI Verification Checklist & Temuan Teknis

| Pemeriksaan | Status Evaluasi | Analisis Kritis & Tindakan Perbaikan |
|---|---|---|
| **Background Handler Top-Level** | **LULUS (Diperbaiki)** | AI awalnya menempatkan handler di dalam method instance `PushService`. Ini ditolak karena Flutter isolate untuk background messaging memerlukan fungsi top-level bertanda `@pragma('vm:entry-point')` agar tidak dihapus oleh tree-shaking kompilator Dart AOT. |
| **Token Lifecycle (`onTokenRefresh`)** | **LULUS (Diperbaiki)** | Draf awal AI hanya mencetak `print(token)` saat refresh. Ini diperbaiki agar `onTokenRefresh` memicu pengiriman payload registrasi perangkat ke endpoint backend (`POST /devices`), mencegah backend menyimpan token kadaluwarsa saat aplikasi di-reinstall. |
| **Foreground Local Notification** | **DIVERIFIKASI** | Pada state foreground, FCM secara default *tidak memunculkan banner pop-up sistem*. Solusi manual dengan `flutter_local_notifications` di dalam listener `onMessage` diverifikasi wajib agar notifikasi tetap terbaca saat mahasiswa membuka aplikasi. |
| **Navigasi Tiga App State** | **DIVERIFIKASI** | Alur deep link dipetakan: `onMessage` (banner lokal klik) -> `pendingDeepLink`; `onMessageOpenedApp` (background klik) -> router `go()`; dan `getInitialMessage` (terminated klik saat app mati) -> router `go()`. |
| **Keamanan Token (OWASP Mobile Top 10)** | **DIVERIFIKASI** | Draf AI sempat mencetak token lengkap di console log. Kami memperbaiki dengan fungsi `PushService.maskToken()` sehingga hanya 10 karakter pertama dan 4 karakter terakhir yang tampil (misal: `fcm_d8a2d6...9x12`). Access token dan refresh token disimpan terenkripsi di `FlutterSecureStorage` (Android Keystore / iOS Keychain), bukan di SharedPreferences. |

---

## 3. Matriks Perbedaan Platform: Android 13+ vs iOS

| Aspek | Android 13+ (API 33+) | iOS (APNs) |
|---|---|---|
| **Izin Notifikasi Runtime** | Memerlukan izin eksplisit `POST_NOTIFICATIONS` di `AndroidManifest.xml` dan runtime dialog via `requestPermission()`. | Memerlukan registrasi APNs token, entitlement Push Notification di Xcode, dan dialog permission `alert, badge, sound`. |
| **Tampilan Foreground** | Banner tidak muncul otomatis; wajib ditampilkan via `flutter_local_notifications` dengan channel `Importance.high`. | Dapat menampilkan banner langsung bila opsi `presentationOptions(alert: true, badge: true, sound: true)` diaktifkan. |
| **Penyimpanan Token Aman** | Menggunakan Android KeyStore (AES-256 GCM) via `flutter_secure_storage`. | Menggunakan iOS Keychain Services dengan proteksi *kSecAttrAccessibleAfterFirstUnlock*. |
| **Background Isolate** | Menjalankan headless Flutter engine via background service broadcast receiver. | Bergantung pada silent push notification dan batasan background execution iOS. |

---

## 4. Keputusan Teknis Final

1. **Topik vs Token Perangkat:**
   - Topik `pengumuman-kampus` digunakan murni untuk siaran massal (*broadcast*) yang tidak memerlukan pelacakan perorangan.
   - Token perangkat personal digunakan untuk pesan spesifik mahasiswa (jadwal ujian perorangan, tunggakan SPP, revisi tugas).
2. **Refresh Token Cycle & Auto-Retry:**
   - Interceptor Dio diatur untuk otomatis mencoba menyegarkan access token **tepat satu kali** saat menerima status `401 Unauthorized`. Jika refresh token juga gagal/kedaluwarsa, seluruh sesi dibersihkan (`clear()`) dan rute otomatis mengunci kembali ke `/login`.
