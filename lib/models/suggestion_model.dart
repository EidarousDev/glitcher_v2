import 'package:cloud_firestore/cloud_firestore.dart';

class Suggestion {
  final String id;
  final String title;
  final String details;
  final String submitter;
  final String gameId;
  final bool dealt;
  final Timestamp timestamp;

  Suggestion({
    this.id,
    this.title,
    this.details,
    this.submitter,
    this.gameId,
    this.dealt,
    this.timestamp,
  });

  factory Suggestion.fromDoc(DocumentSnapshot doc) {
    Map data = doc.data();

    return Suggestion(
      id: doc.id,
      title: data['title'],
      details: data['details'],
      submitter: data['submitter'],
      gameId: data['game_id'],
      dealt: data['dealt'],
      timestamp: data['timestamp'],
    );
  }
}
