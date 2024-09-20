import 'package:equatable/equatable.dart';


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

class NoteByIdLoaded extends NotesState {
  final Map<String, dynamic> note;

  NoteByIdLoaded(this.note);

  @override
  List<Object?> get props => [note];
}

class NotesError extends NotesState {
  final String message;

  NotesError(this.message);

  @override
  List<Object?> get props => [message];
}
