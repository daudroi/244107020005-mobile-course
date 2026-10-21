import 'dart:async';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(Map<String, dynamic> message) async {
  // Background isolate: Jangan akses BuildContext atau Riverpod di sini.
  // Tugasnya hanya mencatat payload secara aman atau menyimpan status ringan.
}

class PushService {
  PushService._();
  static final PushService instance = PushService._();

  String? _fcmToken = 'fcm_mock_token_${DateTime.now().millisecondsSinceEpoch}';
  final _tokenRefreshController = StreamController<String>.broadcast();
  final Set<String> _subscribedTopics = {'pengumuman-kampus'};
  String? pendingDeepLink;

  Stream<String> get onTokenRefresh => _tokenRefreshController.stream;

  Future<bool> requestNotificationPermission() async {
    // Simulasi permission runtime Android 13+ (POST_NOTIFICATIONS) dan iOS
    await Future.delayed(const Duration(milliseconds: 150));
    return true;
  }

  Future<String?> getToken() async {
    return _fcmToken;
  }

  Future<void> simulateTokenRotation() async {
    _fcmToken = 'fcm_renewed_${DateTime.now().millisecondsSinceEpoch}';
    _tokenRefreshController.add(_fcmToken!);
  }

  Future<void> subscribeToTopic(String topic) async {
    _subscribedTopics.add(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    _subscribedTopics.remove(topic);
  }

  bool isSubscribedTo(String topic) => _subscribedTopics.contains(topic);

  /// Mask token untuk keamanan (OWASP Mobile Top 10):
  /// Jangan pernah menampilkan token penuh di UI, log production, atau screenshot.
  static String maskToken(String? token) {
    if (token == null || token.isEmpty) return 'Belum terdaftar';
    if (token.length <= 12) return token;
    return '${token.substring(0, 10)}...${token.substring(token.length - 4)}';
  }
}
