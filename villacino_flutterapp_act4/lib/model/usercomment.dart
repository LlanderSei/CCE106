class UserComment {
  final String id;
  final String postId;
  final String commenterImg;
  final String commenterName;
  final String commenterTime;
  final String commenterContent;

  UserComment({
    required this.id,
    required this.postId,
    required this.commenterImg,
    required this.commenterName,
    required this.commenterTime,
    required this.commenterContent,
  });
}
