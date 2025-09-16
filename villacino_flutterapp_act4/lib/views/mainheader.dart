import 'package:flutter/material.dart';
import 'package:villacino_flutterapp_act4/model/userdata.dart';

class MainHeader extends StatelessWidget {
  const MainHeader({super.key, required this.userdata});
  final UserData userdata;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage(userdata.myUserAcc.img),
        ),
        Text(
          userdata.myUserAcc.name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(userdata.myUserAcc.email),
        const SizedBox(height: 10),
      ],
    );
  }
}
