import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kargo/components/chat_card.dart';
import 'package:kargo/components/my_scaffold.dart';
import 'package:kargo/components/search_bar.dart';

import '../models/chat_users_model.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  bool isSearchActivated = false;
  List<ChatUser> chatUsers = [
    ChatUser(name: "Menna Shalaby", messageText: "Awesome Setup", imageUrl: "https://english.ahram.org.eg/Media/News/2022/12/22/41_2022-638073298442678794-267.jpg", time: "Now"),
    ChatUser(name: "Mo Salah", messageText: "That's Great", imageUrl: "https://img.a.transfermarkt.technology/portrait/big/148455-1546611604.jpg?lm=1", time: "Yesterday"),
    ChatUser(name: "Shikabala", messageText: "Hey where are you?", imageUrl: "https://img.a.transfermarkt.technology/portrait/big/28463-1497271438.jpg?lm=1", time: "31 Mar"),
    ChatUser(name: "Emiliano Martinez", messageText: "Busy! Call me in 20 mins", imageUrl: "images/userImage4.jpeg", time: "28 Mar"),
    // ChatUser(text: "Debra Hawkins", secondaryText: "Thankyou, It's awesome", image: "images/userImage5.jpeg", time: "23 Mar"),
    // ChatUser(text: "Jacob Pena", secondaryText: "will update you in evening", image: "images/userImage6.jpeg", time: "17 Mar"),
    // ChatUser(text: "Andrey Jones", secondaryText: "Can you please share the file?", image: "images/userImage7.jpeg", time: "24 Feb"),
    // ChatUser(text: "John Wick", secondaryText: "How are you?", image: "images/userImage8.jpeg", time: "18 Feb"),
  ];

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
            title: const Text("Chats", style: TextStyle(fontSize: 28, color: Colors.black, fontWeight: FontWeight.bold),),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.black,),
                onPressed: (){
                  setState(() {
                    isSearchActivated = !isSearchActivated;
                  });
                }
              )
            ],
          ),
        )
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if(isSearchActivated) const SearchBar(),
            ListView.builder(
              shrinkWrap: true,
              itemCount: chatUsers.length,
              itemBuilder: (context, index) => ChatCard(user: chatUsers[index], isMessageRead: (index == 0 || index == 3)?true:false),
            )
          ],
        )
      )
    );
  }
}