import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kargo/models/chat_users_model.dart';
import 'package:kargo/services/database_services.dart';

class ChatCard extends StatefulWidget {
  ChatUser user;
  DocumentReference chatRef;
  bool isMessageRead;

  ChatCard(
      {required this.user, required this.chatRef, required this.isMessageRead});

  @override
  State<ChatCard> createState() => ChatCardState();
}

class ChatCardState extends State<ChatCard> {
  late DatabaseService db;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    db = DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid);
    // print("our user id = " + widget.user.id);
    db.getUserDataFromId(widget.user.id).then((value) {
      // print("fetched user data = " + value.toString());
      // setState(() {

      // });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
          .getUserDataFromId(widget.user.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: FadeShimmer(
              height: 150,
              width: 300,
              radius: 10,
              millisecondsDelay: 2,
              fadeTheme: FadeTheme.light,
            ),
          );
        }
        final userData = (snapshot.data as DocumentSnapshot).data();
        print("user photo url = " + widget.user.imageUrl.toString());
        return ListTile(
          onTap: () {
            Navigator.of(context).pushNamed('/ChatDetail', arguments: {
              'username': widget.user.name,
              'chatRef': widget.chatRef
            });
          },
          leading: CircleAvatar(
            backgroundImage: widget.user.imageUrl != ""
                ? NetworkImage(widget.user.imageUrl ?? "")
                : const AssetImage("assets/images/default.png")
                    as ImageProvider,
            maxRadius: 30,
          ),
          title: Text(
            widget.user.name ?? "",
            style: const TextStyle(fontSize: 16),
          ),
          subtitle: Text(
            widget.user.messageText ?? "",
            style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight:
                    widget.isMessageRead ? FontWeight.bold : FontWeight.normal),
          ),
          // trailing: Text(widget.user.time ?? "", style: TextStyle(fontSize: 12, fontWeight: widget.isMessageRead?FontWeight.bold:FontWeight.normal),),
        );
      },
    );

    // ListTile(
    //   onTap: (){
    //     Navigator.of(context).pushNamed('/ChatDetail', arguments: {'username': widget.user.name, 'chatRef': widget.chatRef});
    //   },
    //   leading: CircleAvatar(
    //     backgroundImage: widget.user.imageUrl!="" ?
    //       NetworkImage(widget.user.imageUrl ?? "")
    //       : const AssetImage("assets/images/default.png") as ImageProvider,
    //     maxRadius: 30,
    //   ),
    //   title: Text(widget.user.name ?? "", style: const TextStyle(fontSize: 16),),
    //   subtitle: Text(widget.user.messageText ?? "", style: TextStyle(fontSize: 13,color: Colors.grey.shade600, fontWeight: widget.isMessageRead?FontWeight.bold:FontWeight.normal),),
    //   trailing: Text(widget.user.time ?? "", style: TextStyle(fontSize: 12, fontWeight: widget.isMessageRead?FontWeight.bold:FontWeight.normal),),
    // );
  }
}
