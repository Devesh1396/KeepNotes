import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:keep_notes/NoteEditorUI.dart';
import 'package:keep_notes/NotesCubit.dart';

class NoteUI extends StatelessWidget {
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
      body: BlocBuilder<NotesCubit, NotesState>(
        builder: (context, state) {
          if (state is NotesLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is NotesLoaded) {
            if (state.notes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Add Your First Note',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
              );
            } else {
              return ListView.separated(
                itemCount: state.notes.length,
                itemBuilder: (context, index) {
                  final note = state.notes[index];

                  String noteId = note['uid'].toString();
                  int timestamp = note['timestamp'];

                  DateTime dateTime =
                      DateTime.fromMillisecondsSinceEpoch(timestamp);
                  String formattedDate =
                      DateFormat('dd/MM/yy').format(dateTime);

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
                                builder: (context) =>
                                    NoteEditor(noteId: noteId, isEdit: true),
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
              );
            }
          } else if (state is NotesError) {
            return Center(child: Text(state.message));
          } else {
            return Center(child: Text('Unknown state'));
          }
        },
      ),
      floatingActionButton: BlocBuilder<NotesCubit, NotesState>(
        builder: (context, state) {
          if (state is NotesLoaded && state.notes.isNotEmpty) {
            return FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NoteEditor(isEdit: false),
                  ),
                );
              },
              child: Icon(Icons.add, color: Colors.black),
              backgroundColor: Colors.white,
            );
          } else {
            return SizedBox.shrink();
          }
        },
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, String noteId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BlocListener<NotesCubit, NotesState>(
          listener: (context, state) {
            if (state is NotesError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          child: AlertDialog(
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
                  await context.read<NotesCubit>().deleteNoteById(noteId);
                  Navigator.of(context).pop();
                },
                child: Text("Yes"),
              ),
            ],
          ),
        );
      },
    );
  }
}
