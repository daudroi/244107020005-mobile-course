import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week7_clean_architecture/features/notes/domain/entities/note.dart';
import 'package:week7_clean_architecture/features/notes/presentation/pages/notes_page.dart';
import 'package:week7_clean_architecture/features/notes/presentation/providers/notes_providers.dart';

class FakeNotesNotifier extends NotesNotifier {
  @override
  Future<List<Note>> build() async {
    return [
      Note(
        id: 1,
        title: 'Catatan Arsitektur Bersih',
        body: 'Domain tidak bergantung pada Flutter atau Database',
        updatedAt: DateTime(2026, 10, 21),
      ),
    ];
  }
}

void main() {
  testWidgets('NotesPage menampilkan judul AppBar dan daftar catatan',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notesProvider.overrideWith(FakeNotesNotifier.new),
        ],
        child: const MaterialApp(
          home: NotesPage(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Clean Notes'), findsOneWidget);
    expect(find.text('Catatan Arsitektur Bersih'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
