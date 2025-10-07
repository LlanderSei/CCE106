import 'package:flutter/material.dart';

class StarwberryScreen extends StatelessWidget {
  const StarwberryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String StrawberryTextHeader = "A Stawberry Shortcake";
    String StrawberryTextDetails = "It is a strawberry shortcake, indeed...";
    return Scaffold(
      appBar: AppBar(
        title: Text('Villacino Activity 1'),
        backgroundColor: Color.fromARGB(255, 252, 143, 180),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/Strawberry-Cake.jpg',
            height: 600,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              StrawberryTextHeader,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Text(
              StrawberryTextDetails,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
