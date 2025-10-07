import 'package:villacino_flutterapp_act4/model/account.dart';
import 'package:villacino_flutterapp_act4/model/friend.dart';
import 'package:villacino_flutterapp_act4/model/usercomment.dart';
import 'package:villacino_flutterapp_act4/model/userpost.dart';

class UserData {
  List<UserPost> userList = [
    UserPost(
      userImg: "assets/persons/person1.png",
      userName: "Gigga",
      time: DateTime.now().toString(),
      postContent: 'I love IGG NATION!11!11',
      postImg: 'assets/things/igg.png',
      numComments: '69420',
      numShare: 'KRAZY AMOUNTS OF LIKES FRFR',
      isLiked: true,
    ),
    UserPost(
      userImg: "assets/persons/person2.png",
      userName: "ILove CP",
      time: "Just now...",
      postContent: "Rape my cp 😄",
      postImg: 'assets/things/phonething.png',
      numComments: '69420',
      numShare: '-9999999999 you\'re doomed nigga',
      isLiked: false,
    ),
    UserPost(
      userImg: "assets/persons/person3.png",
      userName: "Dark Humor Enjoyer",
      time: DateTime.now().toString(),
      postContent: "Lmfao 😂😂😂😂😂",
      postImg: 'assets/things/911.png',
      numComments: '- $double.maxFinite.toString()',
      numShare:
          '-9999999999 $double.maxFinite.toString() you\'re also doomed nigga',
      isLiked: true,
    ),
    UserPost(
      userImg: "assets/persons/person4.png",
      userName: "Rock Lloyd",
      time: DateTime.now().toString(),
      postContent: "Im edging to ts frfr ✌🏻✌🏻✌🏻✌🏻",
      postImg: 'assets/things/67.png',
      numComments: '- $double.maxFinite.toString()',
      numShare:
          '-9999999999 $double.maxFinite.toString() you\'re also doomed nigga',
      isLiked: true,
    ),
  ];

  List<Friend> friendList = [
    Friend(img: 'assets/persons/person1.png', name: "Gigga"),
    Friend(img: 'assets/persons/person2.png', name: "ILove CP"),
    Friend(img: 'assets/persons/person3.png', name: "Dark Humor Enjoyer"),
    Friend(img: 'assets/persons/person4.png', name: "Rock Lloyd"),
    Friend(img: 'assets/persons/person5.png', name: "Inverted Triangle"),
  ];

  // List<UserComment> commentList = [
  //   UserComment(
  //     commenterImg: 'assets/persons/person5.png',
  //     commenterName: 'Inverted Triangle',
  //     commenterTime: 'Not long ago...',
  //     commenterContent: 'is ts fr????',
  //   ),
  // ];

  Account myUserAcc = Account(
    name: 'Llander',
    email: 'llander@test.com',
    img: 'assets/llander.png',
    numFollowers: 'Infinite',
    numPosts: 'Bottomless',
    numFollowing: 'Unfathomable',
    numFriends: 'Only "True" number of friends lol.',
  );
}
