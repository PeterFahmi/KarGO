import 'dart:convert';

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
import '../components/multiChip.dart';
import '../models/ad.dart';
import '../models/user.dart' as UserModel;

import 'my_ads_screen.dart';

class FaveScreen extends StatefulWidget {
  const FaveScreen({super.key});

  @override
  State<FaveScreen> createState() => _FaveScreenState();
}

class _FaveScreenState extends State<FaveScreen> {
  @override
  void initState() {
    super.initState();
    loadAds();
  }

  var currentUser = getCurrentUser();

  List<Ad> favoriteAds = [];
  List favAdsIds = [];

  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          if (isLoading)
            LinearProgressIndicator(
              minHeight: 5,
              value: favoriteAds.length / (favAdsIds.length + 0.1),
              backgroundColor: Colors.white,
              color: Colors.black,
            ),
          Expanded(
            child: ListView(
              reverse: false,
              children: [
                ...favoriteAds.map((e) => Ad_Card2(Ad: e)),
                if (isLoading) ShimmerCard(),
              ],
            ),
          ),
        ],
      ),
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

  void loadAds() async {
    CollectionReference adsCollection =
        FirebaseFirestore.instance.collection('ads');
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((res) async {
      final data = res.data() as Map<String, dynamic>;
      setState(() {
        favAdsIds = data['favAds'];
      });
      if (favAdsIds.isEmpty) {
        setState(() {
          isLoading = false;
        });
      }
      print(favAdsIds);
      for (var adId in favAdsIds) {
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
          favAdsIds.contains(adId) ? fav = 1 : fav = 0;
          endDate = data['end_date'] ?? endDate;
          startDate = data['start_date'] ?? startDate;
          auto = data['auto'] ?? 0;

          highestBid = data['highest_bid'] ?? 0;
          highestBidderId = data['highest_bidder_id'] ?? "";
          await FirebaseFirestore.instance
              .collection('cars')
              .doc(carId)
              .get()
              .then((res) async {
            final data = res.data() as Map<String, dynamic>;
            color = data['color'];
            km = data['km'];
            cc = data['cc'] ?? 0;
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
          Ad adModel = Ad(
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
          setState(() {
            favoriteAds.add(adModel);
            if (favoriteAds.length == favAdsIds.length) isLoading = false;
          });
        });
      }
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
