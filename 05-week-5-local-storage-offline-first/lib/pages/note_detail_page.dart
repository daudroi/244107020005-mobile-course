import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/note.dart';
import '../data/providers.dart';

class NoteDetailPage extends ConsumerStatefulWidget {
  const NoteDetailPage({super.key, required this.noteId});

  final int noteId;

  @override
  ConsumerState<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends ConsumerState<NoteDetailPage> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  Note? _originalNote;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  Future<void> _loadNote() async {
    final repo = ref.read(noteRepositoryProvider);
    final note = await repo.getNoteById(widget.noteId);
    if (!mounted) return;
    if (note != null) {
      _titleController.text = note.title;
      _bodyController.text = note.body;
      setState(() {
        _originalNote = note;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveChanges() async {
    if (_originalNote == null) return;
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    setState(() => _isSaving = true);
    final updated = _originalNote!.copyWith(
      title: title,
      body: _bodyController.text.trim(),
    );
    await ref.read(notesProvider.notifier).updateNote(updated);

    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Catatan diperbarui (ditandai belum tersinkron)'),
        backgroundColor: Colors.amber,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Catatan')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_originalNote == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Catatan Tidak Ditemukan')),
        body: const Center(
          child: Text('Catatan ini tidak ada di database lokal.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Catatan'),
        actions: [
          IconButton(
            tooltip: 'Simpan Perubahan',
            icon: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            onPressed: _isSaving ? null : _saveChanges,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _originalNote!.dirty
                      ? Icons.cloud_upload_outlined
                      : Icons.cloud_done,
                  size: 16,
                  color: _originalNote!.dirty
                      ? Colors.amber.shade900
                      : Colors.green,
                ),
                const SizedBox(width: 6),
                Text(
                  _originalNote!.dirty
                      ? 'Status: Belum tersinkron (dirty = 1)'
                      : 'Status: Tersinkron (dirty = 0)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _originalNote!.dirty
                        ? Colors.amber.shade900
                        : Colors.green,
                  ),
                ),
                const Spacer(),
                Text(
                  'ID: #${_originalNote!.id}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const Divider(height: 24),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Judul Catatan',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bodyController,
              decoration: const InputDecoration(
                labelText: 'Isi Catatan',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 10,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _saveChanges,
                icon: const Icon(Icons.save),
                label: const Text('Simpan Perubahan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
