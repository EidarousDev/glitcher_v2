import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String commenterID;
  final String text;
  int likesCount;
  int disLikesCount;
  int repliesCount;
  final Timestamp timestamp;

  Comment({
    this.id,
    this.commenterID,
    this.text,
    this.likesCount,
    this.disLikesCount,
    this.repliesCount,
    this.timestamp,
  });

  factory Comment.fromDoc(DocumentSnapshot doc) {
    Map data = doc.data();

    return Comment(
      id: doc.id,
      commenterID: data['commenter'],
      text: data['text'],
      likesCount: data['likes'],
      disLikesCount: data['dislikes'],
      repliesCount: data['replies'],
      timestamp: data['timestamp'],
    );
  }
}
