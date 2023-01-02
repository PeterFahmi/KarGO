import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kargo/components/ad_card2.dart';
import 'package:kargo/components/my_bottom_navigator.dart';
import 'package:kargo/components/my_scaffold.dart';
import 'package:kargo/components/my_shimmering_card.dart';
import 'package:kargo/screens/loading_screen.dart';
import '../models/user.dart' as UserModel;
import 'my_ads_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    final fbm = FirebaseMessaging.instance;
    fbm.getToken().then((value) => print(value));
    fbm.requestPermission();
  }

  var _selectedTabIndex = 0;
  List<String> imgUrls = [
    'https://www.hdcarwallpapers.com/download/abt_sportsline_audi_tt-2880x1800.jpg',
    'https://th.bing.com/th/id/OIP.zpu1nHs3RCyeRXikR-nFGgHaFj?pid=ImgDet&w=1600&h=1200&rs=1'
  ];

  var currentUser = getCurrentUser();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: currentUser,
      builder: (BuildContext context,
          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.hasData) {
          var currentUserModel = createCurrentUserModel(snapshot);
          return MyScaffold(
            body: showTab(_selectedTabIndex),
            bottomNavigationBar: MyBottomNavagationBar(
              notifyParent: onNavigationBarChanged,
            ),
            currentUser: currentUserModel,
            updateUserFunction: updateUserProfile,
          );
        } else if (snapshot.hasError) {
          throw Exception("");
        }
        return LoadingScreen();
      },
    );
  }

  void updateUserProfile(UserModel.User updatedUser) async {
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserUid)
        .update({'name': updatedUser.name, 'photoURL': updatedUser.imagePath});

    setState(() {
      currentUser = getCurrentUser();
    });
  }

  getSnapShotData(mySnapShot) {
    return mySnapShot.data!.data();
  }

  createCurrentUserModel(mySnapShot) {
    var snapShotData = getSnapShotData(mySnapShot);
    var curUserModel = UserModel.User(
        email: snapShotData['email'],
        name: snapShotData['name'],
        imagePath: snapShotData['photoURL']);
    return curUserModel;
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
        return MyAdsScreen();
      // return Column(children: [
      //   Ad_Card2(
      //     imgUrls: imgUrls,
      //     manufacturer: "Audi",
      //     model: "RS7",
      //     year: "2021",
      //     km: "9000",
      //     fav: 1,
      //     bid: "1,290,000",
      //     ask: "1,200,000",
      //   ),
      //   Ad_Card2(
      //       imgUrls: imgUrls,
      //       manufacturer: "Audi",
      //       model: "RS7",
      //       year: "2021",
      //       km: "9000",
      //       fav: 0,
      //       bid: "1,290,000",
      //       ask: "1,200,000")
      // ]);
      default:
        return Text("");
    }
  }
}

Future<DocumentSnapshot<Map<String, dynamic>>> getCurrentUser() async {
  final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
  return FirebaseFirestore.instance
      .collection('users')
      .doc(currentUserUid)
      .get();
}
