import 'package:flutter/material.dart';
import 'package:villacino_flutterapp_act4/model/userdata.dart';

class InfoHeader extends StatefulWidget {
  const InfoHeader({super.key, required this.userdata});
  final UserData userdata;

  @override
  State<InfoHeader> createState() => _InfoHeaderState();
}

class _InfoHeaderState extends State<InfoHeader> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('Followers'),
            Text('Posts'),
            Text('Following'),
            Text('Friends'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(widget.userdata.myUserAcc.numFollowers),
            Text(widget.userdata.myUserAcc.numPosts),
            Text(widget.userdata.myUserAcc.numFollowing),
            Text(widget.userdata.myUserAcc.numFriends),
          ],
        ),
        const SizedBox(height: 10),
        const Divider(height: 1, color: Colors.grey),
      ],
    );
  }
}
