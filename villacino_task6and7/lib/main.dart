import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:villacino_task6and7/controllers/NoteController.dart';
import 'package:villacino_task6and7/views/notes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 230, 157, 189),
        ),
      ),
      home: Notes(noteController: NoteController()),
    );
  }
}
