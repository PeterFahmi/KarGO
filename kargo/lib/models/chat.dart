import 'package:cloud_firestore/cloud_firestore.dart';

class Chat{
  String user1;
  String user2;
  CollectionReference messagesReference;

  Chat({required this.user1, required this.user2, required this.messagesReference});
}