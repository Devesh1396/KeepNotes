import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keep_notes/DataModel.dart';
import 'package:keep_notes/bloc/events.dart';
import 'package:keep_notes/bloc/states.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {

  final DatabaseHelper _dbHelper = DatabaseHelper();

  NotesBloc() : super(NotesInitial()) {

    // Event -> State Map
    on<FetchNotesEvent>(_onFetchNotes);
    on<AddNoteEvent>(_onInsertNote);
    on<UpdateNoteEvent>(_onUpdateNote);
    on<DeleteNoteEvent>(_onDeleteNote);
    on<GetNoteByIdEvent>(_onGetNoteById);
  }

  // Fetch all notes
  Future<void> _onFetchNotes(FetchNotesEvent event, Emitter<NotesState> emit) async {
    try {
      emit(NotesLoading());
      final notes = await _dbHelper.getNotes();
      emit(NotesLoaded(notes));
    } catch (e) {
      emit(NotesError("Failed to load notes"));
    }
  }

  // Insert
  Future<void> _onInsertNote(AddNoteEvent event, Emitter<NotesState> emit) async {
    try {
      await _dbHelper.insertNote(
        title: event.title,
        desc: event.description,
        stamp: DateTime.now().millisecondsSinceEpoch,
      );
      add(FetchNotesEvent());
    } catch (e) {
      emit(NotesError("Failed to add note"));
    }
  }

  // Update
  Future<void> _onUpdateNote(UpdateNoteEvent event, Emitter<NotesState> emit) async {
    try {
      await _dbHelper.updateNote(
        noteId: event.noteId,
        title: event.title,
        description: event.description,
        stamp: DateTime.now().millisecondsSinceEpoch,
      );
      add(FetchNotesEvent());
    } catch (e) {
      emit(NotesError("Failed to update note"));
    }
  }

  // Delete
  Future<void> _onDeleteNote(DeleteNoteEvent event, Emitter<NotesState> emit) async {
    try {
      await _dbHelper.deleteNoteById(event.noteId);
      add(FetchNotesEvent());
    } catch (e) {
      emit(NotesError("Failed to delete note"));
    }
  }

  // Get a note by ID
  Future<void> _onGetNoteById(GetNoteByIdEvent event, Emitter<NotesState> emit) async {
    try {
      final note = await _dbHelper.getNoteById(event.noteId);
      emit(NoteByIdLoaded(note!));
    } catch (e) {
      emit(NotesError("Failed to get a note"));
    }
  }
}
