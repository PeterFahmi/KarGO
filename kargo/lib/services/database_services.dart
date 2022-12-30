import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");
  final CollectionReference chatCollection =
      FirebaseFirestore.instance.collection("chats");

  Future gettingUserData(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }

  getUserChats() async {
    return userCollection.doc(uid).snapshots();
  }

  Future<Stream<QuerySnapshot<Map<String, dynamic>>>> getCollectionFromDocument(
      DocumentReference ref) async {
    return ref.collection("messages").snapshots();
  }

  sendMessage(DocumentReference chatReference, Map<String, dynamic> message) {
    //TODO: handle non-text messages + delivered and seen functionality
    Map<String, dynamic> messageData = reformatMessageJson(message);
    chatReference.collection("messages").add(messageData);
    chatReference.update({
      "recentMessage": messageData['content'],
      "recentMessageSender": messageData['sender'],
      "recentMessageTime": messageData['date']
    });
    //TODO: add most recent message functionality to code & schema
  }

  Map<String, dynamic> reformatMessageJson(Map<String, dynamic> message){
    Map<String, dynamic> messageData = {};
    if(message['type'] == "text") {
      messageData = reformatTextMessageJson(message);
    }
    else if(message['type'] == "image"){
      messageData = reformatImageMessageJson(message);
    }
    return messageData;
  }

  Map<String, dynamic> reformatTextMessageJson(Map<String, dynamic> message) {
    Map<String, dynamic> newMsg = {};
    newMsg['content'] = message['text'];
    newMsg['date'] = Timestamp.fromDate(DateTime.parse(message['id']));
    newMsg['sender'] = message['author']['id'];
    newMsg['seen'] = true;
    newMsg['type'] = message['type'];
    return newMsg;
  }

  Map<String, dynamic> reformatImageMessageJson(Map<String, dynamic> message) {
    Map<String, dynamic> newMsg = {};
    // newMsg['content'] = message['text'];
    newMsg['date'] = Timestamp.fromDate(DateTime.parse(message['id']));
    newMsg['sender'] = message['author']['id'];
    newMsg['seen'] = true;
    newMsg['type'] = message['type'];
    newMsg['name'] = message['name'];
    newMsg['uri'] = message['uri'];
    newMsg['size'] = message['size'];
    return newMsg;
  }

  /**
    I/flutter ( 7835): image message json = {
      author: {id: dspuAgOXFcRcXIUwiDYbLBX3jEx2}, 
      createdAt: 1672403324368, id: 2022-12-30 14:28:44.368769, 
      type: image, 
      name: scaled_image_picker2774617387038099389.jpg, 
      size: 27, 
      uri: /data/user/0/com.example.kargo/cache/scaled_image_picker2774617387038099389.jpg
    }
   */
}
