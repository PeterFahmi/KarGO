import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kargo/components/chat_card.dart';
import 'package:kargo/components/my_scaffold.dart';
import 'package:kargo/components/my_shimmering_card.dart';
import 'package:kargo/components/no_chats_component.dart';
import 'package:kargo/components/search_bar.dart';
import 'package:kargo/services/database_services.dart';

import '../models/chat_users_model.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  bool isSearchActivated = false;
  // List<ChatUser> chatUsers = [
  //   ChatUser(name: "Menna Shalaby", messageText: "Awesome Setup", imageUrl: "https://english.ahram.org.eg/Media/News/2022/12/22/41_2022-638073298442678794-267.jpg", time: "Now"),
  //   ChatUser(name: "Mo Salah", messageText: "That's Great", imageUrl: "https://img.a.transfermarkt.technology/portrait/big/148455-1546611604.jpg?lm=1", time: "Yesterday"),
  //   ChatUser(name: "Shikabala", messageText: "Hey where are you?", imageUrl: "https://img.a.transfermarkt.technology/portrait/big/28463-1497271438.jpg?lm=1", time: "31 Mar"),
  // ];

  List<ChatUser> chatUsers = [];
  Stream? chats;
  var db = DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid);

  getCurrentUserData() async {
    await db.getUserChats().then((snapshot) {
      setState(() {
        chats = snapshot;
      });
    });
  }

  getChatData(ref) async {
    ChatUser otherUser = ChatUser(
        id: "",
        imageUrl: "",
        messageText: "",
        name: FirebaseAuth.instance.currentUser!.email,
        time: '');
    await ref.get().then((value) async {
      var data = value.data() as Map;
      // print("chat value=" + data.toString());
      var users = data['users'];
      for (var i = 0; i < users.length; i++) {
        await users[i].get().then((userVal) {
          var userData = userVal.data() as Map;
          // print("user data=" + userData.toString());
          // print("user id=" + userVal.id.toString());
          if (userVal.id != FirebaseAuth.instance.currentUser!.uid) {
            otherUser = ChatUser(
                id: userVal.id.toString(),
                name: userData['name'],
                messageText: data['recentMessage'],
                imageUrl: userData['photoURL'],
                time: data['recentMessageTime'].toString());
          }
        });
      }
    });
    return otherUser;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUserData();
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
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                title: const Text(
                  "Chats",
                  style: TextStyle(
                      fontSize: 28,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                actions: [
                  IconButton(
                      icon: const Icon(
                        Icons.search,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          isSearchActivated = !isSearchActivated;
                        });
                      })
                ],
              ),
            )),
        body: Column(
          children: [
            isSearchActivated ? const SearchBar() : Container(),
            const SizedBox(
              height: 15,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () {
                  setState(() {
                    
                  });
                  return Future<void>(() {},);
                },
                child: buildChatList(),
              ) 
            )
          ],
        ));
  }

  buildChatList() {
    return StreamBuilder(
      stream: chats,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const ShimmerCard();
        }
        // print("snapshot data=" + snapshot.data['chats'].toString());
        // print("snapshot data=" + snapshot.data['chats'].toString());
        if (snapshot.data['chats'] == null ||
            snapshot.data['chats'].length == 0) {
          return const NoChatsComponent();
        }

        var chatsList = snapshot.data['chats'];
        // print("chatslist="+chatsList.toString());
        return ListView.builder(
          itemCount: chatsList.length,
          itemBuilder: (context, index) {
            return FutureBuilder(
              future: getChatData(chatsList[index]),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: FadeShimmer(
                      height: 150,
                      width: 300,
                      radius: 10,
                      millisecondsDelay: 2,
                      fadeTheme: FadeTheme.light,
                    ),
                  );
                }
                // print("snapshot.data=" + (snapshot.data as ChatUser).id);
                return ChatCard(
                    user: snapshot.data as ChatUser,
                    chatRef: chatsList[index],
                    isMessageRead: false);
              },
            );
          },

          // (context, index) {
          //   // var user;
          //   // getChatData(chatsList[index]).then((value) => user = value);
          //   var user = ChatUser(
          //       imageUrl: "",
          //       messageText: "",
          //       name: chatsList[index].toString(),
          //       time: '');
          //   // var user = chatUsers[index];
          //   return ChatCard(
          //     user: user,
          //     isMessageRead: false,
          //     chatRef: chatsList[index],
          //   );
          // },
        );
      },
    );
  }
}
