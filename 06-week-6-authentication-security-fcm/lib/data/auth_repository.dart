class AuthSession {
  const AuthSession({required this.access, required this.refresh});
  final String access;
  final String refresh;
}

class AuthRepository {
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (!email.contains('@') || password.length < 6) {
      throw Exception('Email tidak valid atau kata sandi minimal 6 karakter');
    }
    // Simulasi JWT session aman
    return AuthSession(
      access: 'mock-access-for-${email.split('@').first}',
      refresh: 'mock-refresh-for-${email.split('@').first}',
    );
  }

  Future<String> refresh(String refreshToken) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (refreshToken.isEmpty) {
      throw Exception('Refresh token tidak ditemukan atau sudah kedaluwarsa');
    }
    return 'mock-access-renewed-${DateTime.now().millisecondsSinceEpoch}';
  }
}
