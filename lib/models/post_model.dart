import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String imageUrl;
  final String game;
  final String text;
  int likesCount;
  int disLikesCount;
  final int commentsCount;
  final String authorId;
  var video;
  final String youtubeId;
  final Timestamp timestamp;

  Post({
    this.id,
    this.game,
    this.imageUrl,
    this.text,
    this.likesCount,
    this.disLikesCount,
    this.commentsCount,
    this.authorId,
    this.video,
    this.youtubeId,
    this.timestamp,
  });

  factory Post.fromDoc(DocumentSnapshot doc) {
    Map data = doc.data();
    return Post(
      id: doc.id,
      game: data['game'],
      imageUrl: data['image'],
      text: data['text'],
      likesCount: data['likes'],
      disLikesCount: data['dislikes'],
      commentsCount: data['comments'],
      authorId: data['author'],
      video: data['video'],
      youtubeId: data['youtubeId'],
      timestamp: data['timestamp'],
    );
  }
}
