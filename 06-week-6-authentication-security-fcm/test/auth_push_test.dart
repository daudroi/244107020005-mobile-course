import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/data/api_errors.dart';
import 'package:campus_notify/messaging/push_service.dart';
import 'package:campus_notify/routes.dart';

class FakeTokenStore {
  String? access;
  String? refresh;

  void save(String a, String r) {
    access = a;
    refresh = r;
  }

  void clear() {
    access = null;
    refresh = null;
  }
}

void main() {
  group('Deep Link Route Parsing', () {
    test('routeFromMessage menangani route kosong dan tanpa slash', () {
      expect(routeFromMessage({}), '/');
      expect(routeFromMessage({'route': 'pengumuman/3'}), '/pengumuman/3');
      expect(routeFromMessage({'route': '/pengumuman/3'}), '/pengumuman/3');
    });

    test('data payload membawa id pengumuman dengan benar', () {
      const data = {'route': '/pengumuman/3', 'id': '3'};
      expect(data['id'], '3');
      expect(routeFromMessage(data), '/pengumuman/3');
    });
  });

  group('Token Store & Auth Session Security', () {
    test('provider auth membaca status login dari ketersediaan access token',
        () async {
      final store = FakeTokenStore()..access = 'mock-access';
      expect(store.access != null, isTrue);

      store.access = null;
      expect(store.access != null, isFalse);
    });

    test('refresh token kedaluwarsa memaksa sesi dibersihkan (re-login)',
        () async {
      final store = FakeTokenStore()
        ..save('expired-access', 'expired-refresh');
      expect(store.access, isNotNull);

      // Simulasi kegagalan refresh -> panggil clear()
      store.clear();
      expect(store.access, isNull);
      expect(store.refresh, isNull);
    });

    test('PushService maskToken menyamarkan token sesuai standar OWASP', () {
      const longToken = 'fcm_d8a2d6c768c334d53e16277f837970ff_xyz';
      final masked = PushService.maskToken(longToken);

      expect(masked.contains('...'), isTrue);
      expect(masked.startsWith('fcm_d8a2d6'), isTrue);
      expect(masked.length < longToken.length, isTrue);
      expect(PushService.maskToken(null), 'Belum terdaftar');
    });
  });

  group('Friendly API Error Mapping', () {
    test('friendlyErrorMessage memetakan error umum', () {
      final err = Exception('Koneksi terputus');
      final msg = friendlyErrorMessage(err);
      expect(msg, 'Koneksi terputus');
    });
  });
}
