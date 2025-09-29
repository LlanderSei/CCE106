import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:statefulwidget_villacino/pages/todo_app.dart';

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
      title: 'Todo App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 255, 159, 255),
        ),
        useMaterial3: true,
      ),
      home: const TodoHomePage(),
    );
  }
}
