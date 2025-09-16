import 'package:flutter/material.dart';
import 'package:villacino_flutterapp_act4/model/userdata.dart';
import 'package:villacino_flutterapp_act4/model/userpost.dart';
import 'package:villacino_flutterapp_act4/model/usercomment.dart';
import 'package:villacino_flutterapp_act4/styles/TextStyles.dart';
import 'package:villacino_flutterapp_act4/views/profile.view.dart';
import 'package:uuid/uuid.dart';

class PostList extends StatefulWidget {
  const PostList({super.key, required this.userdata});
  final UserData userdata;

  @override
  State<PostList> createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  // Temporary in-memory storage for comments
  final Map<String, List<UserComment>> _postComments = {};
  final Map<String, TextEditingController> _commentControllers = {};
  final Map<String, bool> _showCommentInput = {};

  @override
  void initState() {
    super.initState();
    // Initialize controllers and comment lists for each post
    for (var post in widget.userdata.userList) {
      _commentControllers[post.userName] = TextEditingController();
      _postComments[post.userName] = [];
      _showCommentInput[post.userName] = false;
    }
  }

  @override
  void dispose() {
    // Dispose controllers
    _commentControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _addComment(String postId, UserPost post, String content) {
    if (content.trim().isEmpty) return;

    setState(() {
      final comment = UserComment(
        id: Uuid().v4(),
        postId: postId,
        commenterImg: widget.userdata.myUserAcc.img,
        commenterName: widget.userdata.myUserAcc.name,
        commenterTime: DateTime.now().toString(),
        commenterContent: content,
      );
      _postComments[postId]!.add(comment);
      _commentControllers[postId]!.clear();
      // Increment numComments for display
      post.numComments = (int.parse(post.numComments) + 1).toString();
    });
  }

  void _toggleCommentInput(String postId) {
    setState(() {
      _showCommentInput[postId] = !(_showCommentInput[postId] ?? false);
    });
  }

  void goToPage(BuildContext context, UserPost userPost) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ProfileView(
        userPost: userPost,
        comments: _postComments[userPost.userName] ?? [],
      ),
    ));
  }

  Widget buttons(UserPost userPost) => Row(
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
              userPost.isLiked
                  ? Icons.thumb_up
                  : Icons.thumb_up_alt_outlined,
              size: 20,
            ),
            label: const Text('Like'),
          ),
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
            onPressed: () => _toggleCommentInput(userPost.userName),
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
      );

  Widget postCount(UserPost userPost) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('${userPost.numComments} Comments'),
          const SizedBox(width: 10),
          Text('${userPost.numShare} Shares'),
        ],
      );

  Widget postImage(UserPost userPost) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(userPost.postImg),
              fit: BoxFit.fill,
            ),
          ),
        ),
      );

  Widget postHeader(UserPost userPost) => Row(
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
              Text(userPost.userName, style: TextStyles.name),
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

  Widget showPost(UserPost userPost) => Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                postHeader(userPost),
                const SizedBox(height: 10),
                Row(children: [Text(userPost.postContent)]),
                postImage(userPost),
                postCount(userPost),
                const Divider(thickness: 1, color: Colors.grey),
                buttons(userPost),
                // Comment input field
                if (_showCommentInput[userPost.userName] ?? false) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentControllers[userPost.userName],
                          decoration: InputDecoration(
                            hintText: 'Add a comment...',
                            border: OutlineInputBorder(),
                            hintStyle: TextStyles.name,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send, color: Colors.blue),
                        onPressed: () => _addComment(
                          userPost.userName,
                          userPost,
                          _commentControllers[userPost.userName]!.text,
                        ),
                      ),
                    ],
                  ),
                ],
                // Display comments
                if (_postComments[userPost.userName]?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 8),
                  Text('Comments:', style: TextStyles.bold),
                  ..._postComments[userPost.userName]!.map((comment) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundImage: AssetImage(comment.commenterImg),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(comment.commenterName,
                                      style: TextStyles.name),
                                  Text(comment.commenterContent,
                                      style: TextStyles.name),
                                  Text(comment.commenterTime,
                                      style: TextStyles.name.copyWith(
                                          fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(color: Colors.grey[300], height: 10),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widget.userdata.userList.map((userPost) {
        return InkWell(
          onTap: () => goToPage(context, userPost),
          child: showPost(userPost),
        );
      }).toList(),
    );
  }
}