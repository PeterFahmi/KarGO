import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kargo/components/ad_card2.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:kargo/components/my_bottom_navigator.dart';
import 'package:kargo/components/my_scaffold.dart';
import 'package:kargo/components/my_shimmering_card.dart';
import 'package:kargo/components/no_Internet.dart';
import 'package:kargo/screens/loading_screen.dart';
import '../components/multiChip.dart';
import '../models/ad.dart';
import '../models/user.dart' as UserModel;

import 'empty_screen.dart';
import 'my_ads_screen.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
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
  void initState() {
    super.initState();
    checkConnectitivy();
    if (internetConnection) {
      getAllAds();
    }
  }

  var _selectedTabIndex = 0;
  List<Ad> ads = [];
  List<Ad> favoriteAds = [];
  List<Ad> myAds = [];
  var currentUser = getCurrentUser();
  List<String> searchResults = [];
  int _maxyear2 = 2000;
  int _minyear2 = 0;
  int _maxcc = 2000;
  int _mincc = 0;
  late double _minPrice2 = 0;
  late double _maxPrice2 = 100;
  bool isLoading = true;
  bool isLoadingf = true;
  bool isLoadingm = true;
  void getAllAds() async {
// Get a reference to the "car_ads" collection
    final carAdsRef = FirebaseFirestore.instance.collection('ads');
    List<String> models1 = [];
// Query the collection to get all documents
    final querySnapshot = await carAdsRef.get();

// create a map to store the models for each manufacturer

// Iterate through the car ad documents and get the models for each manufacturer
    querySnapshot.docs.forEach((carAdDoc) {
      // get the manufacturer name

      String k = carAdDoc.id;
      setState(() {
        searchResults.add(k);
        loadAds();
      });
    });

    return;
  }

  @override
  Widget build(BuildContext context) {
    checkConnectitivy();

    return internetConnection
        ? NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  backgroundColor: Color.fromRGBO(0, 0, 0, 0.2),
                  floating: true,
                  title: Text("Have a specific car in mind?"),
                  actions: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: ElevatedButton(
                        onPressed: Adfilter,
                        child: Text('Filter'),
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
            body: (Container(
                child: ads.length == 0
                    ? EmptyScreen()
                    : ListView(
                        reverse: false,
                        children: [
                          ...ads.map((e) => Ad_Card2(Ad: e)),
                          if (isLoading) ShimmerCard(),
                        ],
                      ))),
          )
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

  onNavigationBarChanged(index) {
    setState(() {
      isLoading = true;
      isLoadingf = true;
      isLoadingm = true;

      getAllAds();
      _selectedTabIndex = index;
    });
  }

  Future<Map<String, List<String>>> getModels() async {
// Get a reference to the "car_ads" collection
    final carAdsRef = FirebaseFirestore.instance.collection('types');
    Map<String, List<String>> models1 = {};
// Query the collection to get all documents
    final querySnapshot = await carAdsRef.get();

// create a map to store the models for each manufacturer
    double minp = 1000.0;
    double maxp = 0;

    int miny = 10000;
    int maxy = 0;
    int mincc = 10000;
    int maxcc = 0;

// Iterate through the car ad documents and get the models for each manufacturer
    querySnapshot.docs.forEach((carAdDoc) {
      // get the manufacturer name

      String manufacturer = carAdDoc.data()['manufacturer'];

      String model = carAdDoc.data()['model'];
      // check if the manufacturer already exists in the map
      if (models1.containsKey(manufacturer)) {
        // if it does, add the model to the list of models for that manufacturer
        models1[manufacturer]!.add(model);
      } else {
        // if it doesn't, add the manufacturer and model to the map
        models1[manufacturer] = [model];
      }
    });
    await FirebaseFirestore.instance
        .collection('extrema')
        .where(FieldPath.documentId, isEqualTo: "extremes")
        .get()
        .then((value) {
      value.docs.forEach((element) {
        minp = element["min_price"].toDouble();
        maxp = element["max_price"].toDouble();
        miny = element["min_year"];
        maxy = element["max_year"];
        mincc = element["min_cc"];
        maxcc = element["max_cc"];
      });
    });
    models1["price"] = [maxp.toString(), minp.toString()];
    models1["year"] = [maxy.toString(), miny.toString()];
    models1["cc"] = [maxcc.toString(), mincc.toString()];

    return models1;
  }

  Adfilter() {
    final _formKey = GlobalKey<FormState>();
    List<String> _manufacturers = [];
    List<String> _models = [];
    late String _year;
    late String _minyear;
    late String _maxyear;

    List<String> availableModels = [];
    double minp = 1000;
    double maxp = 0;
    int miny = 10000;
    int maxy = 0;
    int mincc = 10000;
    int maxcc = 0;
    Map<String, List<String>> models = {};
    getModels().then((newModels) {
      // update the models map and trigger a rebuild
      setState(() {
        models = newModels;
        minp = double.parse((newModels["price"]![1]));
        maxp = double.parse((newModels["price"]![0]));
        if (_minPrice2 == 0) {
          _minPrice2 = minp;
          _maxPrice2 = maxp;
        }

        miny = int.parse((newModels["year"]![1]));
        maxy = int.parse((newModels["year"]![0]));
        if (_minyear2 == 0) {
          _minyear2 = miny;
          _maxyear2 = maxy;
        }

        mincc = int.parse((newModels["cc"]![1]));
        maxcc = int.parse((newModels["cc"]![0]));
        if (_mincc == 0) {
          _mincc = mincc;
          _maxcc = maxcc;
        }
        print(minp);
        print(maxp);
        newModels.remove("price");
        models.remove("price");
        newModels.remove("year");
        models.remove("year");
        newModels.remove("cc");
        models.remove("cc");
        availableModels = models.values.toList().expand((i) => i).toList();
      });

      showModalBottomSheet<dynamic>(
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          context: context,
          builder: (context) {
            return StatefulBuilder(builder: (BuildContext context,
                StateSetter setState1 /*You can rename this!*/) {
              return Wrap(children: <Widget>[
                Container(
                    decoration: new BoxDecoration(
                        color: Colors.white,
                        borderRadius: new BorderRadius.only(
                            topLeft: const Radius.circular(25.0),
                            topRight: const Radius.circular(25.0))),
                    width: double.infinity,
                    child: Column(children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Row(children: [
                              SizedBox(width: 5),
                              Text("Manufacturers: "),
                              SizedBox(width: 5),
                              Expanded(
                                  child: MultiSelectChip(
                                labels: models.keys.toList(),
                                onSelectionChanged: (selected) {
                                  setState1(() {
                                    _manufacturers = selected;
                                    if (_manufacturers.isEmpty)
                                      availableModels = models.values
                                          .toList()
                                          .expand((i) => i)
                                          .toList();
                                    else
                                      availableModels = models.entries
                                          .where((entry) => _manufacturers
                                              .contains(entry.key))
                                          .expand((entry) => entry.value)
                                          .toList();
                                    _models = _models
                                        .where((element) =>
                                            availableModels.contains(element))
                                        .toList();
                                  });
                                },
                              ))
                            ]),
                            Row(children: [
                              SizedBox(width: 5),
                              Text("Models: "),
                              SizedBox(width: 5),
                              Expanded(
                                  child: MultiSelectChip(
                                labels: availableModels,
                                onSelectionChanged: (selected) {
                                  setState1(() {
                                    _models = selected;
                                  });
                                },
                              ))
                            ]),
                            Row(children: [
                              SizedBox(width: 5),
                              Text("Price: "),
                              SizedBox(width: 5),
                              Expanded(
                                  child: RangeSlider(
                                activeColor: Colors.black,
                                inactiveColor:
                                    Color.fromARGB(255, 191, 190, 190),
                                values: RangeValues(_minPrice2, _maxPrice2),
                                min: minp > maxp ? maxp : minp,
                                max: minp > maxp ? minp : maxp,
                                divisions: 100,
                                labels: RangeLabels(_minPrice2.toString(),
                                    _maxPrice2.toString()),
                                onChanged: (values) {
                                  setState1(() {
                                    _minPrice2 = values.start;
                                    _maxPrice2 = values.end;
                                    print(_minPrice2);
                                    print(_maxPrice2);
                                  });
                                },
                              ))
                            ]),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Min: ' + _minPrice2.toString()),
                                SizedBox(width: 10),
                                Text('Max: ' + _maxPrice2.toString()),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(children: [
                              SizedBox(width: 5),
                              Text("Year: "),
                              SizedBox(width: 5),
                              Expanded(
                                  child: RangeSlider(
                                activeColor: Colors.black,
                                inactiveColor:
                                    Color.fromARGB(255, 191, 190, 190),
                                values: RangeValues(
                                    _minyear2.toDouble(), _maxyear2.toDouble()),
                                min: miny > maxy
                                    ? maxy.toDouble()
                                    : miny.toDouble(),
                                max: miny > maxy
                                    ? miny.toDouble()
                                    : maxy.toDouble(),
                                divisions: 100,
                                labels: RangeLabels(
                                    _minyear2.toString(), _maxyear2.toString()),
                                onChanged: (values) {
                                  setState1(() {
                                    _minyear2 = values.start.toInt();
                                    _maxyear2 = values.end.toInt();
                                  });
                                },
                              ))
                            ]),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Min: ' + _minyear2.toString()),
                                SizedBox(width: 10),
                                Text('Max: ' + _maxyear2.toString()),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(children: [
                              SizedBox(width: 5),
                              Text("CC: "),
                              SizedBox(width: 5),
                              Expanded(
                                  child: RangeSlider(
                                activeColor: Colors.black,
                                inactiveColor:
                                    Color.fromARGB(255, 191, 190, 190),
                                values: RangeValues(
                                    _mincc.toDouble(), _maxcc.toDouble()),
                                min: mincc > maxcc
                                    ? maxcc.toDouble()
                                    : mincc.toDouble(),
                                max: mincc > maxcc
                                    ? mincc.toDouble()
                                    : maxcc.toDouble(),
                                divisions: 100,
                                labels: RangeLabels(
                                    _mincc.toString(), _maxcc.toString()),
                                onChanged: (values) {
                                  setState1(() {
                                    _mincc = values.start.toInt();
                                    _maxcc = values.end.toInt();
                                  });
                                },
                              ))
                            ]),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Min: ' + _mincc.toString()),
                                SizedBox(width: 10),
                                Text('Max: ' + _maxcc.toString()),
                              ],
                            ),
                            SizedBox(height: 10),
                            ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.black)),
                              child: Text("Filter"),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  isLoading = true;
                                  CollectionReference carAdsRef =
                                      FirebaseFirestore.instance
                                          .collection('types');
                                  Query query = carAdsRef;
                                  if (_manufacturers.isNotEmpty) {
                                    query = query.where('manufacturer',
                                        whereIn: _manufacturers);
                                  }

                                  query.get().then((snapshot) async {
                                    List<String> cars = [];
                                    List<DocumentSnapshot> carAds =
                                        snapshot.docs;
                                    carAds.forEach((document) {
                                      String k = document.id;
                                      var temp = document.data().toString();
                                      temp = temp.replaceAllMapped(
                                          new RegExp(r'(\w+):'),
                                          (match) => '"${match[1]}":');
                                      temp = temp.replaceAllMapped(
                                          new RegExp(r': (\w+)'),
                                          (match) => ': "${match[1]}"');
                                      //print(temp);
                                      Map<String, dynamic> map =
                                          jsonDecode(temp);
                                      //Car_ad ad=Car_ad.fromJson( jsonDecode(temp));
                                      if (((!_models.any((model) => models[
                                                          map["manufacturer"]]!
                                                      .contains(model)) &&
                                                  _manufacturers.isNotEmpty) ||
                                              _models.contains(map["model"])) ||
                                          (_manufacturers.isEmpty &&
                                              _models.isEmpty)) {
                                        cars.add(k);
                                      }
                                    });

                                    print(cars);
                                    List<List<String>> subList = [];
                                    for (var i = 0; i < cars.length; i += 10) {
                                      subList.add(cars.sublist(
                                          i,
                                          i + 10 > cars.length
                                              ? cars.length
                                              : i + 10));
                                    }
                                    CollectionReference carRef =
                                        FirebaseFirestore.instance
                                            .collection('cars');
                                    List<String> cars3 = [];
                                    int sub1 = 0;
                                    int len = subList.length;
                                    if (cars.isEmpty) {
                                      setState(() {
                                        searchResults = cars3;
                                        loadAds();
                                      });
                                    }
                                    subList.forEach((element) {
                                      Query query = carRef;
                                      if (!(_minyear2 == miny)) {
                                        query = query.where('year',
                                            isGreaterThanOrEqualTo: _minyear2);
                                      }
                                      if (!(_maxyear2 == maxy)) {
                                        query = query.where('year',
                                            isLessThanOrEqualTo: _maxyear2);
                                      }

                                      if (!(_mincc == mincc)) {
                                        query = query.where('cc',
                                            isGreaterThanOrEqualTo: _mincc);
                                      }
                                      if (!(_maxcc == maxcc)) {
                                        query = query.where('cc',
                                            isLessThanOrEqualTo: _mincc);
                                      }

                                      if (_manufacturers.isNotEmpty ||
                                          _models.isNotEmpty) {
                                        query = query.where("type_id",
                                            whereIn: element);
                                      }
                                      query.get().then((snapshot) async {
                                        List<String> cars2 = [];
                                        List<DocumentSnapshot> carAds =
                                            snapshot.docs;
                                        carAds.forEach((document) {
                                          String k = document.id;

                                          cars2.add(k);
                                        });

                                        CollectionReference carRef2 =
                                            FirebaseFirestore.instance
                                                .collection('ads');
                                        List<List<String>> subList2 = [];
                                        int c2 = 0;
                                        if (cars2.isEmpty) {
                                          setState(() {
                                            searchResults = cars3;
                                            loadAds();
                                          });
                                        }
                                        for (var i = 0;
                                            i < cars2.length;
                                            i += 10) {
                                          subList2.add(cars2.sublist(
                                              i,
                                              i + 10 > cars2.length
                                                  ? cars2.length
                                                  : i + 10));
                                        }
                                        subList2.forEach((element2) async {
                                          Query query = carRef2;

                                          if (!(_minPrice2 == minp)) {
                                            query = query.where('ask_price',
                                                isGreaterThanOrEqualTo:
                                                    _minPrice2);
                                          }
                                          if (!(_maxPrice2 == maxp)) {
                                            query = query.where('ask_price',
                                                isLessThanOrEqualTo:
                                                    _maxPrice2);
                                          }

                                          if (!element2.isEmpty) {
                                            query = query.where("car_id",
                                                whereIn: element2);
                                            await query
                                                .get()
                                                .then((snapshot) async {
                                              List<DocumentSnapshot> carAds =
                                                  snapshot.docs;
                                              carAds.forEach((document) {
                                                String k = document.id;
                                                c2 = c2 + 1;
                                                cars3.add(k);
                                                setState(() {
                                                  searchResults = cars3;
                                                  loadAds();
                                                });
                                              });
                                            });
                                          }
                                          print(c2);
                                          print(sub1);
                                          if (c2 == cars2.length) {
                                            sub1 = sub1 + 1;
                                          }

                                          if (c2 == cars2.length &&
                                              sub1 == len) {
//       setState(() {
//  searchResults=cars3;
// loadAds();
//  });
                                          }

                                          print("cars3 $cars3");
                                        }); //batch2
                                      });
                                    });
                                    print("cars3b1 $cars3"); //batch1
                                    // Display the filtered list of car ads
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      )
                      //form
                    ]))
              ]);
            });
          } //alala

          );
    });
  }

  void loadAds() async {
    CollectionReference adsCollection =
        FirebaseFirestore.instance.collection('ads');
    ads = [];
    List<Ad> CarADs = [];
    favoriteAds = [];
    myAds = [];
    List<String> carsIDs = searchResults;

    Set<String> set = new Set<String>.from(carsIDs);

    carsIDs = new List<String>.from(set);
    List favAds = [];
    List mAds = [];
    print("loading $carsIDs");
    if (carsIDs.isEmpty) {
      setState(() {
        ads = CarADs;
        isLoading = false;
        isLoadingf = false;
        isLoadingm = false;
      });
    }
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((res) async {
      final data = res.data() as Map<String, dynamic>;
      favAds = data['favAds'];
      mAds = data['myBids'];

      for (var adId in carsIDs) {
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
          if (this.mounted) {
            setState(() {
              bool p = false;
              for (var ad in ads) {
                if (adv.adId == ad.adId) p = true;
              }
              if (!p) {
                ads.add(adv);
                if (adv.fav > 0) favoriteAds.add(adv);
                if (mAds.contains(adv.adId)) {
                  myAds.add(adv);
                }
              }
              print(myAds);
              print("IDS:$carsIDs");
              print(ads);
              print("aa");
              if (favoriteAds.length == favAds.length) isLoadingf = false;
              if (myAds.length == mAds.length) isLoadingm = false;
              if (carsIDs.length == ads.length ||
                  searchResults.length == ads.length) isLoading = false;
            });
          }
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
