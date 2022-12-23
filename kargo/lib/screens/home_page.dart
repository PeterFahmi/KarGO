import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kargo/components/my_bottom_navigator.dart';
import 'package:kargo/components/my_scaffold.dart';
import 'package:kargo/components/my_shimmering_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      body: showTab(_selectedTabIndex),
      bottomNavigationBar: MyBottomNavagationBar(
        notifyParent: onNavigationBarChanged,
      ),
    );
  }

  onNavigationBarChanged(index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  Widget showTab(selectedTabIndex) {
    switch (selectedTabIndex) {
      case 0:
        return ShimmerCard();
      case 1:
        return Text("fav");
      case 2:
        return Text("bid");
      case 3:
        return Text("my cars");
      default:
        return Text("");
    }
  }
}
