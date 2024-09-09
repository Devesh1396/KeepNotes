import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:keep_notes/DataModel.dart';
import 'package:keep_notes/NoteEditorUI.dart';

class NoteUI extends StatefulWidget {
  @override
  _NoteUIState createState() => _NoteUIState();
}

class _NoteUIState extends State<NoteUI> {
  List<Map<String, dynamic>> _notes = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NoteEditor(isEdit: false),
                        ),
                      ).then((value) => _loadNotes());
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NoteEditor(noteId: noteId, isEdit: true),  // Navigate to the AddNoteScreen
                            ),
                          ).then((value) => _loadNotes());
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NoteEditor(isEdit: false),  // Navigate to the AddNoteScreen
                  ),
                ).then((value) => _loadNotes());
              },
              child: Icon(Icons.add, color: Colors.black),
            )
          : null,
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
