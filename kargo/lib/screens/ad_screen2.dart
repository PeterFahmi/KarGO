import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kargo/components/CarouselWithDots.dart';
import 'package:kargo/components/CarouselBig.dart';
import 'package:kargo/components/no_Internet.dart';
import 'package:kargo/screens/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kargo/models/ad.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kargo/screens/ad_screen2.dart';
import 'package:kargo/services/database_services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class AdScreen extends StatefulWidget {
  const AdScreen({super.key});

  static const routeName = '/ad';

  @override
  State<AdScreen> createState() => _AdScreenState();
}

class _AdScreenState extends State<AdScreen> {
  bool internetConnection = true;
  var bidPrice = 0;
  List userNames = List.empty(growable: true);
  List userBidPrices = List.empty(growable: true);
  List userProfilePhoto = List.empty(growable: true);
  List userIds = List.empty(growable: true);
  bool initialB = true;
  DatabaseService db =
      DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid);
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
  void initState() {
    super.initState();
    checkConnectitivy();
  }

  @override
  Widget build(BuildContext context) {
    checkConnectitivy();
    var ad = ModalRoute.of(context)!.settings.arguments as Ad;
    var userId = FirebaseAuth.instance.currentUser!.uid;

    void fetchAllBids() {
      List namesList = List.empty(growable: true);
      List photosList = List.empty(growable: true);
      List idsList = List.empty(growable: true);
      List pricesList = List.empty(growable: true);
      FirebaseFirestore.instance.collection('users').get().then(
        (user) {
          user.docs.forEach(
            (result) {
              final data = result.data() as Map<dynamic, dynamic>;
              List userBids = data['myBids'];

              for (Map<String, dynamic> item in userBids) {
                var adIdCurrent = item['ad_id'];
                if (adIdCurrent == ad.adId) {
                  pricesList.add(item['bid_price']);
                  idsList.add(result.id);
                  namesList.add(data['name']);
                  photosList.add(data['photoURL']);
                }
                setState(() {
                  userNames = namesList;
                  userIds = idsList;
                  userBidPrices = pricesList;
                  userProfilePhoto = photosList;
                });
              }
            },
          );
        },
      );
    }

    if (initialB) {
      bidPrice = ad.highestBid == 0 ? (ad.askPrice + 1) : (ad.highestBid + 1);
      initialB = false;
      if (internetConnection) {
        fetchAllBids();
      }
    }

    void onPressedDelete() async {
      Navigator.of(context).pop();
      await FirebaseFirestore.instance.collection('ads').doc(ad.adId).delete();
      FirebaseFirestore.instance.collection('users').get().then(
        (user) {
          user.docs.forEach((result) {
            List<dynamic> myBids = result.data()['myBids'];
            List<dynamic> filteredBids =
                myBids.where((element) => element['ad_id'] != ad.adId).toList();
            result.reference.update({'myBids': filteredBids});
          });
        },
      );
      Navigator.of(context).popAndPushNamed('/');
    }

    showDeleteAlert() {
      // set up the buttons
      Widget cancelButton = TextButton(
        child: Text(
          "Cancel",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      );
      Widget continueButton = TextButton(
        child: Text(
          "Delete",
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: onPressedDelete,
      );

      // set up the AlertDialog
      AlertDialog alert = AlertDialog(
        title: Text(
          "Delete?",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "This action can not be undone. Are you sure you want to delete this ad?",
          style: TextStyle(
            fontWeight: FontWeight.normal,
          ),
        ),
        actions: [
          cancelButton,
          continueButton,
        ],
      );

      // show the dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
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
      var newAdd;
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
        final data = res.data() as Map<dynamic, dynamic>;
        bidAds = data['myBids'];
      });
      Map<String, dynamic> currentBid = {
        'ad_id': ad.adId,
        'bid_price': bidPrice,
      };
      bool newAd = true;
      var oldAd;
      for (Map<String, dynamic> item in bidAds) {
        var adIdCurrent = item['ad_id'];
        if (adIdCurrent == ad.adId) {
          newAd = false;
          oldAd = item;
          break;
        }
      }
      if (!newAd) {
        bidAds.remove(oldAd);
      }
      bidAds.add(currentBid);
      var users = FirebaseFirestore.instance.collection('users');
      users
          .doc(userId)
          .update({'myBids': bidAds}) // <-- Updated data
          .then((_) => print(bidAds))
          .catchError((error) => print('Failed: $error'));

      Navigator.pop(context);
      Navigator.pop(context);

      // Navigator.pop(context); // pop current page
      ad.highestBid = bidPrice;
      Navigator.pushNamed(context, "/ad", arguments: ad); // push it back in
    }

    void onPressedEdit() {
      Navigator.of(context)
          .pushNamed('/create_ad', arguments: {'ad': ad, 'isEditable': true});
    }

    showBidSheet() {
      print("in modal");
      print(userNames);
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
                            Text('Current Bids',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                )),
                            SizedBox(height: 10),
                            Divider(
                                thickness: 1,
                                color: Color.fromRGBO(150, 150, 150, 1)),
                            SizedBox(height: 10),
                            ListView.builder(
                                itemCount: userNames.length,
                                shrinkWrap: true,
                                itemBuilder: (BuildContext context, int index) {
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: userProfilePhoto[index] !=
                                              ""
                                          ? NetworkImage(
                                              userProfilePhoto[index] ?? "")
                                          : const AssetImage(
                                                  "assets/images/default.png")
                                              as ImageProvider,
                                      maxRadius: 15,
                                    ),
                                    trailing: Text(
                                        'EGP ' +
                                            userBidPrices[index].toString(),
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15.0,
                                        )),
                                    title: Text(userNames[index]),
                                  );
                                }),
                            SizedBox(height: 30),
                            Text('Your Bid',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                )),
                            SizedBox(height: 10),
                            Divider(
                                thickness: 1,
                                color: Color.fromRGBO(150, 150, 150, 1)),
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
      Navigator.of(context).pushNamed('/ChatDetail',
          arguments: {'username': ownerName, 'chatRef': chatRef});
    }

    viewBidsSheet() {
      print("in modal");
      print(userNames);
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
                          child: Text('View Bids',
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
                            Text('Current Bids',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                )),
                            SizedBox(height: 10),
                            Divider(
                                thickness: 1,
                                color: Color.fromRGBO(150, 150, 150, 1)),
                            SizedBox(height: 10),
                            ListView.builder(
                                itemCount: userNames.length,
                                shrinkWrap: true,
                                itemBuilder: (BuildContext context, int index) {
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: userProfilePhoto[index] !=
                                              ""
                                          ? NetworkImage(
                                              userProfilePhoto[index] ?? "")
                                          : const AssetImage(
                                                  "assets/images/default.png")
                                              as ImageProvider,
                                      maxRadius: 15,
                                    ),
                                    trailing: Text(
                                        'EGP ' +
                                            userBidPrices[index].toString(),
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15.0,
                                        )),
                                    // (GestureDetector(
                                    //         onTap: handleOnPressChat,
                                    //         child: Padding(
                                    //           padding: const EdgeInsets.all(
                                    //               10.0),
                                    //           child: Image(
                                    //             image: AssetImage(
                                    //                 'assets/images/chats.png'),
                                    //             width: 30,
                                    //           ),
                                    //         ),
                                    //       )),

                                    title: Text(userNames[index]),
                                  );
                                }),
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ]);
            });
          });
    }

    return internetConnection
        ? (new Scaffold(
            appBar: PreferredSize(
                preferredSize: const Size.fromHeight(80.0),
                child: Container(
                  padding: const EdgeInsets.only(top: 10),
                  child: AppBar(
                    backgroundColor: Colors.white,
                    titleSpacing: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    actions: <Widget>[
                      // IconButton(
                      //   icon: const Icon(Icons.phone, color: Colors.black),
                      //   tooltip: 'Call',
                      //   onPressed: () {},
                      // ),
                      GestureDetector(
                        onTap: ad.ownerId == userId
                            ? ((() =>
                                Navigator.of(context).pushNamed('/Chats')))
                            : (handleOnPressChat),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Image(
                            image: AssetImage('assets/images/chats.png'),
                            width: 30,
                          ),
                        ),
                      ),
                    ], //<Widget>[]
                    title: Text(
                      ad.title.toUpperCase(),
                      style: const TextStyle(
                          fontSize: 28,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                )),
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
                      ],
                    ),
                    // child 2 of column is the white row
                    Container(
                        margin: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ad.ownerId == userId
                                ? SizedBox(
                                    height: 5,
                                  )
                                : Container(),
                            ad.ownerId == userId
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      OutlinedButton(
                                          style: ButtonStyle(
                                            side: MaterialStateProperty.all(
                                                BorderSide(width: 1)),
                                            shape: MaterialStateProperty.all(
                                                RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30.0))),
                                          ),
                                          onPressed: onPressedEdit,
                                          child: Text(
                                            "Edit ad",
                                            style:
                                                TextStyle(color: Colors.black),
                                          ))
                                    ],
                                  )
                                : Container(),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                        ad.daysRemaining.toString() +
                                            ' days remaining',
                                        style: TextStyle(
                                          color:
                                              Color.fromRGBO(150, 150, 150, 1),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.0,
                                        )),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 15),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                  'EGP  ' +
                                                      ad.askPrice.toString(),
                                                  style: TextStyle(
                                                    color: Colors.green,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 17.0,
                                                  )),
                                            ]),
                                      ]),
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              ad.highestBid == 0
                                                  ? (Text('No Bids Yet',
                                                      style: TextStyle(
                                                        color: Colors.green,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 17.0,
                                                      )))
                                                  : (Text(
                                                      'EGP ' +
                                                          ad.highestBid
                                                              .toString(),
                                                      style: TextStyle(
                                                        color: Colors.green,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 17.0,
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
                                          color:
                                              Color.fromRGBO(150, 150, 150, 1),
                                          fontSize: 13.0,
                                          fontWeight: FontWeight.bold,
                                        )),
                                  ],
                                ),
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text('Highest Bid',
                                          style: TextStyle(
                                            color: Color.fromRGBO(
                                                150, 150, 150, 1),
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
                            SizedBox(height: 25),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Car Manufacturer',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15.0,
                                          )),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(ad.manufacturer.toUpperCase(),
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.w600,
                                          )),
                                    ],
                                  )
                                ]),
                            Divider(
                                thickness: 1,
                                color: Color.fromARGB(255, 195, 193, 193)),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Car Model',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15.0,
                                          )),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(ad.model.toUpperCase(),
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15.0,
                                          )),
                                    ],
                                  )
                                ]),
                            Divider(
                                thickness: 1,
                                color: Color.fromARGB(255, 195, 193, 193)),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Year',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15.0,
                                          )),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(ad.year.toString(),
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15.0,
                                          )),
                                    ],
                                  )
                                ]),
                            Divider(
                                thickness: 1,
                                color: Color.fromARGB(255, 195, 193, 193)),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Capacity',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15.0,
                                          )),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(ad.cc.toString() + ' CC',
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15.0,
                                          )),
                                    ],
                                  )
                                ]),
                            Divider(
                                thickness: 1,
                                color: Color.fromARGB(255, 195, 193, 193)),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('KM',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15.0,
                                          )),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(ad.km.toString() + ' KM',
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15.0,
                                          )),
                                    ],
                                  )
                                ]),
                            Divider(
                                thickness: 1,
                                color: Color.fromARGB(255, 195, 193, 193)),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Gear',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15.0,
                                          )),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(ad.auto == 0 ? 'AUTO' : 'Manual',
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.w600,
                                          )),
                                    ],
                                  ),
                                ]),
                            Divider(
                                thickness: 1,
                                color: Color.fromARGB(255, 195, 193, 193)),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Color',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15.0,
                                          )),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(ad.colour.toUpperCase(),
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w600,
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
                            ad.ownerId == userId
                                ? Column(
                                    children: [
                                      SizedBox(height: 50),
                                      Center(
                                        child: MaterialButton(
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(9))),
                                            height: 50,
                                            minWidth: 150,
                                            color: Colors.red[400],
                                            onPressed: showDeleteAlert,
                                            child: Icon(
                                              Icons.delete,
                                              color: Colors.white,
                                            )),
                                      ),
                                      SizedBox(height: 90),
                                    ],
                                  )
                                : Container(),
                          ],
                        ))
                  ]))
            ])),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: Visibility(
                // visible: ad.ownerId != userId ? (true) : (false),
                child: ad.ownerId != userId
                    ? (Stack(
                        fit: StackFit.expand,
                        children: [
                          // Positioned(
                          //   bottom: 20,
                          //   right: 30,
                          //   child: FloatingActionButton(
                          //     backgroundColor: Colors.green[400],
                          //     heroTag: 'btn1',
                          //     elevation: 60,
                          //     onPressed: fetchAllBids,
                          //     child: Padding(
                          //       padding: const EdgeInsets.all(10.0),
                          //       child: const Icon(
                          //         Icons.phone,
                          //         color: Colors.black,
                          //         size: 20,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          // Positioned(
                          //   bottom: 20,
                          //   right: 100,
                          //   child: FloatingActionButton(
                          //     backgroundColor: Colors.green[400],
                          //     heroTag: 'btn2',
                          //     // Color.fromRGBO(239, 235, 235, 1),
                          //     elevation: 60,
                          //     onPressed: handleOnPressChat,
                          //     child: Padding(
                          //       padding: const EdgeInsets.all(10.0),
                          //       child: Image(
                          //         image: AssetImage("assets/images/chatsNoBck.png"),
                          //         width: 30,
                          //       ),
                          //     ),
                          //   ),
                          // ),

                          Positioned(
                            bottom: 20,
                            right: 100,
                            child: FloatingActionButton.extended(
                              backgroundColor: Colors.green[400],
                              elevation: 60,
                              heroTag: 'btn3',
                              onPressed: showBidSheet,
                              label: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    children: [
                                      SizedBox(width: 10),
                                      Image(
                                        image: AssetImage(
                                            'assets/images/auction.png'),
                                        width: 30,
                                      ),
                                      SizedBox(width: 10),
                                      Text('Place Bid',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15.0,
                                          )),
                                      SizedBox(width: 10),
                                    ],
                                  )),
                            ),
                          )
                        ],
                      ))
                    : (Stack(fit: StackFit.expand, children: [
                        Positioned(
                          bottom: 20,
                          right: 100,
                          child: FloatingActionButton.extended(
                            backgroundColor: Colors.green[400],
                            elevation: 60,
                            heroTag: 'btn3',
                            onPressed: viewBidsSheet,
                            label: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  children: [
                                    SizedBox(width: 10),
                                    Image(
                                      image: AssetImage(
                                          'assets/images/auction.png'),
                                      width: 30,
                                    ),
                                    SizedBox(width: 10),
                                    Text('View Bids',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15.0,
                                        )),
                                    SizedBox(width: 10),
                                  ],
                                )),
                          ),
                        )
                      ])))))
        : (noInternet());
  }
}
