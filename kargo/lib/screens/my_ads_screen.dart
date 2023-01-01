import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/basic.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kargo/components/ad_card2.dart';

import '../components/my_shimmering_card.dart';

class MyAdsScreen extends StatefulWidget {
  const MyAdsScreen({super.key});

  @override
  State<MyAdsScreen> createState() => _MyAdsScreenState();
}

class _MyAdsScreenState extends State<MyAdsScreen> {
  List<String> adIds = [];
  List<Ad_Card2> ads = [];
  bool isLoading = true;
  @override
  void initState() {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance.collection('users').doc(uid).get().then((res) {
      final data = res.data() as Map<String, dynamic>;
      setState(() {
        adIds =
            (data['myAds'] as List<dynamic>).map((e) => e as String).toList();
      });
      loadAds();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    for (var ad in ads) {
      print(ad.imgUrls);
    }
    return Container(
      child: Column(
        children: [
          if (isLoading)
            LinearProgressIndicator(
              minHeight: 5,
              value: ads.length / (adIds.length + 1),
              backgroundColor: Colors.white,
              color: Colors.black,
            ),
          Expanded(
            child: ListView(
              reverse: false,
              children: [
                ...ads,
                if (isLoading) ShimmerCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void loadAds() async {
    CollectionReference adsCollection =
        FirebaseFirestore.instance.collection('ads');
    for (var adId in adIds) {
      var askPrice;
      var title;
      var desc;
      var endDate;
      var startDate;
      var color;
      var km;
      List<String> photos = [];
      var year;
      var manufacturer;
      var model;
      await adsCollection.doc(adId).get().then((res) async {
        final data = res.data() as Map<String, dynamic>;
        askPrice = data['ask_price'];
        title = data['title'];
        desc = data['desc'];
        var carId = data['car_id'];
        endDate = data['end_date'];
        startDate = data['start_date'];
        await FirebaseFirestore.instance
            .collection('cars')
            .doc(carId)
            .get()
            .then((res) async {
          final data = res.data() as Map<String, dynamic>;
          color = data['color'];
          km = data['km'];
          photos = (data['photos'] as List<dynamic>)
              .map((e) => e as String)
              .toList();
          var typeId = data['type_id'];
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
      });
      setState(() {
        ads.add(Ad_Card2(
            model: model,
            year: year,
            manufacturer: manufacturer,
            km: km,
            fav: 0,
            imgUrls: photos,
            bid: -1,
            ask: askPrice));
        if (adIds.length == ads.length) isLoading = false;
      });
    }
  }
}
