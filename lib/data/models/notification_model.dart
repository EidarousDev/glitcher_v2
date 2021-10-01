import 'package:cloud_firestore/cloud_firestore.dart';

class Notification {
  final String id;
  final String title;
  final String body;
  final String icon;
  final bool seen;
  final Timestamp timestamp;
  final String sender;
  final String objectId;
  final String type;

  Notification(
      {this.id,
      this.title,
      this.body,
      this.icon,
      this.seen,
      this.timestamp,
      this.sender,
      this.objectId,
      this.type});

  factory Notification.fromDoc(DocumentSnapshot doc) {
    Map data = doc.data();

    return Notification(
        id: doc.id,
        title: data['title'],
        body: data['body'],
        icon: data['icon'],
        seen: data['seen'],
        timestamp: data['timestamp'],
        sender: data['sender'],
        objectId: data['object_id'],
        type: data['type']);
  }
}
