import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kargo/components/my_scaffold.dart';
import 'package:kargo/components/search_bar.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool isSearchActivated = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0),
        child: Container(
          padding: EdgeInsets.only(top: 10),
          child: AppBar(
            backgroundColor: Colors.white,
            titleSpacing: 0,
            leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.black), onPressed: (){Navigator.of(context).pop();},),
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
        )),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if(isSearchActivated) const SearchBar(),
          ],
        )
      )
    );
  }
}