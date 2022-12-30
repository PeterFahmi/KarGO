import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

class DatabaseService{
  final String? uid;
  DatabaseService({this.uid});

  final CollectionReference userCollection = FirebaseFirestore.instance.collection("users");
  final CollectionReference chatCollection = FirebaseFirestore.instance.collection("chats");

  Future gettingUserData(String email) async{
    QuerySnapshot snapshot = await userCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }

  getUserChats() async{
    return userCollection.doc(uid).snapshots();
  }

  Future<Stream<QuerySnapshot<Map<String, dynamic>>>> getCollectionFromDocument(DocumentReference ref) async{
    return ref.collection("messages").snapshots();
  }

  sendMessage(DocumentReference chatReference, Map<String,dynamic> message){
    //TODO: handle non-text messages + delivered and seen functionality
    Map<String,dynamic> messageData = reformatMessageJson(message);
    chatReference.collection("messages").add(messageData);

    //TODO: add most recent message functionality to code & schema 
  }
  
  Map<String,dynamic> reformatMessageJson(Map<String, dynamic> message) {
    Map<String,dynamic> newMsg = {};
    newMsg['content'] = message['text'];
    newMsg['date'] = Timestamp.fromDate(DateTime.parse(message['id']));
    newMsg['sender'] = message['author']['id'];
    newMsg['seen'] = true;
    return newMsg;
  }
}