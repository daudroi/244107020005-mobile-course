import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/pages/login_page.dart';
import 'package:campus_notify/providers/auth_provider.dart';

class FakeAuthNotifier extends AuthNotifier {
  @override
  Future<bool> build() async => false;
}

void main() {
  testWidgets('LoginPage menampilkan field email, password, dan tombol masuk',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(FakeAuthNotifier.new),
        ],
        child: const MaterialApp(
          home: LoginPage(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Campus Notify'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Masuk ke Akun'), findsOneWidget);
  });
}
