import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:keep_notes/DataModel.dart';


abstract class NotesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotesInitial extends NotesState {}

class NotesLoading extends NotesState {}

class NotesLoaded extends NotesState {
  final List<Map<String, dynamic>> notes;

  NotesLoaded(this.notes);

  @override
  List<Object?> get props => [notes];
}

class NotesError extends NotesState {
  final String message;

  NotesError(this.message);

  @override
  List<Object?> get props => [message];
}


class NotesCubit extends Cubit<NotesState> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  NotesCubit() : super(NotesInitial());

  // fetch notes from the database
  Future<void> loadNotes() async {
    try {
      emit(NotesLoading());
      final notes = await _dbHelper.getNotes();
      emit(NotesLoaded(notes));
    } catch (e) {
      emit(NotesError("Failed to load notes"));
    }
  }

  // Add a new note
  Future<void> insertNote(String title, String description) async {
    try {
      int timestamp = DateTime.now().millisecondsSinceEpoch;
      await _dbHelper.insertNote(
        title: title,
        desc: description,
        stamp: timestamp,
      );
      await loadNotes();
    } catch (e) {
      emit(NotesError("Failed to add note"));
    }
  }

  // Update an existing note
  Future<void> updateNote(String noteId, String title, String description) async {
    try {
      int timestamp = DateTime.now().millisecondsSinceEpoch;
      await _dbHelper.updateNote(
        noteId: noteId,
        title: title,
        description: description,
        stamp: timestamp,
      );
      await loadNotes();
    } catch (e) {
      emit(NotesError("Failed to update note"));
    }
  }

  // Delete a note
  Future<void> deleteNoteById(String noteId) async {
    try {
      await _dbHelper.deleteNoteById(noteId);
      await loadNotes();
    } catch (e) {
      emit(NotesError("Failed to delete note"));
    }
  }

  // Get a note by ID
  Future<Map<String, dynamic>?> getNoteById(String noteId) async {
    try {
      final note = await _dbHelper.getNoteById(noteId);
      if (note != null) {
        return note;
      } else {
        emit(NotesError("Note not found"));
        return null;
      }
    } catch (e) {
      emit(NotesError("Failed to fetch note"));
      return null;
    }
  }


}
