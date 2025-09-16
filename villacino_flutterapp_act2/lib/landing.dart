import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  final String username;
  final String password;
  const LandingPage({
    super.key,
    required this.username,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Villacino Task 2")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome, $username!", style: const TextStyle(fontSize: 30)),
            SizedBox(height: 20),
            Text("Your password is:", style: const TextStyle(fontSize: 30)),
            Text("\"$password\"", style: const TextStyle(fontSize: 30)),
            Text("🥶😱☠", style: const TextStyle(fontSize: 30)),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Back to Login"),
            ),
          ],
        ),
      ),
    );
  }
}
