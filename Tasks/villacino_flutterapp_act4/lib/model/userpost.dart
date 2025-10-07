class UserPost {
  final String userImg;
  final String userName;
  final String time;
  final String postContent;
  final String postImg;
  String numComments;
  final String numShare;
  bool isLiked;

  UserPost({
    required this.userImg,
    required this.userName,
    required this.time,
    required this.postContent,
    required this.postImg,
    required this.numComments,
    required this.numShare,
    required this.isLiked,
  });
}
