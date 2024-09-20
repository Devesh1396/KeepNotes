import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keep_notes/NotesCubit.dart';
import 'package:keep_notes/Noteshome_UI.dart';
import 'package:keep_notes/bloc/events.dart';
import 'package:keep_notes/bloc/notes_bloc.dart';

/*void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => NotesProvider(),
      child: MyApp(),
    ),
  );
}*/

// void main() {
//   runApp(
//     BlocProvider(
//       create: (context) => NotesCubit()..loadNotes(),
//       child: MyApp(),
//     ),
//   );
// }

void main() {
  runApp(
    BlocProvider(
      create: (context) => NotesBloc()..add(FetchNotesEvent()),
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


