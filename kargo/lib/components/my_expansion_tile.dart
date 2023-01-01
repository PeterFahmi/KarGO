import 'package:flutter/material.dart';

class myExpansionTile extends StatelessWidget {
  IconData myIcon;
  String myTitle;
  List<Widget> children;
  double leftInset;

  myExpansionTile(
      {required this.myIcon,
      required this.myTitle,
      required this.children,
      this.leftInset = 30});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(myTitle),
      leading: Icon(myIcon), //add icon
      childrenPadding: EdgeInsets.only(left: leftInset), //children padding
      children: children,
    );
  }
}

getExpansionTile(myTitle, myIcon, myChildren) {}
