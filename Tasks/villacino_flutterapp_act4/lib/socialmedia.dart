import 'package:flutter/material.dart';
import 'package:villacino_flutterapp_act4/model/userdata.dart';
import 'package:villacino_flutterapp_act4/styles/TextStyles.dart';
import 'package:villacino_flutterapp_act4/views/friendlist.dart';
import 'package:villacino_flutterapp_act4/views/infoheader.dart';
import 'package:villacino_flutterapp_act4/views/mainheader.dart';
import 'package:villacino_flutterapp_act4/views/postlist.dart';

class SocialMedia extends StatefulWidget {
  const SocialMedia({super.key});

  @override
  State<SocialMedia> createState() => _SocialMediaState();
}

class _SocialMediaState extends State<SocialMedia> {
  UserData userData = UserData();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Instagram Ripoff Imnimninda"),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.grey),
        ),
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          MainHeader(userdata: userData),
          InfoHeader(userdata: userData),
          FriendList(userdata: userData),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: (Row(children: [Text('Posts', style: TextStyles.follow)])),
          ),
          const SizedBox(height: 20),
          PostList(userdata: userData),
        ],
      ),
    );
  }
}
