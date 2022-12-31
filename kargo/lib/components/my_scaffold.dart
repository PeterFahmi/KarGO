import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kargo/models/user.dart' as UserModel;

class MyScaffold extends StatelessWidget {
  Widget body;
  Widget? bottomNavigationBar;
  bool hasLeading;
  UserModel.User? currentUser;
  Function? updateUserFunction;

  MyScaffold(
      {required this.body,
      this.bottomNavigationBar,
      this.currentUser,
      this.updateUserFunction,
      this.hasLeading = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(80.0),
          child: Container(
            padding: EdgeInsets.only(top: 10),
            child: AppBar(
              iconTheme: IconThemeData(color: Colors.black),
              backgroundColor: Colors.white,
              titleSpacing: 0,
              leading: hasLeading
                  ? GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed('/profile_page',
                            arguments: {
                              'user': currentUser,
                              'callBack': updateUserFunction
                            });
                      },
                      child: showUserImage(),
                    )
                  : null,
              title: Image(
                image: AssetImage('assets/images/logo.png'),
                width: 150,
                height: 100,
              ),
              actions: [ IconButton(
 onPressed: () {
 Navigator.of(context).pushNamed('/filter');
 },
 icon: Icon(Icons.filter_alt_rounded, color: Colors.black)),IconButton(
 onPressed: () {
 FirebaseAuth.instance.signOut();
 },
 icon: Icon(Icons.logout_outlined, color: Colors.black)),
 
             
                IconButton(
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                    },
                    icon: Icon(Icons.logout_outlined, color: Colors.black)),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed('/Chats');
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Image(
                      image: AssetImage('assets/images/chats.png'),
                      width: 30,
                    ),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/create_ad');
                    },
                    icon: Icon(Icons.add, color: Colors.black)),
              ],
            ),
          )),
      body: body,
      bottomNavigationBar: bottomNavigationBar,
    );
  }

  showUserImage() {
    if (!hasLeading) return;
    var size = 30.0;
    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xff7c94b6),
          image: DecorationImage(
            image: currentUser!.imagePath == null
                ? AssetImage('assets/images/default.png') as ImageProvider
                : NetworkImage(currentUser!.imagePath!),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.all(Radius.circular(size / 2)),
          border: Border.all(
            color: Colors.black,
            width: 4.0,
          ),
        ),
      ),
    );
  }
}
