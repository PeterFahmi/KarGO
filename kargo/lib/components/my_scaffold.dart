import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class MyScaffold extends StatelessWidget {
  String? userImageURL;

  MyScaffold({this.userImageURL});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(100.0),
          child: AppBar(
            leading: showUserImage(),
          )),
    );
  }

  showUserImage() {
    var size = 50.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xff7c94b6),
        image: DecorationImage(
          image: userImageURL == null
              ? AssetImage('images/DefaultUserImage.png') as ImageProvider
              : NetworkImage(userImageURL!),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.all(Radius.circular(size / 2)),
        border: Border.all(
          color: Colors.black,
          width: 4.0,
        ),
      ),
    );
  }
}
