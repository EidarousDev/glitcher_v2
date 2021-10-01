import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  final String id;
  final String name;
  final String image;
  final dynamic timestamp;

  Group({
    this.id,
    this.name,
    this.image,
    this.timestamp,
  });

  factory Group.fromDoc(DocumentSnapshot doc) {
    Map data = doc.data();

    return Group(
      id: doc.id,
      name: data['name'],
      image: data['image'],
      timestamp: data['timestamp'],
    );
  }
}
