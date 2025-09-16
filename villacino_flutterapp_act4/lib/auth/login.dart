import 'package:flutter/material.dart';
import 'package:villacino_flutterapp_act4/socialmedia.dart';
import 'package:villacino_flutterapp_act4/styles/TextStyles.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  // Controllers and variables
  static TextEditingController usernameController = TextEditingController();
  static TextEditingController passwordController = TextEditingController();

  // Variables...?
  static late String errorMessage;
  static late bool isError;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  @override
  void initState() {
    LoginForm.errorMessage = "This is an error message.";
    LoginForm.isError = false;
    super.initState();
  }

  @override
  void dispose() {
    LoginForm.usernameController.dispose();
    LoginForm.passwordController.dispose();
    super.dispose();
  }

  void checkLogin(username, password) {
    setState(() {
      if (username.isEmpty || password.isEmpty) {
        LoginForm.errorMessage = "Please fill all the fields.";
        LoginForm.isError = true;
        return;
      }
      if (username != 'llander' && password != 'llander') {
        LoginForm.errorMessage = "Incorrect authentication.";
        LoginForm.isError = true;
        return;
      }
      LoginForm.errorMessage = "";
      LoginForm.isError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/logo.png', height: 48, width: 48),
                  const SizedBox(width: 12),
                  Text("Instagram Ripoff Logo", style: TextStyles.login),
                ],
              ),
              SizedBox(height: 15),
              TextField(
                controller: LoginForm.usernameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Enter Username",
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: LoginForm.passwordController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Enter Password",
                  prefixIcon: Icon(Icons.password),
                ),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.blue,
                ),
                onPressed: () {
                  checkLogin(
                    LoginForm.usernameController.text,
                    LoginForm.passwordController.text,
                  );
                  if (!LoginForm.isError) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SocialMedia()),
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Login Failed"),
                          content: Text(LoginForm.errorMessage),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("OK"),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: Text('L O G I N', style: TextStyles.login),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
