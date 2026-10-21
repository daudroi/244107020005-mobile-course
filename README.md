# 244107020005 - Mobile Course Portfolio

Repository tugas dan praktikum perkuliahan **Pemrograman Mobile (Mobile Programming)** menggunakan Flutter & Dart.

## Identitas Mahasiswa

| Data | Keterangan |
|---|---|
| **Nama** | Achmad Daud Roichan |
| **NIM** | 244107020005 |
| **Kelas** | TI 3F |
| **Program Studi** | D4 Teknik Informatika |
| **Jurusan** | Teknologi Informasi |
| **Institusi** | Politeknik Negeri Malang |

---

## Daftar Praktikum & Laporan Mingguan

| Minggu | Topik Praktikum | Direktori & Laporan | Status |
|---|---|---|---|
| **Week 1** | Mobile Development Ecosystem & Flutter Refresh | [`01-week-1-mobile-development-ecosystem-flutter-refresh`](01-week-1-mobile-development-ecosystem-flutter-refresh/README.md) | Selesai |
| **Week 2** | Declarative UI & Responsive Design | [`02-week-2-declarative-ui-responsive-design`](02-week-2-declarative-ui-responsive-design/README.md) | Selesai |
| **Week 3** | Navigation & State Management (Riverpod + GoRouter) | [`03-week-3-navigation-state-management`](03-week-3-navigation-state-management/README.md) | Selesai |
| **Week 4** | Networking & REST API (Dio + Repository Pattern) | [`04-week-4-networking-rest-api`](04-week-4-networking-rest-api/README.md) | Selesai |
| **Week 5** | Local Storage & Offline-First (SharedPreferences + SQLite sqflite) | [`05-week-5-local-storage-offline-first`](05-week-5-local-storage-offline-first/README.md) | Selesai |
| **Week 6** | Authentication, Security & FCM Push Notification | [`06-week-6-authentication-security-fcm`](06-week-6-authentication-security-fcm/README.md) | Selesai |
| **Week 7** | Clean Architecture (Feature-First Modular Structure) | [`07-week-7-clean-architecture`](07-week-7-clean-architecture/README.md) | Selesai |

---

## Struktur Repositori

```text
244107020005-mobile-course/
├── README.md
├── 01-week-1-mobile-development-ecosystem-flutter-refresh/
│   ├── README.md
│   ├── my_first_app/
│   │   ├── lib/
│   │   ├── test/
│   │   └── screenshoot/
├── 02-week-2-declarative-ui-responsive-design/
│   ├── README.md
│   ├── prak_week2/
│   ├── tugas_week2/
│   └── screenshoot/
├── 03-week-3-navigation-state-management/
│   ├── README.md
│   ├── week3_navigation/
│   ├── week3_todo/
│   └── screenshots/
├── 04-week-4-networking-rest-api/
│   ├── README.md
│   └── week4_api/
│       ├── lib/
│       ├── test/
│       └── screenshoot/
├── 05-week-5-local-storage-offline-first/
│   ├── README.md
│   ├── pubspec.yaml
│   ├── lib/
│   ├── test/
│   ├── docs/
│   └── screenshots/
├── 06-week-6-authentication-security-fcm/
│   ├── README.md
│   ├── pubspec.yaml
│   ├── lib/
│   ├── test/
│   ├── docs/
│   └── screenshots/
└── 07-week-7-clean-architecture/
    ├── README.md
    ├── pubspec.yaml
    ├── lib/
    ├── test/
    ├── docs/
    └── screenshots/
```

---

## Stack Teknologi Utama

- **Framework:** Flutter SDK (3.47+) & Dart SDK (3.13+)
- **State Management:** `flutter_riverpod` (Notifier, AsyncNotifier, AsyncValue)
- **Routing:** `go_router` (Dynamic routes, child routes, deep linking, auth redirect guards)
- **Networking:** `dio` (Interceptors, automatic 401 token refresh, error formatting)
- **Local Storage:** `shared_preferences` (Key-value), `sqflite` (Relational SQLite with indexing & dirty flags)
- **Security:** `flutter_secure_storage` (Hardware-backed Android KeyStore & iOS Keychain)
- **Cloud Messaging:** `firebase_messaging` & `flutter_local_notifications` (Token lifecycle, foreground banner, background isolate)
- **Architecture:** Clean Architecture Feature-First (*Domain, Data, Presentation* dengan *Dependency Inversion*)
- **Quality Assurance:** Static analysis (`flutter analyze`) dan automated testing (`flutter test`)