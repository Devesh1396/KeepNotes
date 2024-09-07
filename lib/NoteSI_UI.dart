import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:keep_notes/DataModel.dart';

class NoteUI extends StatefulWidget {
  @override
  _NoteUIState createState() => _NoteUIState();
}

class _NoteUIState extends State<NoteUI> {
  List<Map<String, dynamic>> _notes = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() async {
    final data = await _dbHelper.getNotes();
    setState(() {
      _notes = data;
    });
  }

  void _addNote() async {
    await _dbHelper.insertNote(
        title: titleController.text,
        desc: descriptionController.text,
        stamp: DateTime.now().millisecondsSinceEpoch);
    titleController.clear();
    descriptionController.clear();
    _loadNotes();
  }

  void _updateNote(String noteId, String title, String description) async {
    await _dbHelper.updateNote(
        noteId: noteId,
        title: title,
        description: description,
        stamp: DateTime.now().millisecondsSinceEpoch);
    titleController.clear();
    descriptionController.clear();
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text('Note Keeper', style: TextStyle(color: Colors.white)),
      ),
      body: _notes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Add Your First Note',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _showBottomSheet(context: context, isEdit: false);
                    },
                    child: Text('Add Note'),
                  ),
                ],
              ),
            )
          : ListView.separated(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                String noteId = note['uid'].toString();

                int timestamp = note['timestamp'];
                DateTime dateTime =
                    DateTime.fromMillisecondsSinceEpoch(timestamp);
                String formattedDate = DateFormat('dd/MM/yy').format(dateTime);

                return ListTile(
                  leading: Text('${index + 1}'),
                  title: Text(note['title']),
                  subtitle:
                      Text('${note['desc']}\nLast Modified: $formattedDate'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _showBottomSheet(
                            context: context,
                            noteId: noteId,
                            isEdit: true,
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _showDeleteConfirmDialog(context, noteId);
                        },
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) => Divider(),
            ),
      floatingActionButton: _notes.isNotEmpty
          ? FloatingActionButton(
              onPressed: (){
                titleController.clear();
                descriptionController.clear();
                _showBottomSheet(context: context, isEdit: false);
              },
              child: Icon(Icons.add, color: Colors.black),
            )
          : null,
    );
  }

  Future<void> _showBottomSheet({required BuildContext context, String? noteId, required bool isEdit}) async {

    String modalTitle = isEdit ? 'Update Your Note' : 'Add Your Note';
    String buttonText = isEdit ? 'Update' : 'Save';

    if (isEdit && noteId != null) {
      Map<String, dynamic>? noteData = await _dbHelper.getNoteById(noteId);

      if (noteData != null) {
        titleController.text = noteData[DatabaseHelper.Column_title];
        descriptionController.text = noteData[DatabaseHelper.Column_desc];
      }
    }
    showModalBottomSheet(
      isScrollControlled: true,
      enableDrag: false,
      barrierColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Wrap(  // Wrap ensures the modal grows as needed
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            modalTitle,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(labelText: 'Title'),
                      ),
                      TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(labelText: 'Description'),
                        maxLines: 3,
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        child: Text(buttonText),
                        onPressed: () {
                          if (titleController.text.isNotEmpty &&
                              descriptionController.text.isNotEmpty) {
                            if (isEdit) {
                              _updateNote(noteId!, titleController.text,
                                  descriptionController.text);
                            } else {
                              _addNote();
                            }
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, String noteId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          title: Text("Wait!"),
          content: Text("Are you sure you want to delete this note?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("No"),
            ),
            TextButton(
              onPressed: () async {
                await _dbHelper.deleteNoteById(noteId);
                Navigator.of(context).pop();
                _loadNotes();
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }
}
