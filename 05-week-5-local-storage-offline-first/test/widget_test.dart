import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/data/local/note.dart';
import 'package:week5_offline_notes/widgets/note_tile.dart';

void main() {
  testWidgets('NoteTile menampilkan judul dan badge belum tersinkron saat dirty == true',
      (tester) async {
    final note = Note(
      id: 1,
      title: 'Belajar Offline First',
      body: 'Materi SQLite dan Dirty Flag',
      updatedAt: DateTime(2026, 9, 20, 10, 30),
      dirty: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NoteTile(
            note: note,
            onTap: () {},
            onDelete: () {},
          ),
        ),
      ),
    );

    expect(find.text('Belajar Offline First'), findsOneWidget);
    expect(find.text('Materi SQLite dan Dirty Flag'), findsOneWidget);
    expect(find.text('Belum tersinkron'), findsOneWidget);
  });

  testWidgets('NoteTile menampilkan badge Tersinkron saat dirty == false',
      (tester) async {
    final note = Note(
      id: 2,
      title: 'Catatan Bersih',
      body: 'Sudah disinkronkan ke server',
      updatedAt: DateTime(2026, 9, 20, 11, 0),
      dirty: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NoteTile(
            note: note,
            onTap: () {},
            onDelete: () {},
          ),
        ),
      ),
    );

    expect(find.text('Catatan Bersih'), findsOneWidget);
    expect(find.text('Tersinkron'), findsOneWidget);
  });
}
