import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keep_notes/DataModel.dart';
import 'package:keep_notes/bloc/events.dart';
import 'package:keep_notes/bloc/notes_bloc.dart';
import 'package:keep_notes/bloc/states.dart';

class NoteEditor extends StatefulWidget {
  final String? noteId;
  final bool isEdit;

  NoteEditor({this.noteId, this.isEdit = false});

  @override
  _NoteEditorState createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.isEdit && widget.noteId != null && widget.noteId!.isNotEmpty) {
      context.read<NotesBloc>().add(GetNoteByIdEvent(widget.noteId!));
    }
  }

  //Add or Update Note
  void _saveNote() {
    String title = titleController.text;
    String description = descriptionController.text;

    if (title.isNotEmpty && description.isNotEmpty) {
      if (widget.isEdit) {
        context
            .read<NotesBloc>()
            .add(UpdateNoteEvent(widget.noteId!, title, description));
      } else {
        context.read<NotesBloc>().add(AddNoteEvent(title, description));
      }

      titleController.clear();
      descriptionController.clear();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              padding: EdgeInsets.all(6.0),
              child: Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
            )),
        backgroundColor: Colors.black,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: BlocBuilder<NotesBloc, NotesState>(builder: (context, state) {
          if (state is NoteByIdLoaded) {
            titleController.text = state.note[DatabaseHelper.Column_title] ?? '';
          }
          return TextField(
            controller: titleController,
            decoration: InputDecoration(
              hintText: widget.isEdit && titleController.text.isNotEmpty ? null : 'Title...',
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.white),
            ),
            style: TextStyle(color: Colors.white, fontSize: 18),
          );
        }),
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: Colors.white),
            onPressed: () {
              _saveNote();
            },
          ),
        ],
      ),
      body: BlocListener<NotesBloc, NotesState>(
        listener: (context, state) {
          if (state is NotesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<NotesBloc, NotesState>(
            builder: (context, state) {
              if (state is NoteByIdLoaded) {
                descriptionController.text = state.note[DatabaseHelper.Column_desc] ?? '';
              }
              return TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  hintText:
                      widget.isEdit && descriptionController.text.isNotEmpty ? null : 'Start typing...',
                  border: InputBorder.none,
                ),
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
              );
            },
          ),
        ),
      ),
    );
  }
}
