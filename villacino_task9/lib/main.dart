import 'package:flutter/material.dart';
import 'package:villacino_task9/views/pokemonlist.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokemon List',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 245, 255, 110),
        ),
      ),
      home: PokemonList(),
    );
  }
}
