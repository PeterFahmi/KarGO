import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kargo/components/ad_card2.dart';
import 'package:kargo/components/my_bottom_navigator.dart';
import 'package:kargo/components/my_scaffold.dart';
import 'package:kargo/components/my_shimmering_card.dart';
import 'package:kargo/components/no_Internet.dart';
import 'package:kargo/screens/empty_screen.dart';
import 'package:kargo/screens/loading_screen.dart';
import '../components/multiChip.dart';
import '../models/ad.dart';
import '../models/user.dart' as UserModel;
import 'FilterScreen.dart';

import 'my_ads_screen.dart';

class MyBidsScreen extends StatefulWidget {
  const MyBidsScreen({super.key});

  @override
  State<MyBidsScreen> createState() => _MyBidsScreenState();
}

class _MyBidsScreenState extends State<MyBidsScreen> {
  @override
  void initState() {
    super.initState();

    loadAds();
  }

  var _selectedTabIndex = 0;
  List<String> imgUrls = [
    'https://www.hdcarwallpapers.com/download/abt_sportsline_audi_tt-2880x1800.jpg',
    'https://th.bing.com/th/id/OIP.zpu1nHs3RCyeRXikR-nFGgHaFj?pid=ImgDet&w=1600&h=1200&rs=1'
  ];

  List<Ad> myBids = [];

  var currentUser = getCurrentUser();

  bool isLoadingb = true;
  bool internetConnection = true;
  void checkConnectitivy() async {
    var result = await Connectivity().checkConnectivity();

    if (result.name == "none") {
      setState(() {
        internetConnection = false;
      });
    } else {
      setState(() {
        internetConnection = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    checkConnectitivy();
    return internetConnection
        ? (isLoadingb
            ? ShimmerCard()
            : Column(children: [
                Expanded(
                    child: myBids.length == 0
                        ? EmptyScreen()
                        : ListView.builder(
                            itemCount: myBids.length,
                            itemBuilder: (context, index) {
                              // Get the map object at the current index
                              Ad item = myBids[index];

                              // Turn the map object into a card widget
                              return Ad_Card2(
                                Ad: item,
                              );
                            },
                          ))
              ]))
        : (noInternet());
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
        imagePath: snapShotData['photoURL'],
        myAds: snapShotData['myAds'],
        myBids: snapShotData['myBids']);
    return curUserModel;
  }

  void loadAds() async {
    CollectionReference adsCollection =
        FirebaseFirestore.instance.collection('ads');

    myBids = [];

    List favAds = [];
    List mbAds = [];
    print("loading ");

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((res) async {
      final data = res.data() as Map<String, dynamic>;
      favAds = data['favAds'];
      var b = data['myBids'];
      print(b);
      mbAds = [for (var ad in b) ad['ad_id']];
      print(mbAds);
      if (mbAds.isEmpty) {
        setState(() {
          isLoadingb = false;
        });
      }

      for (var adId in mbAds) {
        int askPrice = 0;
        var title = "";
        var uId = "";
        var desc = "";
        var endDate = Timestamp.fromDate(DateTime.now());
        var startDate = Timestamp.fromDate(DateTime.now());
        var color = "";
        var fav;
        var km = 0;
        List<String> photos = [];
        var year = 0;
        var manufacturer = "";
        var model = "";
        var carId = "";
        var cc = 0;
        var auto = 0;
        var highestBid = 0;
        var typeId = "";
        var highestBidderId = "";
        await adsCollection.doc(adId).get().then((res) async {
          final data = res.data() as Map<String, dynamic>;
          askPrice = data['ask_price'];
          title = data['title'];
          desc = data['desc'];
          carId = data['car_id'];
          uId = data['owner_id'];
          favAds.contains(adId) ? fav = 1 : fav = 0;
          endDate = data['end_date'] == null ? endDate : data['end_date'];
          ;
          startDate =
              data['start_date'] == null ? startDate : data['start_date'];
          auto = data['auto'] == null ? 0 : data['auto'];

          highestBid = data['highest_bid'] == null ? 0 : data['highest_bid'];
          highestBidderId = data['highest_bidder_id'] == null
              ? ""
              : data['highest_bidder_id'];
          await FirebaseFirestore.instance
              .collection('cars')
              .doc(carId)
              .get()
              .then((res) async {
            final data = res.data() as Map<String, dynamic>;
            color = data['color'];
            km = data['km'];
            cc = data['cc'] == null ? 0 : data['cc'];
            photos = (data['photos'] as List<dynamic>)
                .map((e) => e as String)
                .toList();
            typeId = data['type_id'];
            year = data['year'];
            await FirebaseFirestore.instance
                .collection('types')
                .doc(typeId)
                .get()
                .then((res) {
              final data = res.data() as Map<String, dynamic>;
              manufacturer = data['manufacturer'];
              model = data['model'];
            });
          });

          setState(() {
            Ad adv = Ad(
                adId: adId,
                model: model,
                year: year,
                manufacturer: manufacturer,
                km: km,
                fav: fav,
                imagePaths: photos,
                highestBid: highestBid,
                askPrice: askPrice,
                highestBidderId: highestBidderId,
                ownerId: uId,
                colour: color,
                title: title,
                desc: desc,
                typeId: typeId,
                startDate: startDate,
                endDate: endDate,
                carId: carId,
                auto: auto,
                cc: cc,
                daysRemaining:
                    DateTime.now().difference(endDate.toDate()).inDays * -1);
            bool p = false;
            for (var ad in myBids) {
              if (adv.adId == ad.adId) p = true;
            }
            if (!p) {
              myBids.add(adv);
            }
            print(myBids);
            print("bids IDS:$mbAds");

            print("aa");
            if (myBids.length == mbAds.length) isLoadingb = false;
            ;
          });
        });
      }

//ss
    });
  }
}

Future<DocumentSnapshot<Map<String, dynamic>>> getCurrentUser() async {
  final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
  return FirebaseFirestore.instance
      .collection('users')
      .doc(currentUserUid)
      .get();
}
