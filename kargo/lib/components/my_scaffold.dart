import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kargo/models/user.dart' as UserModel;

class MyScaffold extends StatelessWidget {
  String userImageURL =
      'https://dynaimage.cdn.cnn.com/cnn/c_fill,g_auto,w_1200,h_675,ar_16:9/https%3A%2F%2Fcdn.cnn.com%2Fcnnnext%2Fdam%2Fassets%2F221208164147-argentina-lionel-messi.jpg';
  Widget body;
  Widget? bottomNavigationBar;
  bool hasLeading;

  MyScaffold(
      {required this.body, this.bottomNavigationBar, this.hasLeading = true});

  @override
  Widget build(BuildContext context) {
    UserModel.User curUser = UserModel.User(
        imagePath: userImageURL, name: "Omar Gamal", email: "Omar@gmail.com");

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
                            arguments: {'user': curUser});
                      },
                      child: showUserImage(),
                    )
                  : null,
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
    var size = 30.0;
    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xff7c94b6),
          image: DecorationImage(
            image: userImageURL == null
                ? AssetImage('assets/images/default.png') as ImageProvider
                : NetworkImage(userImageURL!),
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
