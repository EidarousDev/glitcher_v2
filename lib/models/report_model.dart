import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  final String id;
  final String reason;
  final String details;
  final String postAuthor;
  final String postId;
  final String submitter;
  final bool dealt;
  final Timestamp timestamp;

  Report({
    this.id,
    this.reason,
    this.details,
    this.postAuthor,
    this.postId,
    this.submitter,
    this.dealt,
    this.timestamp,
  });

  factory Report.fromDoc(DocumentSnapshot doc) {
    Map data = doc.data();

    return Report(
      id: doc.id,
      reason: data['reason'],
      details: data['details'],
      postAuthor: data['post_author'],
      postId: data['post_id'],
      submitter: data['submitter'],
      dealt: data['dealt'],
      timestamp: data['timestamp'],
    );
  }
}
