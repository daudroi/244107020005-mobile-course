import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prak_week2/main.dart';

void main() {
  testWidgets('Academic Overview uses one column on narrow screens',
      (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const AcademicOverviewApp());

    expect(find.byType(InfoCard), findsNWidgets(4));
    expect(find.text('Academic Overview'), findsOneWidget);
    expect(find.text('Good morning, Alex'), findsOneWidget);
    expect(tester.getSize(find.byType(InfoCard).first).width, lessThan(700));
  });

  testWidgets('Academic Overview uses two columns on wide screens',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const AcademicOverviewApp());

    final firstCard = tester.getSize(find.byType(InfoCard).first);
    expect(firstCard.width, greaterThan(250));
    expect(find.byType(Row), findsWidgets);
  });

  testWidgets('Theme switch and accessibility labels work', (tester) async {
    await tester.pumpWidget(const AcademicOverviewApp());

    expect(find.byType(CupertinoSwitch), findsOneWidget);
    expect(find.bySemanticsLabel(
      'Dark theme disabled. Turn on to use dark theme.',
    ), findsOneWidget);
    expect(find.bySemanticsLabel('Assignments: 8. 2 due this week'),
        findsOneWidget);

    await tester.tap(find.byType(CupertinoSwitch));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.dark_mode), findsOneWidget);
  });
}
