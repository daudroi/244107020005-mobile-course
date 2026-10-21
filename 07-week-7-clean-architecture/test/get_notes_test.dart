import 'package:flutter_test/flutter_test.dart';
import 'package:week7_clean_architecture/core/failures.dart';
import 'package:week7_clean_architecture/features/notes/domain/entities/note.dart';
import 'package:week7_clean_architecture/features/notes/domain/repositories/note_repository.dart';
import 'package:week7_clean_architecture/features/notes/domain/usecases/add_note.dart';
import 'package:week7_clean_architecture/features/notes/domain/usecases/delete_note.dart';
import 'package:week7_clean_architecture/features/notes/domain/usecases/get_notes.dart';

class FakeNoteRepository implements NoteRepository {
  FakeNoteRepository({this.items = const [], this.fail = false});

  final List<Note> items;
  final bool fail;

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async {
    if (fail) {
      return (
        notes: const <Note>[],
        failure: const LocalFailure('db locked (simulasi)'),
      );
    }
    return (notes: items, failure: null);
  }

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) async {
    if (fail) {
      return (
        note: null,
        failure: const LocalFailure('Gagal simpan (simulasi)'),
      );
    }
    final created = Note(
      id: items.length + 1,
      title: title,
      body: body,
      updatedAt: DateTime.now(),
    );
    return (note: created, failure: null);
  }

  @override
  Future<({bool success, Failure? failure})> deleteNote(int id) async {
    if (fail) {
      return (
        success: false,
        failure: const LocalFailure('Gagal hapus (simulasi)'),
      );
    }
    return (success: true, failure: null);
  }
}

void main() {
  group('GetNotes UseCase Test', () {
    test('GetNotes meneruskan daftar catatan dari repository dengan sukses',
        () async {
      final repo = FakeNoteRepository(items: [
        Note(
          id: 1,
          title: 'Arsitektur Bersih',
          updatedAt: DateTime(2026, 9, 27),
        ),
      ]);
      final result = await GetNotes(repo).call();

      expect(result.failure, isNull);
      expect(result.notes.length, 1);
      expect(result.notes.first.title, 'Arsitektur Bersih');
    });

    test('GetNotes meneruskan failure tanpa melempar exception liar', () async {
      final repo = FakeNoteRepository(fail: true);
      final result = await GetNotes(repo).call();

      expect(result.failure, isA<LocalFailure>());
      expect(result.failure!.message, contains('db locked'));
      expect(result.notes, isEmpty);
    });
  });

  group('AddNote & DeleteNote UseCases', () {
    test('AddNote menolak judul kosong dengan LocalFailure', () async {
      final repo = FakeNoteRepository();
      final result = await AddNote(repo).call(title: '   ');

      expect(result.failure, isA<LocalFailure>());
      expect(result.failure!.message, contains('tidak boleh kosong'));
      expect(result.note, isNull);
    });

    test('AddNote berhasil menambahkan catatan baru', () async {
      final repo = FakeNoteRepository();
      final result = await AddNote(repo).call(
        title: 'Belajar SOLID',
        body: 'Single Responsibility Principle',
      );

      expect(result.failure, isNull);
      expect(result.note?.title, 'Belajar SOLID');
    });

    test('DeleteNote berhasil menghapus catatan', () async {
      final repo = FakeNoteRepository();
      final result = await DeleteNote(repo).call(1);

      expect(result.failure, isNull);
      expect(result.success, isTrue);
    });
  });
}
