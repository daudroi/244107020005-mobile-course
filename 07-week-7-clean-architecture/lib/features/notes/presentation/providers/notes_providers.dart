import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/note_repository_impl.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../../domain/usecases/add_note.dart';
import '../../domain/usecases/delete_note.dart';
import '../../domain/usecases/get_notes.dart';

// Data layer DI wiring
final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepositoryImpl();
});

// Domain layer DI wiring
final getNotesProvider = Provider<GetNotes>((ref) {
  return GetNotes(ref.watch(noteRepositoryProvider));
});

final addNoteProvider = Provider<AddNote>((ref) {
  return AddNote(ref.watch(noteRepositoryProvider));
});

final deleteNoteProvider = Provider<DeleteNote>((ref) {
  return DeleteNote(ref.watch(noteRepositoryProvider));
});

// Presentation layer state management
final notesProvider =
    AsyncNotifierProvider<NotesNotifier, List<Note>>(NotesNotifier.new);

class NotesNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() async {
    final usecase = ref.watch(getNotesProvider);
    final result = await usecase.call();
    if (result.failure != null) {
      throw Exception(result.failure!.message);
    }
    return result.notes;
  }

  Future<void> add({required String title, String body = ''}) async {
    final usecase = ref.read(addNoteProvider);
    final result = await usecase.call(title: title, body: body);
    if (result.failure != null) {
      throw Exception(result.failure!.message);
    }
    ref.invalidateSelf();
  }

  Future<void> delete(int id) async {
    final usecase = ref.read(deleteNoteProvider);
    final result = await usecase.call(id);
    if (result.failure != null) {
      throw Exception(result.failure!.message);
    }
    ref.invalidateSelf();
  }
}
