import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/basic.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kargo/components/ad_card2.dart';

class MyAdsScreen extends StatefulWidget {
  const MyAdsScreen({super.key});

  @override
  State<MyAdsScreen> createState() => _MyAdsScreenState();
}

class _MyAdsScreenState extends State<MyAdsScreen> {
  List<String> adIds = [];
  List<Widget> ads = [];
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
    return Column(
      children: [...adIds.map((e) => Text(e)), ...ads],
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
            fav: 1,
            imgUrls: photos,
            bid: -1,
            ask: askPrice));
      });
    }
  }
}
