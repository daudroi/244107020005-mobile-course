import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/failures.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../models/note_model.dart';

class NoteRepositoryImpl implements NoteRepository {
  NoteRepositoryImpl({this.openDb});

  final Future<Database> Function()? openDb;

  static final List<NoteModel> _inMemoryNotes = [
    NoteModel(
      id: 1,
      title: 'Arsitektur Clean Architecture',
      body: 'Pemisahan Presentation, Domain, Data layer dengan arah panah ke dalam.',
      updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      dirty: false,
    ),
    NoteModel(
      id: 2,
      title: 'SOLID Principles Flutter',
      body: 'Single Responsibility, Open/Closed, Liskov, Interface Segregation, Dependency Inversion.',
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      dirty: false,
    ),
  ];

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async {
    try {
      final dbOpener = openDb;
      if (kIsWeb || dbOpener == null) {
        final list = _inMemoryNotes.map((m) => m.toEntity()).toList();
        list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        return (notes: list, failure: null);
      }

      final db = await dbOpener();
      final rows = await db.query('notes', orderBy: 'updated_at DESC');
      final notes = rows.map((r) => NoteModel.fromMap(r).toEntity()).toList();
      return (notes: notes, failure: null);
    } catch (e) {
      return (
        notes: const <Note>[],
        failure: LocalFailure('Gagal membaca catatan dari penyimpanan: $e'),
      );
    }
  }

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) async {
    try {
      final now = DateTime.now();
      final dbOpener = openDb;

      if (kIsWeb || dbOpener == null) {
        final newId = _inMemoryNotes.length + 1;
        final model = NoteModel(
          id: newId,
          title: title,
          body: body,
          updatedAt: now,
          dirty: true,
        );
        _inMemoryNotes.add(model);
        return (note: model.toEntity(), failure: null);
      }

      final db = await dbOpener();
      final model = NoteModel(
        title: title,
        body: body,
        updatedAt: now,
        dirty: true,
      );
      final id = await db.insert('notes', model.toMap());
      return (
        note: Note(
          id: id,
          title: title,
          body: body,
          updatedAt: now,
          dirty: true,
        ),
        failure: null,
      );
    } catch (e) {
      return (
        note: null,
        failure: LocalFailure('Gagal menambahkan catatan: $e'),
      );
    }
  }

  @override
  Future<({bool success, Failure? failure})> deleteNote(int id) async {
    try {
      final dbOpener = openDb;
      if (kIsWeb || dbOpener == null) {
        _inMemoryNotes.removeWhere((n) => n.id == id);
        return (success: true, failure: null);
      }

      final db = await dbOpener();
      await db.delete('notes', where: 'id = ?', whereArgs: [id]);
      return (success: true, failure: null);
    } catch (e) {
      return (
        success: false,
        failure: LocalFailure('Gagal menghapus catatan: $e'),
      );
    }
  }
}
