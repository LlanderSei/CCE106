import 'package:flutter/material.dart';
import 'package:villacino_flutterapp_act4/model/friend.dart';
import 'package:villacino_flutterapp_act4/model/userdata.dart';
import 'package:villacino_flutterapp_act4/styles/TextStyles.dart';

class FriendList extends StatelessWidget {
  const FriendList({super.key, required this.userdata});

  final UserData userdata;

  Widget friend(Friend friend) => Card(
    child: Column(
      children: [
        Expanded(child: Image.asset(friend.img)),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(friend.name, style: TextStyles.follow),
        ),
      ],
    ),
  );

  Widget friendListGrid() => GridView.builder(
    shrinkWrap: true,
    physics: const BouncingScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      mainAxisExtent: 180,
    ),
    itemCount: userdata.friendList.length,
    itemBuilder: (BuildContext context, index) {
      return friend(userdata.friendList[index]);
    },
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Row(children: [Text('${userdata.friendList.length} Friends')]),
        ),
        const SizedBox(height: 10),
        SizedBox(height: 380, child: friendListGrid()),
        SizedBox(height: 10, child: Container(color: Colors.grey[300])),
      ],
    );
  }
}
