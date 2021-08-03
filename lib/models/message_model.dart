import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String sender;
  final String message;
  final dynamic timestamp;
  final String type;

  Message({this.id, this.sender, this.message, this.timestamp, this.type});

  factory Message.fromDoc(DocumentSnapshot doc) {
    Map data = doc.data();

    return Message(
      id: doc.id,
      sender: data['sender'],
      message: data['message'],
      timestamp: data['timestamp'],
      type: data['type'],
    );
  }
}
