import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kargo/models/ad.dart';
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
      //  print(ad.);
    }
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            backgroundColor: Color.fromRGBO(0, 0, 0, 0.2),
            floating: true,
            title: Text("Have a new car to offer"),
            actions: [
              Padding(
                padding: EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/create_ad', arguments: {
                      'ad': Object(),
                      'isEditable': false
                    }).then((_) => {Navigator.popAndPushNamed(context, '/')});
                  },
                  child: Text('Add'),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.green),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                  ),
                ),
              ),
            ],
          )
        ];
      },
      floatHeaderSlivers: true,
      body: Container(
        child: Column(
          children: [
            if (isLoading)
              LinearProgressIndicator(
                minHeight: 5,
                value: ads.length / (adIds.length + 0.1),
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
      ),
    );
  }

  void loadAds() async {
    CollectionReference adsCollection =
        FirebaseFirestore.instance.collection('ads');
    for (var adId in adIds) {
      var askPrice;
      var title;
      var uId = FirebaseAuth.instance.currentUser!.uid;
      var desc;
      var endDate;
      var startDate;
      var color;
      var fav;
      var km;
      List<String> photos = [];
      var year;
      var manufacturer;
      var model;
      var carId;
      var cc;
      var auto;
      var highestBid;
      var typeId;
      var highestBidderId;
      await adsCollection.doc(adId).get().then((res) async {
        final data = res.data() as Map<String, dynamic>;
        askPrice = data['ask_price'];
        title = data['title'];
        desc = data['desc'];
        carId = data['car_id'];
        endDate = data['end_date'];
        startDate = data['start_date'];
        auto = data['auto'];
        highestBid = data['highest_bid'];
        highestBidderId = data['highest_bidder_id'];
        await FirebaseFirestore.instance
            .collection('cars')
            .doc(carId)
            .get()
            .then((res) async {
          final data = res.data() as Map<String, dynamic>;
          color = data['color'];
          km = data['km'];
          cc = data['cc'];
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
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uId)
              .get()
              .then((res) {
            final data = res.data() as Map<String, dynamic>;
            List favAds = data['favAds'];
            favAds.contains(adId) ? fav = 1 : fav = 0;
          });
        });
      });
      setState(() {
        var bidEndDate = (endDate as Timestamp).toDate();
        int daysLeft = bidEndDate.difference(DateTime.now()).inDays;
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
            daysRemaining: daysLeft);
        ads.add(Ad_Card2(Ad: adv));
        if (adIds.length == ads.length) isLoading = false;
      });
    }
  }
}
     //   var bidEndDate = (endDate as Timestamp).toDate();
      //  int daysLeft = bidEndDate.difference(DateTime.now()).inDays;

     //     daysRemaining: daysLeft,
      