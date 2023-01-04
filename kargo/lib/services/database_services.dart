import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");
  final CollectionReference chatCollection =
      FirebaseFirestore.instance.collection("chats");

  Future getUserDataFromEmail(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }

  Future<Object?> getUserDataFromId(String id) async {
    DocumentReference docRef = userCollection.doc(id);
    DocumentSnapshot snapshot = await docRef.get();
    // print("userdata = " + snapshot.data().toString());
    var userdata = snapshot.data();
    return userdata;
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

  // This method takes in a user id and returns the corresponding chat document reference
  // if exists, else returns null.
  Future<DocumentReference?> checkChatExists(String otherUserId) async {
    DocumentReference? correspondingChat = null;
    DocumentReference otherUserRef = userCollection.doc(otherUserId);
    // print("other user ref=" + otherUserRef.toString());
    await userCollection.doc(uid).get()
      .then((snapshot) async {
        final data = snapshot.data() as Map;
        final chats = data['chats'] as List;
        // print("chatsList" + chats.toString());
        for (var chatRef in chats) { 
          // print("chatRef="+chatRef.toString());
          await chatRef.get()
            .then((DocumentSnapshot snapshot) {
              final chatData = snapshot.data() as Map;
              final chatUsers = chatData['users'] as List;
              // print("chatsList="+chatUsers.toString());
              if(chatUsers.contains(otherUserRef)){
                correspondingChat = chatRef;
                return;
              }
            });
        }
      });
    return correspondingChat;
  }
  
  Future<DocumentReference<Object?>?> createChat(String otherUserId) async {
    DocumentReference? exists = await checkChatExists(otherUserId);
    print("Chat already exists?" + exists.toString());
    if(exists != null){
      return exists;
    }

    DocumentReference curUserRef = userCollection.doc(uid);
    DocumentReference otherUserRef = userCollection.doc(otherUserId);
    await chatCollection.add({
      "users": [
        curUserRef, 
        otherUserRef
      ],
      "recentMessage": "",
      "recentMessageSender": "",
      "recentMessageTime": Timestamp.now()
    })
    .then((DocumentReference chatRef) {
      print("chat then value = " + chatRef.toString());
      exists = chatRef;
      userCollection.doc(uid).update({
        "chats": FieldValue.arrayUnion([chatRef as DocumentReference])
      });
      userCollection.doc(otherUserId).update({
        "chats": FieldValue.arrayUnion([chatRef])
      });
    });
    return exists;
  }
}
