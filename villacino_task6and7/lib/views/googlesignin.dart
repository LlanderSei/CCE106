import 'package:flutter/material.dart';
import 'package:villacino_task6and7/controllers/AuthController.dart';
import 'package:villacino_task6and7/controllers/NoteController.dart';
import 'package:villacino_task6and7/views/notes.dart';

class GoogleSignIn extends StatefulWidget {
  const GoogleSignIn({super.key, required this.authController});
  final AuthController authController;

  @override
  State<GoogleSignIn> createState() => _GoogleSignInState();
}

class _GoogleSignInState extends State<GoogleSignIn> {
  String _status = 'Not Signed In';

  void _handleSignIn() async {
    final user = await widget.authController.signInWithGoogle();
    if (user != null) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Notes(noteController: NoteController()),
        ),
      );
    }
  }

  void _handleSignOut() async {
    await widget.authController.signOut();
    setState(() {
      _status = 'Signed Out';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Task 8 Villacino')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_status),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _handleSignIn,
              child: Text('Sign in with Google!'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _handleSignOut, child: Text('Sign out.')),
          ],
        ),
      ),
    );
  }
}
