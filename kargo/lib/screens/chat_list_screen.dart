import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:kargo/components/chat_card.dart';
import 'package:kargo/components/my_scaffold.dart';
import 'package:kargo/components/my_shimmering_card.dart';
import 'package:kargo/components/no_Internet.dart';
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
  List<ChatUser> chatUsers = [];
  bool internetConnection = true;
  Stream? chats;
  var db = DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid);
  SearchBar chatSearchBar = SearchBar();
  void checkConnectitivy() async {
    var result = await Connectivity().checkConnectivity();

    if (result.name == "none") {
      setState(() {
        internetConnection = false;
      });
    } else {
      setState(() {
        internetConnection = true;
      });
    }
  }

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
    checkConnectitivy();
    // TODO: implement initState
    super.initState();
    if (internetConnection) {
      getCurrentUserData();
      chatSearchBar.searchCtrl.addListener(() {
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //checkConnectitivy();
    // print("search val=" + chatSearchBar.searchCtrl.text);
    return internetConnection
        ? (Scaffold(
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
                isSearchActivated ? chatSearchBar : Container(),
                const SizedBox(
                  height: 15,
                ),
                Expanded(
                    child: RefreshIndicator(
                  onRefresh: () {
                    setState(() {});
                    return Future<void>(
                      () {},
                    );
                  },
                  child: buildChatList(),
                ))
              ],
            )))
        : (noInternet());
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
                ChatUser chatUser = snapshot.data as ChatUser;
                if(isSearchActivated && !chatUser.name!.toUpperCase().contains(chatSearchBar.searchCtrl.text.toUpperCase())){
                  return Container();
                }
                return ChatCard(
                    user: snapshot.data as ChatUser,
                    chatRef: chatsList[index],
                    isMessageRead: false);
              },
            );
          },
        );
      },
    );
  }
}
