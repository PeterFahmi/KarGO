import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kargo/models/chat_users_model.dart';

class ChatCard extends StatefulWidget {
  ChatUser user;
  DocumentReference chatRef;
  bool isMessageRead;

  ChatCard({required this.user,required this.chatRef, required this.isMessageRead});
  
  @override
  State<ChatCard> createState() => ChatCardState();
}

class ChatCardState extends State<ChatCard> {
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: (){
        Navigator.of(context).pushNamed('/ChatDetail', arguments: {'username': widget.user.name, 'chatRef': widget.chatRef});
      },
      leading: CircleAvatar(
        backgroundImage: widget.user.imageUrl!="" ? 
          NetworkImage(widget.user.imageUrl ?? "") 
          : const AssetImage("assets/images/default.png") as ImageProvider,
        maxRadius: 30,
      ),
      title: Text(widget.user.name ?? "", style: const TextStyle(fontSize: 16),),
      subtitle: Text(widget.user.messageText ?? "", style: TextStyle(fontSize: 13,color: Colors.grey.shade600, fontWeight: widget.isMessageRead?FontWeight.bold:FontWeight.normal),),
      trailing: Text(widget.user.time ?? "", style: TextStyle(fontSize: 12, fontWeight: widget.isMessageRead?FontWeight.bold:FontWeight.normal),),
      // child: Container(
      //   padding: const EdgeInsets.only(left: 16,right: 16,top: 10,bottom: 10),
      //   child: Row(
      //     children: [
      //       Expanded(
      //         child: Row(
      //           children: [
      //             CircleAvatar(
      //               backgroundImage: NetworkImage(widget.user.imageUrl),
      //               maxRadius: 30,
      //             ),
      //             const SizedBox(width: 16,),
      //             Expanded(
      //               child: Container(
      //                 color: Colors.transparent,
      //                 child: Column(
      //                   crossAxisAlignment: CrossAxisAlignment.start,
      //                   children: [
      //                     Text(widget.user.name, style: const TextStyle(fontSize: 16),),
      //                     const SizedBox(height: 16,),
      //                     Text(widget.user.messageText, style: TextStyle(fontSize: 13,color: Colors.grey.shade600, fontWeight: widget.isMessageRead?FontWeight.bold:FontWeight.normal),)
      //                   ]
      //                 ),
      //               ),
      //             )
      //           ],
      //         )
      //       ),
      //       Text(widget.user.time, style: TextStyle(fontSize: 12, fontWeight: widget.isMessageRead?FontWeight.bold:FontWeight.normal),)
      //     ],
      //   ),
      // ),
    );
  }
}