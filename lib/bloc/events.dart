import 'package:equatable/equatable.dart';

abstract class NotesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Event to fetch
class FetchNotesEvent extends NotesEvent {}

// Event to add a new note
class AddNoteEvent extends NotesEvent {
  final String title;
  final String description;

  AddNoteEvent(this.title, this.description);

  @override
  List<Object?> get props => [title, description];
}

// Event to update an existing note
class UpdateNoteEvent extends NotesEvent {
  final String noteId;
  final String title;
  final String description;

  UpdateNoteEvent(this.noteId, this.title, this.description);

  @override
  List<Object?> get props => [noteId, title, description];
}

// Event to delete a note
class DeleteNoteEvent extends NotesEvent {
  final String noteId;

  DeleteNoteEvent(this.noteId);

  @override
  List<Object?> get props => [noteId];
}

// Event to get a note by ID
class GetNoteByIdEvent extends NotesEvent {
  final String noteId;

  GetNoteByIdEvent(this.noteId);

  @override
  List<Object?> get props => [noteId];
}
