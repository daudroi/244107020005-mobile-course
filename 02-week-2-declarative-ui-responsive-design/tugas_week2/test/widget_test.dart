import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tugas_week2/main.dart';

void main() {
  testWidgets('Login validates and opens the student portal', (tester) async {
    await tester.pumpWidget(const StudentPortalApp());

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('This semester at a glance'), findsOneWidget);
    expect(find.byType(MetricCard), findsNWidgets(4));
  });

  testWidgets('Dashboard uses one column on a narrow screen', (tester) async {
    tester.view.physicalSize = const Size(600, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const StudentPortalApp());
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.byType(MetricCard), findsNWidgets(4));
  });

  testWidgets('Dashboard uses navigation rail on a wide screen', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const StudentPortalApp());
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('Theme, profile navigation, and logout are accessible', (tester) async {
    await tester.pumpWidget(const StudentPortalApp());

    expect(find.byType(CupertinoSwitch), findsOneWidget);
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Alex Morgan'), findsOneWidget);
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
  });
}
