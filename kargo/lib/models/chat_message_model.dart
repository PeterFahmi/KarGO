import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessages {
  String idFrom;
  String timestamp;
  String content;
  bool seen;

  ChatMessages(
      {required this.idFrom,
      required this.timestamp,
      required this.content,
      required this.seen});

  Map<String, dynamic> toJson() {
    return {
      "sender": idFrom,
      "date": timestamp,
      "content": content,
      "seen": seen,
    };
  }

  factory ChatMessages.fromDocument(DocumentSnapshot documentSnapshot) {
    String idFrom = documentSnapshot.get("sender");
    String timestamp = documentSnapshot.get("date");
    String content = documentSnapshot.get("content");
    bool seen = documentSnapshot.get("seenn");

    return ChatMessages(
        idFrom: idFrom,
        timestamp: timestamp,
        content: content,
        seen: seen);
  }
}
