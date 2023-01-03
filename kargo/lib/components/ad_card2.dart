import 'package:flutter/material.dart';
import 'package:kargo/components/CarouselWithDots.dart';
import 'package:kargo/models/ad.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '';
import 'package:kargo/screens/ad_screen2.dart';
import 'package:kargo/screens/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:carousel_slider/carousel_slider.dart';

class Ad_Card2 extends StatefulWidget {
  var Ad;

  Ad_Card2({required this.Ad});

  @override
  State<Ad_Card2> createState() => _Ad_Card2State();
}

class _Ad_Card2State extends State<Ad_Card2> {
  void onPressedFav() async {
    var userId = FirebaseAuth.instance.currentUser!.uid;
    List favAds = List.empty(growable: true);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get()
        .then((res) async {
      final data = res.data() as Map<String, dynamic>;
      favAds = data['favAds'];
    });
    favAds.add(widget.Ad.adId);
    var ads = FirebaseFirestore.instance.collection('users');
    ads
        .doc(userId)
        .update({'favAds': favAds}) // <-- Updated data
        .then((_) => print(favAds))
        .catchError((error) => print('Failed: $error'));
    setState(() {
      widget.Ad.fav = 1;
    });
  }

  void onPressedUnFav() async {
    var userId = FirebaseAuth.instance.currentUser!.uid;
    List favAds = List.empty(growable: true);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get()
        .then((res) async {
      final data = res.data() as Map<String, dynamic>;
      favAds = data['favAds'];
    });
    favAds.remove(widget.Ad.adId);
    var ads = FirebaseFirestore.instance.collection('users');
    ads
        .doc(userId)
        .update({'favAds': favAds}) // <-- Updated data
        .then((_) => print(favAds))
        .catchError((error) => print('Failed: $error'));
    setState(() {
      widget.Ad.fav = 0;
    });
  }

  void adDetails(BuildContext context) {
    Navigator.pushNamed(context, AdScreen.routeName, arguments: widget.Ad).then((value) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    //  var bidp = int.parse(widget.Ad.highestBid);
    return InkWell(
      onTap: () => adDetails(context),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        color: Colors.white60,
        margin: EdgeInsets.all(10),
        child: Column(
          children: [
            // child 1 of column is image + title
            Stack(
              children: [
// child 1 of stack is the recipe image
                CarouselWithDotsPage(imgList: widget.Ad.imagePaths),
// child 2 of stack is the recipe title

                Positioned(
                    right: 10,
                    bottom: 0,
                    child: SizedBox.fromSize(
                      size: Size(50, 50), // button width and height
                      child: ClipOval(
                        child: Material(
                          elevation: 60,
                          color:
                              Color.fromRGBO(239, 235, 235, 1), // button color
                          child: InkWell(
                            splashColor: Colors.green, // splash color
                            onTap: widget.Ad.fav == 0
                                ? onPressedFav
                                : onPressedUnFav, // button pressed
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                widget.Ad.fav == 0
                                    ? IconButton(
                                        onPressed: onPressedFav,
                                        icon: Icon(
                                          Icons.favorite_border,
                                          size: 30,
                                          color: Colors.black,
                                        ))
                                    : IconButton(
                                        onPressed: onPressedUnFav,
                                        icon: Icon(
                                          Icons.favorite,
                                          size: 30,
                                          color: Colors.black,
                                        ))
                              ],
                            ),
                          ),
                        ),
                      ),
                    ))
              ],
            ),
            // child 2 of column is the white row
            Container(
              margin: EdgeInsets.all(10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                                widget.Ad.daysRemaining.toString() +
                                    ' days remaining',
                                style: TextStyle(
                                  color: Color.fromRGBO(150, 150, 150, 1),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.0,
                                )),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                widget.Ad.manufacturer.toUpperCase() +
                                    '  ' +
                                    widget.Ad.model.toUpperCase() +
                                    '  ' +
                                    widget.Ad.year.toString() ,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                )),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(widget.Ad.auto == 0 ? 'AUTO' : 'MANUAL',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                            )),
                        Container(
                            height: 15,
                            // margin: EdgeInsets.all(10),
                            child: VerticalDivider(
                                thickness: 2,
                                color: Color.fromRGBO(150, 150, 150, 1))),
                        Text(widget.Ad.km.toString() + ' km',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                            )),
                        Container(
                            height: 15,
                            child: VerticalDivider(
                                thickness: 2,
                                color: Color.fromRGBO(150, 150, 150, 1))),
                        Text(widget.Ad.cc.toString() + ' CC',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),
                  ]),
            ),

            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Text('EGP  ' + widget.Ad.askPrice.toString(),
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0,
                      )),
                ]),
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  widget.Ad.highestBid == 0
                      ? (Text('No Bids Yet',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 15.0,
                          )))
                      : (Text('EGP ' + widget.Ad.highestBid.toString(),
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 15.0,
                          ))),
                ]),
              ]),
            ]),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Ask Price',
                        style: TextStyle(
                          color: Color.fromRGBO(150, 150, 150, 1),
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Highest Bid',
                          style: TextStyle(
                            color: Color.fromRGBO(150, 150, 150, 1),
                            fontSize: 13.0,
                            fontWeight: FontWeight.bold,
                          )),
                    ]),
              ],
            ),
            SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}
