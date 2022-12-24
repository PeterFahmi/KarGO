import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kargo/components/ad_card.dart';
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
  List imgUrls = [
    'https://www.hdcarwallpapers.com/download/abt_sportsline_audi_tt-2880x1800.jpg',
    'https://th.bing.com/th/id/OIP.zpu1nHs3RCyeRXikR-nFGgHaFj?pid=ImgDet&w=1600&h=1200&rs=1'
  ];
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
        return Column(children: [
          Ad_Card(
            imgUrls: imgUrls,
            manufacturer: "Audi",
            model: "RS7",
            year: "2021",
            km: "9000",
            fav: 1,
            bid: "1,290,000",
            ask: "1,200,000",
          ),
          Ad_Card(
              imgUrls: imgUrls,
              manufacturer: "Audi",
              model: "RS7",
              year: "2021",
              km: "9000",
              fav: 0,
              bid: "1,290,000",
              ask: "1,200,000")
        ]);
      default:
        return Text("");
    }
  }
}
