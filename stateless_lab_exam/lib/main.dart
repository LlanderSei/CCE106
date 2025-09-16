import 'package:flutter/material.dart';
import 'package:stateless_lab_exam/views/StudentDashboard.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Student Dashboard",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 249, 178, 255))
      ),
      home: const StudentDashboard(),
    );
  }
}
