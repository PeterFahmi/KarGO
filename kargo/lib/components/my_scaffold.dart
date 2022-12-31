import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kargo/models/user.dart' as UserModel;

class MyScaffold extends StatelessWidget {
  Widget body;
  Widget? bottomNavigationBar;
  UserModel.User currentUser;
  Function updateUserFunction;

  MyScaffold(
      {required this.body,
      this.bottomNavigationBar,
      required this.currentUser,
      required this.updateUserFunction});

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
              leading: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed('/profile_page', arguments: {
                    'user': currentUser,
                    'callBack': updateUserFunction
                  });
                },
                child: showUserImage(),
              ),
              title: Image(
                image: AssetImage('assets/images/logo.png'),
                width: 150,
                height: 100,
              ),
              actions: [
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
                )
              ],
            ),
          )),
      body: body,
      bottomNavigationBar: bottomNavigationBar,
    );
  }

  showUserImage() {
    var size = 30.0;
    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xff7c94b6),
          image: DecorationImage(
            image: currentUser.imagePath == null
                ? AssetImage('assets/images/default.png') as ImageProvider
                : NetworkImage(currentUser.imagePath!),
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
