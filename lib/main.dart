import 'package:flutter/material.dart';
import 'package:keep_notes/NotesProvider.dart';
import 'package:keep_notes/Noteshome_UI.dart';
import 'package:provider/provider.dart';


void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => NotesProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: NoteUI(),
      debugShowCheckedModeBanner: false,
    );
  }
}


