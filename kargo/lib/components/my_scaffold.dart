import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kargo/models/user.dart';

class MyScaffold extends StatelessWidget {
  String userImageURL =
      'https://dynaimage.cdn.cnn.com/cnn/c_fill,g_auto,w_1200,h_675,ar_16:9/https%3A%2F%2Fcdn.cnn.com%2Fcnnnext%2Fdam%2Fassets%2F221208164147-argentina-lionel-messi.jpg';
  Widget body;
  Widget? bottomNavigationBar;

  MyScaffold({required this.body, this.bottomNavigationBar});

  @override
  Widget build(BuildContext context) {
    User curUser = User(
        imagePath: userImageURL, name: "Omar Gamal", email: "Omar@gmail.com");

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
                  Navigator.of(context)
                      .pushNamed('/profile_page', arguments: {'user': curUser});
                },
                child: showUserImage(),
              ),
              title: Image(
                image: AssetImage('assets/images/logo.png'),
                width: 150,
                height: 100,
              ),
              actions: [
                GestureDetector(
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
