import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:keep_notes/NoteEditorUI.dart';
import 'package:keep_notes/NotesProvider.dart';
import 'package:provider/provider.dart';

class NoteUI extends StatefulWidget {
  @override
  _NoteUIState createState() => _NoteUIState();
}

class _NoteUIState extends State<NoteUI> {

  @override
  void initState() {
    super.initState();
    Provider.of<NotesProvider>(context, listen: false).loadNotes();
  }

  @override
  Widget build(BuildContext context) {

    final notesProvider = Provider.of<NotesProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text('Note Keeper', style: TextStyle(color: Colors.white)),
      ),
      body: notesProvider.notes.isEmpty
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
                      );
                    },
                    child: Text('Add Note'),
                  ),
                ],
              ),
            )
          : ListView.separated(
              itemCount: notesProvider.notes.length,
              itemBuilder: (context, index) {
                final note = notesProvider.notes[index];
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
                              builder: (context) => NoteEditor(noteId: noteId, isEdit: true),
                            ),
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
      floatingActionButton: notesProvider.notes.isNotEmpty
          ? FloatingActionButton(
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NoteEditor(isEdit: false),
                  ),
                );
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
                await Provider.of<NotesProvider>(context, listen: false).deleteNoteById(noteId);
                Navigator.of(context).pop();
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }
}
