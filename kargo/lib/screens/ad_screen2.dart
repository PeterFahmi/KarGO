import 'package:flutter/material.dart';
import 'package:kargo/components/CarouselWithDots.dart';
import 'package:kargo/components/CarouselBig.dart';
import 'package:kargo/screens/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kargo/models/ad.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kargo/screens/ad_screen2.dart';

class AdScreen extends StatefulWidget {
  const AdScreen({super.key});

  static const routeName = '/ad';

  @override
  State<AdScreen> createState() => _AdScreenState();
}

class _AdScreenState extends State<AdScreen> {
  @override
  Widget build(BuildContext context) {
    var ad = ModalRoute.of(context)!.settings.arguments as Ad;

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
      favAds.remove(ad.adId);
      var ads = FirebaseFirestore.instance.collection('users');
      ads
          .doc(userId)
          .update({'favAds': favAds}) // <-- Updated data
          .then((_) => print(favAds))
          .catchError((error) => print('Failed: $error'));
      setState(() {
        ad.fav = 0;
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
                      ))
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
                          Text('3 hours ago',
                              style: TextStyle(
                                color: Color.fromRGBO(150, 150, 150, 1),
                                fontWeight: FontWeight.bold,
                                fontSize: 13.0,
                              )),
                        ],
                      ),

                      //SizedBox(height: 10),
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
                      SizedBox(height: 30),
                    ],
                  ))
            ]))
      ])),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Stack(
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
              onPressed: () {
                Navigator.of(context).pushNamed('/Chats');
              },
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Image(
                  image: AssetImage('assets/images/chatsNoBck.png'),
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
              onPressed: () {
                Navigator.of(context).pushNamed('/Chats');
              },
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
      ),
    );
  }
}
