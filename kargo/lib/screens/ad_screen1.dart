import 'package:flutter/material.dart';
import 'package:kargo/components/CarouselWithDots.dart';
import 'package:kargo/components/CarouselBig.dart';
import 'package:kargo/screens/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kargo/models/ad.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kargo/screens/ad_screen2.dart';
import 'package:kargo/services/database_services.dart';

class AdScreen1 extends StatefulWidget {
  const AdScreen1({super.key});

  static const routeName = '/ad';

  @override
  State<AdScreen1> createState() => _AdScreen1State();
}

class _AdScreen1State extends State<AdScreen1> {
  var bidPrice = 0;
  bool initialB = true;
  DatabaseService db = DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid);
  @override
  Widget build(BuildContext context) {
    var ad = ModalRoute.of(context)!.settings.arguments as Ad;
    var userId = FirebaseAuth.instance.currentUser!.uid;
    if (initialB) {
      bidPrice = ad.highestBid == 0 ? (ad.askPrice + 1) : (ad.highestBid + 1);
      initialB = false;
    }
    void onPressedFav() async {
      List favAds = List.empty(growable: true);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get()
          .then((res) async {
        final data = res.data() as Map<String, dynamic>;
        favAds = data['favAds'];
      });
      favAds.add(ad.adId);
      var ads = FirebaseFirestore.instance.collection('users');
      ads
          .doc(userId)
          .update({'favAds': favAds}) // <-- Updated data
          .then((_) => print(favAds))
          .catchError((error) => print('Failed: $error'));
      setState(() {
        ad.fav = 1;
      });
    }

    void onPressedUnFav() async {
      List favAds = List.empty(growable: true);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get()
          .then((res) async {
        final data = res.data() as Map<String, dynamic>;
        favAds = data['favAds'];
      });
      favAds.remove(ad.adId);
      var users = FirebaseFirestore.instance.collection('users');
      users
          .doc(userId)
          .update({'favAds': favAds}) // <-- Updated data
          .then((_) => print(favAds))
          .catchError((error) => print('Failed: $error'));
      setState(() {
        ad.fav = 0;
      });
    }

    void showLoading() {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const SimpleDialog(
            elevation: 0.0,
            backgroundColor:
                Colors.transparent, // can change this to your prefered color
            children: <Widget>[
              Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
            ],
          );
        },
      );
    }

    void submit() async {
      showLoading();
      List bidAds = List.empty(growable: true);
      var ads = FirebaseFirestore.instance.collection('ads');
      ads
          .doc(ad.adId)
          .update({
            'highest_bid': bidPrice,
            'highest_bidder_id': userId
          }) // <-- Updated data
          .then((_) => print(bidPrice))
          .catchError((error) => print('Failed: $error'));

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get()
          .then((res) async {
        final data = res.data() as Map<String, dynamic>;
        bidAds = data['myBids'];
      });
      if (!bidAds.contains(ad.adId)) {
        bidAds.add(ad.adId);
        var users = FirebaseFirestore.instance.collection('users');
        users
            .doc(userId)
            .update({'myBids': bidAds}) // <-- Updated data
            .then((_) => print(bidAds))
            .catchError((error) => print('Failed: $error'));
      }
      Navigator.pop(context);
      Navigator.pop(context);
    }

    void onPressedEdit() {}

    showBidSheet() {
      showModalBottomSheet<dynamic>(
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          context: context,
          builder: (BuildContext bc) {
            return StatefulBuilder(builder: (BuildContext context,
                void Function(void Function()) setState) {
              return Wrap(children: <Widget>[
                Container(
                  decoration: new BoxDecoration(
                      color: Colors.white,
                      borderRadius: new BorderRadius.only(
                          topLeft: const Radius.circular(25.0),
                          topRight: const Radius.circular(25.0))),
                  width: double.infinity,
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 60,
                        decoration: new BoxDecoration(
                            color: Colors.black,
                            borderRadius: new BorderRadius.only(
                                topLeft: const Radius.circular(25.0),
                                topRight: const Radius.circular(25.0))),
                        child: Center(
                          child: Text('Place Bid',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  fontSize: 20)),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Slider(
                              activeColor: Colors.green,
                              inactiveColor: Colors.green[100],
                              label: "Select Bidding Price",
                              value: bidPrice.toDouble(),
                              min: ad.highestBid == 0
                                  ? (ad.askPrice.floorToDouble() + 1)
                                  : (ad.highestBid.floorToDouble() + 1),
                              max: ad.highestBid == 0
                                  ? ((ad.askPrice + 100000).floorToDouble())
                                  : ((ad.highestBid + 100000).floorToDouble()),
                              onChanged: (value) {
                                setState(() {
                                  print(bidPrice);
                                  bidPrice = value.toInt();
                                });
                              },
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Text("Your Bidding Price : ",
                                    style: const TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                    )),
                                Text(
                                  'EGP ' + bidPrice.toString(),
                                  style: const TextStyle(
                                    fontSize: 15.0,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: submit,
                          child: Text('Bid'),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.black),
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(height: 20)
                    ],
                  ),
                ),
              ]);
            });
          });
    }

    void handleOnPressChat() async {
      Map ownerData = (await db.getUserDataFromId(ad.ownerId)) as Map;
      String ownerName = ownerData['name'];
      DocumentReference? chatRef = await db.createChat(ad.ownerId);
      Navigator.of(context).pushNamed('/ChatDetail', arguments: {
                'username': ownerName,
                'chatRef': chatRef
              });
    }

    return new Scaffold(
        body: Material(
            child: ListView(children: <Widget>[
          Container(
              color: Colors.white,
              child: Column(children: [
                Stack(
                  children: [
                    CarouselBig(imgList: ad.imagePaths),
                    Positioned(
                      right: 20,
                      bottom: 0,
                      child: SizedBox.fromSize(
                        size: Size(50, 50), // button width and height
                        child: ClipOval(
                          child: Material(
                            elevation: 60,
                            color: Color.fromRGBO(
                                239, 235, 235, 1), // button color
                            child: InkWell(
                              splashColor: Colors.green, // splash color
                              onTap: ad.fav == 0
                                  ? onPressedFav
                                  : onPressedUnFav, // button pressed
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  ad.fav == 0
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
                      ),
                    ),
                    if(ad.ownerId == userId)
                         (Positioned(
                            right: 80,
                            bottom: 0,
                            child: SizedBox.fromSize(
                              size: Size(50, 50), // button width and height
                              child: ClipOval(
                                child: Material(
                                  elevation: 60,
                                  color: Color.fromRGBO(
                                      239, 235, 235, 1), // button color
                                  child: InkWell(
                                    splashColor: Colors.green, // splash color
                                    onTap: onPressedEdit, // button pressed
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        IconButton(
                                            onPressed: onPressedFav,
                                            icon: Icon(
                                              Icons.edit,
                                              size: 30,
                                              color: Colors.black,
                                            ))
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )))
                       
                  ],
                ),
                // child 2 of column is the white row
                Container(
                    margin: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                                ad.daysRemaining.toString() + ' days remaining',
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
                                ad.manufacturer.toUpperCase() +
                                    ' ' +
                                    ad.model.toUpperCase() +
                                    ' ' +
                                    ad.year.toString(),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                )),
                          ],
                        ),
                        SizedBox(height: 15),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text('EGP  ' + ad.askPrice.toString(),
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15.0,
                                              )),
                                        ]),
                                  ]),
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          ad.highestBid == 0
                                              ? (Text('No Bids Yet',
                                                  style: TextStyle(
                                                    color: Colors.green,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15.0,
                                                  )))
                                              : (Text(
                                                  'EGP ' +
                                                      ad.highestBid.toString(),
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
                        SizedBox(height: 7),
                        Divider(
                            thickness: 1,
                            color: Color.fromRGBO(150, 150, 150, 1)),
                        SizedBox(height: 20),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text('Details',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                  )),
                            ]),
                        SizedBox(height: 20),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Car Manufacturer',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15.0,
                                      )),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(' ',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15.0,
                                      )),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(ad.manufacturer.toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 15.0,
                                      )),
                                ],
                              )
                            ]),
                        Divider(
                            thickness: 1,
                            color: Color.fromARGB(255, 195, 193, 193)),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Car Model',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15.0,
                                      )),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(' ',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15.0,
                                      )),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(ad.model.toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 15.0,
                                      )),
                                ],
                              )
                            ]),
                        Divider(
                            thickness: 1,
                            color: Color.fromARGB(255, 195, 193, 193)),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Year',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15.0,
                                      )),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(' ',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15.0,
                                      )),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(ad.year.toString(),
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 15.0,
                                      )),
                                ],
                              )
                            ]),
                        Divider(
                            thickness: 1,
                            color: Color.fromARGB(255, 195, 193, 193)),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Capacity',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15.0,
                                      )),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(' ',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15.0,
                                      )),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(ad.cc.toString() + ' CC',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 15.0,
                                      )),
                                ],
                              )
                            ]),
                        Divider(
                            thickness: 1,
                            color: Color.fromARGB(255, 195, 193, 193)),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('KM',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15.0,
                                      )),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(' ',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15.0,
                                      )),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(ad.km.toString() + ' KM',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 15.0,
                                      )),
                                ],
                              )
                            ]),
                        Divider(
                            thickness: 1,
                            color: Color.fromARGB(255, 195, 193, 193)),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Gear',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15.0,
                                      )),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(' ',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15.0,
                                      )),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(ad.auto == 0 ? 'AUTO' : 'Manual',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 15.0,
                                      )),
                                ],
                              ),
                            ]),
                        Divider(
                            thickness: 1,
                            color: Color.fromARGB(255, 195, 193, 193)),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Color',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15.0,
                                      )),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(' ',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15.0,
                                      )),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(ad.colour.toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 15.0,
                                      )),
                                ],
                              )
                            ]),
                        Divider(
                            thickness: 1,
                            color: Color.fromRGBO(150, 150, 150, 1)),
                        SizedBox(height: 20),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text('Description',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                  )),
                            ]),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                                child: Text(ad.desc,
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 15.0,
                                    )))
                          ],
                        ),
                        SizedBox(height: 150),
                      ],
                    ))
              ]))
        ])),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Visibility(
            visible: ad.ownerId != userId ? (true) : (false),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  bottom: 20,
                  right: 30,
                  child: FloatingActionButton(
                    backgroundColor: Colors.green[400],
                    heroTag: 'btn1',
                    elevation: 60,
                    onPressed: () {},
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: const Icon(
                        Icons.phone,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  right: 100,
                  child: FloatingActionButton(
                    backgroundColor: Colors.green[400],
                    heroTag: 'btn2',
                    // Color.fromRGBO(239, 235, 235, 1),
                    elevation: 60,
                    onPressed: handleOnPressChat,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Image(
                        image: AssetImage("assets/images/chatsNoBck.png"),
                        width: 30,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  right: 170,
                  child: FloatingActionButton(
                    backgroundColor: Colors.green[400],
                    elevation: 60,
                    heroTag: 'btn3',
                    onPressed: showBidSheet,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Image(
                        image: AssetImage('assets/images/bid.png'),
                        width: 30,
                      ),
                    ),
                  ),
                )
              ],
            )));
  }


  
}
