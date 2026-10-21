import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week5_offline_notes/data/local/note.dart';
import 'package:week5_offline_notes/data/providers.dart';
import 'package:week5_offline_notes/data/repositories/note_repository.dart';
import 'package:week5_offline_notes/data/sync.dart';

class FakeNoteRepository extends NoteRepository {
  FakeNoteRepository({this.items = const [], this.throwError = false})
      : _stateItems = List.of(items),
        super(openDb: () => throw UnimplementedError());

  final List<Note> items;
  final List<Note> _stateItems;
  final bool throwError;

  @override
  Future<List<Note>> fetchNotes() async {
    if (throwError) throw Exception('db locked (simulasi)');
    return _stateItems;
  }

  @override
  Future<int> countDirty() async {
    return _stateItems.where((n) => n.dirty).length;
  }

  @override
  Future<void> markAllSynced() async {
    for (int i = 0; i < _stateItems.length; i++) {
      if (_stateItems[i].dirty) {
        _stateItems[i] = _stateItems[i].copyWith(dirty: false);
      }
    }
  }

  @override
  Future<Note?> getNoteById(int id) async {
    try {
      return _stateItems.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }
}

void main() {
  group('Model Note & Serialisasi', () {
    test('fromMap aman terhadap field yang hilang', () {
      final note = Note.fromMap({'title': 'Belanja'});
      expect(note.title, 'Belanja');
      expect(note.body, '');
      expect(note.dirty, isFalse);
      expect(note.id, isNull);
    });

    test('flag dirty bertahan pada serialisasi', () {
      final note = Note(
        title: 'Catatan Rapat',
        body: 'Diskusi proyek mobile',
        updatedAt: DateTime(2026, 9, 18),
        dirty: true,
      );
      final restored = Note.fromMap(note.toMap());
      expect(restored.title, 'Catatan Rapat');
      expect(restored.body, 'Diskusi proyek mobile');
      expect(restored.dirty, isTrue);
    });
  });

  group('Provider dengan FakeNoteRepository', () {
    test('provider sukses dengan repository palsu', () async {
      final container = ProviderContainer(
        overrides: [
          noteRepositoryProvider.overrideWithValue(
            FakeNoteRepository(items: [
              Note(
                id: 1,
                title: 'Tes Catatan',
                body: 'Konten pengujian',
                updatedAt: DateTime.now(),
              ),
            ]),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notes = await container.read(notesProvider.future);
      expect(notes.length, 1);
      expect(notes.first.title, 'Tes Catatan');
      expect(notes.first.id, 1);
    });

    test('provider error dengan repository palsu', () async {
      final container = ProviderContainer(
        overrides: [
          noteRepositoryProvider.overrideWithValue(
            FakeNoteRepository(throwError: true),
          ),
        ],
      );
      addTearDown(container.dispose);

      final sub = container.listen(notesProvider, (_, _) {});
      await Future<void>.delayed(Duration.zero);

      final state = container.read(notesProvider);
      expect(state.hasError, isTrue);
      expect(state.error.toString(), contains('db locked (simulasi)'));
      sub.close();
    });
  });

  group('Sinkronisasi Offline-First', () {
    test('syncNotes menandai semua catatan kotor dan mengembalikan jumlahnya',
        () async {
      final fakeRepo = FakeNoteRepository(items: [
        Note(id: 1, title: 'Item 1', updatedAt: DateTime.now(), dirty: true),
        Note(id: 2, title: 'Item 2', updatedAt: DateTime.now(), dirty: true),
        Note(id: 3, title: 'Item 3', updatedAt: DateTime.now(), dirty: false),
      ]);

      final initialDirty = await fakeRepo.countDirty();
      expect(initialDirty, 2);

      final syncedCount = await syncNotes(fakeRepo);
      expect(syncedCount, 2);

      final finalDirty = await fakeRepo.countDirty();
      expect(finalDirty, 0);
    });
  });
}
