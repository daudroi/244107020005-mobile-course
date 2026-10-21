import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../data/models/announcement.dart';
import '../data/token_store.dart';
import '../messaging/push_service.dart';

final tokenStoreProvider = Provider((ref) => TokenStore());
final authRepositoryProvider = Provider((ref) => AuthRepository());

final authStateProvider =
    AsyncNotifierProvider<AuthNotifier, bool>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final token = await ref.watch(tokenStoreProvider).readAccess();
    return token != null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final session = await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);
      await ref
          .read(tokenStoreProvider)
          .save(access: session.access, refresh: session.refresh);
      return true;
    });
  }

  Future<void> logout() async {
    await ref.read(tokenStoreProvider).clear();
    ref.invalidateSelf();
  }
}

final fcmTokenProvider =
    AsyncNotifierProvider<FcmTokenNotifier, String?>(FcmTokenNotifier.new);

class FcmTokenNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    final service = PushService.instance;
    await service.requestNotificationPermission();
    return service.getToken();
  }

  Future<void> rotateToken() async {
    state = const AsyncLoading();
    await PushService.instance.simulateTokenRotation();
    final newToken = await PushService.instance.getToken();
    state = AsyncData(newToken);
  }
}

final topicSubscribedProvider =
    NotifierProvider<TopicNotifier, bool>(TopicNotifier.new);

class TopicNotifier extends Notifier<bool> {
  @override
  bool build() => PushService.instance.isSubscribedTo('pengumuman-kampus');

  Future<void> toggle() async {
    final current = state;
    if (current) {
      await PushService.instance.unsubscribeFromTopic('pengumuman-kampus');
      state = false;
    } else {
      await PushService.instance.subscribeToTopic('pengumuman-kampus');
      state = true;
    }
  }
}

final announcementsProvider = Provider<List<Announcement>>((ref) {
  return const [
    Announcement(
      id: '1',
      title: 'Perubahan Jadwal Kuliah Pemrograman Mobile',
      body: 'Kelas Pemrograman Mobile TI 3F hari Kamis dipindahkan ke Ruang A2 pada pukul 13.00 WIB.',
      date: '2026-10-20',
      category: 'Akademik',
      important: true,
    ),
    Announcement(
      id: '2',
      title: 'Pendaftaran Ujian Tengah Semester (UTS)',
      body: 'Mahasiswa diharapkan memverifikasi KRS online dan menyelesaikan administrasi sebelum pekan UTS.',
      date: '2026-10-18',
      category: 'Akademik',
      important: false,
    ),
    Announcement(
      id: '3',
      title: 'Kuliah Tamu: Mobile Security & Cloud Messaging',
      body: 'Seminar hybrid bersama praktisi industri membahas token lifecycle, OWASP Mobile Top 10, dan FCM push architecture.',
      date: '2026-10-15',
      category: 'Event Kampus',
      important: true,
    ),
    Announcement(
      id: '4',
      title: 'Pemeliharaan Server Jaringan Kampus',
      body: 'Layanan Wi-Fi gedung utama akan mengalami gangguan sementara pada Sabtu malam pukul 22.00 - 02.00 WIB.',
      date: '2026-10-12',
      category: 'Fasilitas',
      important: false,
    ),
  ];
});

final announcementDetailProvider =
    Provider.family<Announcement?, String>((ref, id) {
  final list = ref.watch(announcementsProvider);
  try {
    return list.firstWhere((item) => item.id == id);
  } catch (_) {
    return null;
  }
});
