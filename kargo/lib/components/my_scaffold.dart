import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class MyScaffold extends StatelessWidget {
  String? userImageURL;
  Widget body;
  Widget? bottomNavigationBar;

  MyScaffold({required this.body, this.userImageURL, this.bottomNavigationBar});

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
              leading: showUserImage(),
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
