import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../local/db.dart';
import '../local/note.dart';

class NoteRepository {
  NoteRepository({Future<Database> Function()? openDb})
      : _openDb = openDb ?? openNotesDb;

  final Future<Database> Function() _openDb;

  // Penyimpanan in-memory terisolasi khusus saat dijalankan di browser (Flutter Web),
  // karena sqflite memerlukan Android/iOS native channel.
  static final List<Note> _webNotes = [
    Note(
      id: 1,
      title: 'Rencana Praktikum Mobile',
      body: 'Mempelajari SharedPreferences dan SQLite sqflite dengan dirty flag',
      updatedAt: DateTime.now().subtract(const Duration(minutes: 45)),
      dirty: true,
    ),
    Note(
      id: 2,
      title: 'Belanja Kebutuhan Kos',
      body: 'Sabun, sampo, odol, deterjen, dan kopi',
      updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
      dirty: true,
    ),
  ];

  Future<List<Note>> fetchNotes() async {
    if (kIsWeb) {
      final list = List<Note>.from(_webNotes);
      list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return list;
    }
    final db = await _openDb();
    final rows = await db.query('notes', orderBy: 'updated_at DESC');
    return rows.map(Note.fromMap).toList();
  }

  Future<Note?> getNoteById(int id) async {
    if (kIsWeb) {
      try {
        return _webNotes.firstWhere((n) => n.id == id);
      } catch (_) {
        return null;
      }
    }
    final db = await _openDb();
    final rows = await db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Note.fromMap(rows.first);
  }

  Future<Note> addNote({required String title, String body = ''}) async {
    final note = Note(
      id: kIsWeb ? (_webNotes.length + 1) : null,
      title: title,
      body: body,
      updatedAt: DateTime.now(),
      dirty: true,
    );

    if (kIsWeb) {
      _webNotes.add(note);
      return note;
    }

    final db = await _openDb();
    final id = await db.insert('notes', note.toMap());
    return Note(
      id: id,
      title: note.title,
      body: note.body,
      updatedAt: note.updatedAt,
      dirty: true,
    );
  }

  Future<void> updateNote(Note note) async {
    if (note.id == null) return;

    final updated = note.copyWith(
      updatedAt: DateTime.now(),
      dirty: true,
    );

    if (kIsWeb) {
      final idx = _webNotes.indexWhere((n) => n.id == note.id);
      if (idx != -1) {
        _webNotes[idx] = updated;
      }
      return;
    }

    final db = await _openDb();
    await db.update(
      'notes',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<void> deleteNote(int id) async {
    if (kIsWeb) {
      _webNotes.removeWhere((n) => n.id == id);
      return;
    }
    final db = await _openDb();
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> countDirty() async {
    if (kIsWeb) {
      return _webNotes.where((n) => n.dirty).length;
    }
    final db = await _openDb();
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM notes WHERE dirty = 1',
    );
    return ((rows.first['c'] as num?)?.toInt() ?? 0);
  }

  Future<void> markAllSynced() async {
    if (kIsWeb) {
      for (int i = 0; i < _webNotes.length; i++) {
        if (_webNotes[i].dirty) {
          _webNotes[i] = _webNotes[i].copyWith(dirty: false);
        }
      }
      return;
    }
    final db = await _openDb();
    await db.update('notes', {'dirty': 0}, where: 'dirty = 1');
  }
}
