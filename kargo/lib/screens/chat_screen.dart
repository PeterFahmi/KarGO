import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:kargo/components/my_shimmering_card.dart';
import 'package:kargo/components/no_chats_component.dart';

import '../services/database_services.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {  
  final List<types.Message> _messages = [];
  final _user = types.User(id: FirebaseAuth.instance.currentUser!.uid);
  late final String username;
  late final DocumentReference chatReference;
  Stream? messageStream;
  var db = DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid);

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    username = args['username'] as String;
    chatReference = args['chatRef'] as DocumentReference;
    getChatStream();
  }
  
  getChatStream() async {
    setState(() {
      messageStream=chatReference.collection("messages").orderBy("date").snapshots();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: Container(
          padding: const EdgeInsets.only(top: 10),
          child: AppBar(
            backgroundColor: Colors.white,
            titleSpacing: 0,
            leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: (){Navigator.of(context).pop();},),
            title: Text(username, style: const TextStyle(fontSize: 28, color: Colors.black, fontWeight: FontWeight.bold),),
          ),
        )
      ),
      body: chatMessages()
    );
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleSendPressed(types.PartialText message) {
    String trimmedText = message.text.trim();
    if(trimmedText == "") {
      return;
    }

    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: DateTime.now().toString(),
      text: trimmedText,
    );

    print("text message json="+textMessage.toJson().toString());
    db.sendMessage(chatReference, textMessage.toJson());
    _addMessage(textMessage);
  }

  // readAllMessages(){
  //   // chatReference.collection("messages").get().then(((value) {
  //   //   print("value of message=" + value.docs[0].data().toString());
  //   //   print("value of message=" + value.docs.length.toString());
  //   // }));
  //   // chatReference.collection("messages").snapshots().listen(((snapshot) {
  //   //   print("value of message="+snapshot.docs[0].data().toString());
  //   // }));
  //   db.getCollectionFromDocument(chatReference).then((snapshot) {
  //     snapshot.listen((snap) {
  //       print("value of message="+snap.docs[1].data().toString());
  //      });
  //   });
  //   return Container();
  // }

  chatMessages(){    
    return StreamBuilder(
      stream: messageStream,
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting){
          return const ShimmerCard();
        }
        if(!snapshot.hasData){
          return const NoChatsComponent();
        }
        var updatedMessages = snapshot.data!.docs;
        // print("messages data="+messagesList[0].data().toString());
        addFetchedMessages(updatedMessages);
        return Chat(
          messages: _messages, 
          onSendPressed: _handleSendPressed, 
          user: _user
        );
      },
    );
  }

  void addFetchedMessages(updatedMessages) {
    _messages.clear();
    updatedMessages.forEach((msg) {
      // print("msg data="+msg.data().toString());
      var sender;
      if(msg.data()['sender']==FirebaseAuth.instance.currentUser!.uid) {
        sender=_user;
      }
      else{
        sender=types.User(id: msg.data()['sender']);
      }
      
      final textMessage = types.TextMessage(
        author: sender,
        createdAt: DateTime.parse(msg.data()['date'].toDate().toString()).millisecondsSinceEpoch,
        id: DateTime.now().toString(),
        text: msg.data()['content'],
      );
    
      _messages.insert(0,textMessage);
    });
  }
}