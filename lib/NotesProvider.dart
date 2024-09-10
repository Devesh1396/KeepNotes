import 'package:flutter/foundation.dart';
import 'DataModel.dart';

class NotesProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Map<String, dynamic>> _notes = [];

  List<Map<String, dynamic>> get notes => _notes;

  //Map<String, dynamic>? _currentNote;
  //Map<String, dynamic>? get currentNote => _currentNote;

  // Fetch
  Future<void> loadNotes() async {
    _notes = await _dbHelper.getNotes();
    notifyListeners();
  }

  //Insert
  Future<void> insertNote(String title, String description, int stamp) async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    await _dbHelper.insertNote(
      title: title,
      desc: description,
      stamp: timestamp,
    );
    await loadNotes();
  }

  // Update
  Future<void> updateNote(String noteId, String title, String description, int stamp) async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    await _dbHelper.updateNote(
      noteId: noteId,
      title: title,
      description: description,
      stamp: timestamp,
    );
    await loadNotes();
  }

  // Delete
  Future<void> deleteNoteById(String noteId) async {
    await _dbHelper.deleteNoteById(noteId);
    await loadNotes();
  }

  // Get a note by ID
  Future<Map<String, dynamic>?> getNoteById(String noteId) async {
    return await _dbHelper.getNoteById(noteId);
  }

  /*// Fetch and set the current note by ID
  Future<void> loadNoteById(String noteId) async {
    _currentNote = await getNoteById(noteId);
    notifyListeners();
  }*/
}
