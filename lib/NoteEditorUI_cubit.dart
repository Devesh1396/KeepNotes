import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keep_notes/DataModel.dart';
import 'package:keep_notes/NotesCubit.dart';

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

  NotesCubit? notesCubit;

  @override
  void initState() {
    super.initState();

    notesCubit = context.read<NotesCubit>();

    if (widget.isEdit && widget.noteId != null && widget.noteId!.isNotEmpty) {
      _loadNoteData();
    }
  }

  // Fetching existing note data from Provider
  Future<void> _loadNoteData() async {
    Map<String, dynamic>? noteData = await notesCubit?.getNoteById(widget.noteId!);

    if (noteData != null) {
        titleController.text = noteData[DatabaseHelper.Column_title] ?? '';
        descriptionController.text = noteData[DatabaseHelper.Column_desc] ?? '';
    }
  }

  //Add or Update Note
  void _saveNote() async{
    String title = titleController.text;
    String description = descriptionController.text;

    if (title.isNotEmpty && description.isNotEmpty) {
      if (widget.isEdit) {
        await notesCubit?.updateNote(
            widget.noteId!,
            title,
            description,
            );
        titleController.clear();
        descriptionController.clear();
      } else {
        await notesCubit?.insertNote(
            title,
            description,
           );
        titleController.clear();
        descriptionController.clear();
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
            onPressed: (){
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
            )
        ),
        backgroundColor: Colors.black,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: TextField(
          controller: titleController,
          decoration: InputDecoration(
            hintText: widget.isEdit && titleController.text.isNotEmpty ? null : 'Title...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white),
          ),
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: Colors.white),
            onPressed: (){
              _saveNote();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: descriptionController,
          decoration: InputDecoration(
            hintText: widget.isEdit && descriptionController.text.isNotEmpty ? null : 'Start typing...',
            border: InputBorder.none,
          ),
          maxLines: null,
          expands: true,
          keyboardType: TextInputType.multiline,
        ),
      ),
    );
  }
}
