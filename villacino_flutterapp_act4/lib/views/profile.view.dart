import 'package:flutter/material.dart';
import 'package:villacino_flutterapp_act4/model/usercomment.dart';
import 'package:villacino_flutterapp_act4/model/userdata.dart';
import 'package:villacino_flutterapp_act4/model/userpost.dart';
import 'package:villacino_flutterapp_act4/styles/TextStyles.dart';
import 'package:uuid/uuid.dart';

class ProfileView extends StatefulWidget {
  final UserPost userPost;
  final List<UserComment> comments;
  final VoidCallback? onCommentAdded; // Optional callback to notify PostList

  ProfileView({
    super.key,
    required this.userPost,
    required this.comments,
    this.onCommentAdded,
  });

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final TextEditingController _commentController = TextEditingController();
  final UserData userData = UserData();

  void _addComment() {
    if (_commentController.text.trim().isEmpty) return;

    final newComment = UserComment(
      id: Uuid().v4(),
      postId: widget.userPost.userName,
      commenterImg: userData.myUserAcc.img,
      commenterName: userData.myUserAcc.name,
      commenterTime: DateTime.now().toString(),
      commenterContent: _commentController.text,
    );

    setState(() {
      widget.comments.add(newComment);
      widget.userPost.numComments = (int.parse(widget.userPost.numComments) + 1)
          .toString();
      _commentController.clear();
      widget.onCommentAdded?.call(); // Notify PostList to update its state
    });
  }

  Widget commentBtn(UserComment userComment) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(
          userComment.commenterTime,
          style: TextStyles.name.copyWith(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(width: 8),
        Text('Like', style: TextStyles.name),
        const SizedBox(width: 8),
        Text('Reply', style: TextStyles.name),
      ],
    ),
  );

  Widget commentDesc(UserComment userComment) => Padding(
    padding: const EdgeInsets.all(10),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(userComment.commenterName, style: TextStyles.bold),
        const SizedBox(height: 4),
        Text(userComment.commenterContent, style: TextStyles.name),
      ],
    ),
  );

  Widget commentSpace(UserComment userComment) => Container(
    decoration: const BoxDecoration(
      color: Color.fromARGB(255, 104, 104, 104),
      borderRadius: BorderRadius.all(Radius.circular(20)),
    ),
    child: commentDesc(userComment),
  );

  Widget commenterPic(UserComment userComment) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: CircleAvatar(
      radius: 20,
      backgroundImage: AssetImage(userComment.commenterImg),
    ),
  );

  Widget userCommenterLine(UserComment userComment) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      commenterPic(userComment),
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [commentSpace(userComment), commentBtn(userComment)],
      ),
    ],
  );

  Widget userPostDetails(UserComment userComment) => Column(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [const SizedBox(height: 10), userCommenterLine(userComment)],
  );

  Widget commenters(UserPost userPost) => Column(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      const Divider(color: Colors.grey),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${userPost.numComments} Comments', style: TextStyles.bold),
            Row(
              children: [
                Text('All comments', style: TextStyles.bold),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ],
        ),
      ),
      // Comment input field
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
                  border: OutlineInputBorder(),
                  hintStyle: TextStyles.name,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send, color: Colors.blue),
              onPressed: _addComment,
            ),
          ],
        ),
      ),
    ],
  );

  Widget buttons(UserPost userPost) => Column(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Divider(color: Colors.grey[300]),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: userPost.isLiked ? Colors.grey : Colors.blue,
              ),
              onPressed: () {
                setState(() {
                  userPost.isLiked = !userPost.isLiked;
                });
              },
              icon: Icon(
                userPost.isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                size: 20,
              ),
              label: const Text('Like'),
            ),
            TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
              onPressed: () {},
              icon: const Icon(Icons.comment, size: 20),
              label: const Text('Comment'),
            ),
            TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
              onPressed: () {},
              icon: const Icon(Icons.share, size: 20),
              label: const Text('Share'),
            ),
          ],
        ),
      ),
    ],
  );

  Widget userLine(UserPost userPost) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: CircleAvatar(
          radius: 20,
          backgroundImage: AssetImage(userPost.userImg),
        ),
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(userPost.userName, style: TextStyles.boldBlue),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(userPost.time, style: TextStyles.name),
              const SizedBox(width: 8),
              const Icon(Icons.public, size: 16, color: Colors.grey),
            ],
          ),
        ],
      ),
    ],
  );

  Widget postImage(UserPost userPost) => Padding(
    padding: const EdgeInsets.all(10),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(children: [Text(userPost.postContent)]),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            userPost.postImg,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        bottomOpacity: 0,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          userLine(widget.userPost),
          postImage(widget.userPost),
          buttons(widget.userPost),
          commenters(widget.userPost),
          ...widget.comments.map((userComment) => userPostDetails(userComment)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
