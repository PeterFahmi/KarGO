import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kargo/models/user.dart' as UserModel;
import 'package:kargo/models/ad.dart';
import '../components/profile_component.dart';
import '../components/my_expansion_tile.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../components/my_text_field.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  bool isEditable = false;
  XFile? uploadedImage;
  int tabIndex = 0;
  var userAds = [];
  var userBids = [];
  bool fetched = false;
  bool isAdLoading = true;
  bool isBidLoading = true;

  late TextEditingController nameController;
  late TabController _tabController;

  final _selectedColor = Color(0xff1a73e8);
  final _unselectedColor = Color(0xff5f6368);
  final _tabs = [
    Tab(text: 'My Ads'),
    Tab(text: 'My Bids'),
    Tab(text: 'Settings'),
  ];
  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routeArgs =
        ModalRoute.of(context)!.settings.arguments as Map<String, Object?>;

    final curUser = routeArgs['user'] as UserModel.User;
    final updateUserFunction = routeArgs['callBack'] as Function;
    List<String> childrenList = ["Child1", "Child2"];
    nameController = TextEditingController(text: curUser!.name);
    if (!fetched) {
      fetchAds(curUser.myAds);
      print(curUser.myBids);
      fetchBids(curUser.myBids);
      fetched = true;
    }
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Colors.black,
        ),
        actions: [
          isEditable
              ? TextButton(
                  onPressed: () async {
                    ConfirmEdits(curUser, updateUserFunction);
                  },
                  child: Text(
                    "Done",
                    style: TextStyle(color: Colors.black, fontSize: 17),
                  ))
              : Text("")
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          const SizedBox(height: 28),
          ProfileComponent(
            imagePath: curUser!.imagePath!,
            editProfileCallBack: editProfile,
            setUploadedImage: setUploadedImage,
            isEditable: isEditable,
          ),
          const SizedBox(height: 24),
          buildName(curUser),
          const SizedBox(height: 24),
          !isEditable
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TabBar(
                    onTap: (value) => setState(() {
                      tabIndex = value;
                    }),
                    controller: _tabController,
                    tabs: _tabs,
                    unselectedLabelColor: Colors.black,
                    labelColor: _selectedColor,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(80.0),
                      color: _selectedColor.withOpacity(0.2),
                    ),
                  ),
                )
              : Container(),
          !isEditable
              ? (tabIndex == 2
                  ? getSettingsList(curUser, context)
                  : tabIndex == 1
                      ? dispayBids(context)
                      : displayAds(context))
              : Container()
        ],
      ),
    );
  }

  Widget buildName(UserModel.User user) => Column(
        children: [
          isEditable
              ? MyTextField(
                  label: "Full Name",
                  inset: 10,
                  controller: nameController,
                )
              : Text(
                  user.name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: TextStyle(color: Colors.grey),
          )
        ],
      );

  void ConfirmEdits(UserModel.User curUser, Function updateUserFunction) async {
    curUser.name = nameController.text;
    if (uploadedImage != null) {
      File imageFile = File(uploadedImage!.path);
      final defaultImagePathUrl =
          'https://firebasestorage.googleapis.com/v0/b/mobileapp-18909.appspot.com/o/profile_pictures%2Fimage_picker6613525771089450064.jpg?alt=media&token=b89b540f-341f-4f04-81ed-c7d0be17e960';
      final storageRef = FirebaseStorage.instance.ref();
      final imageRef =
          storageRef.child('profile_pictures/${uploadedImage!.name}');
      var uploadTask = imageRef.putFile(imageFile);

      final snapshot = await uploadTask!.whenComplete(() {});

      final newImageURl = await snapshot.ref.getDownloadURL();
      final oldPath = curUser.imagePath;
      curUser.imagePath = newImageURl;
      if (defaultImagePathUrl != oldPath) {
        final deleteRef = FirebaseStorage.instance.refFromURL(oldPath!);
        deleteRef.delete().then((res) {
          print("deleted");
        }).catchError(() {
          print("deletion error");
        });
      }
    }
    updateUserFunction(curUser);
    setState(() {
      isEditable = false;
    });
    uploadedImage = null;
  }

  void editProfile() {
    setState(() {
      isEditable = !isEditable;
    });
  }

  void setUploadedImage(XFile myUploadedImage) {
    uploadedImage = myUploadedImage;
  }

  wrapDBAd(adData, carData, typeData, adId) {
    List<String> imgPth = [];
    for (var i = 0; i < carData['photos'].length; i++) {
      imgPth.add(carData['photos'][i]);
    }
    if (imgPth.isEmpty)
      imgPth.add(
          "https://prod-ripcut-delivery.disney-plus.net/v1/variant/disney/406172AFB9ADF0578670A0B256610FA794B8D2C6259DC784B1DB900C92694E1D/scale?width=1200&aspectRatio=1.78&format=jpeg");
    return Ad(
        imagePaths: imgPth,
        adId: adId,
        highestBidderId: adData['highest_bidder_id'],
        ownerId: adData['owner_id'],
        manufacturer: typeData['manufacturer'],
        model: typeData['model'],
        askPrice: adData['ask_price'],
        highestBid: adData['highest_bid'],
        cc: (carData['cc']),
        auto: adData['auto'],
        year: carData['year'],
        typeId: carData['type_id'],
        colour: carData['color'],
        km: carData['km'],
        title: adData['title'],
        desc: adData['desc'],
        carId: adData['car_id'],
        startDate: adData['start_date'],
        endDate: adData['end_date'],
        fav: adData['fav'] ?? 0,
        daysRemaining:
            DateTime.now().difference(adData['end_date'].toDate()).inDays * -1);
  }

  fetchAnAd(adId) async {
    final adsCollection = FirebaseFirestore.instance.collection('ads');
    final ad = await adsCollection.doc(adId).get();
    if (ad.data() != null) {
      final adCar = await FirebaseFirestore.instance
          .collection('cars')
          .doc(ad.data()!['car_id'])
          .get();
      if (adCar != null) {
        final carType = await FirebaseFirestore.instance
            .collection('types')
            .doc(adCar.data()!['type_id'])
            .get();
        return wrapDBAd(ad.data(), adCar.data(), carType.data(), adId);
      }
      return null;
    }
  }

  fetchBids(bidsIds) async {
    var bidsArr = [];
    for (var i = 0; i < bidsIds.length; i++) {
      Map<String, dynamic> bid = bidsIds[i] as Map<String, dynamic>;
      final fetchedAd = await fetchAnAd(bid[bid.keys.first]);
      if (fetchedAd != null)
        bidsArr.add({'ad': fetchedAd, 'price': bidsIds[i][bid.keys.last]});
    }
    setState(
      () {
        userBids = bidsArr;
        isBidLoading = false;
      },
    );
  }

  fetchAds(adsIds) async {
    var adsArr = [];
    for (var i = 0; i < adsIds.length; i++) {
      final fetchedAd = await fetchAnAd(adsIds[i]);
      if (fetched != null) adsArr.add(fetchedAd);
    }

    setState(() {
      userAds = adsArr;
      isAdLoading = false;
    });
  }

  dispayBids(ctx) {
    return isBidLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : userBids.isEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Image(
                      image: NetworkImage(
                          "https://firebasestorage.googleapis.com/v0/b/mobileapp-18909.appspot.com/o/no%20bids.png?alt=media&token=33b9e404-12c8-4d3e-bec8-0a98a8d256d6"),
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    "No bids yet",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              )
            : Column(
                children: userBids.map((e) {
                  return getListTile(e, false, ctx);
                }).toList(),
              );
  }

  displayAds(ctx) {
    return isAdLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : userAds.isEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 40,
                  ),
                  Text(
                    "You have no ads yet",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Create your first by clicking the button below ...",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  MaterialButton(
                    textColor: Colors.white,
                    color: Colors.black,
                    child: Text("Create a new ad"),
                    onPressed: () {
                      Navigator.of(context)
                          .pushNamed('/create_ad', arguments: {'ad': null});
                    },
                  )
                ],
              )
            : Column(
                children: userAds.map((e) {
                  return getListTile(e, true, ctx);
                }).toList(),
              );
  }
}

Widget getSettingsList(UserModel.User curUser, context) {
  return Container(
    child: Column(children: [
      SizedBox(
        height: 20,
      ),
      Row(
        children: [
          SizedBox(
            width: 45,
          ),
          Icon(Icons.key),
          SizedBox(
            width: 20,
          ),
          TextButton(
              onPressed: (() {
                Navigator.of(context).pushNamed('/update_password_screen',
                    arguments: {'user': curUser});
              }),
              child: Text(
                "Change password",
                style: TextStyle(color: Colors.black),
              )),
        ],
      ),
      Row(
        children: [
          SizedBox(
            width: 45,
          ),
          Icon(Icons.phone_iphone_sharp),
          SizedBox(
            width: 20,
          ),
          Container(
            child: TextButton(
                onPressed: (() {}),
                child: Text(
                  "Add phone number",
                  style: TextStyle(color: Colors.black),
                )),
          )
        ],
      ),
      SizedBox(
        height: 50,
      ),
      TextButton(
          onPressed: (() {
            FirebaseAuth.instance.signOut();
            Navigator.of(context).pop();
          }),
          child: Text(
            "Log out",
            style: TextStyle(color: Colors.red),
          ))
    ]),
  );
}

Widget getListTile(elem, isAd, ctx) {
  return ListTile(
    title: Text(isAd ? elem.title : elem['ad'].title),
    leading: CircleAvatar(
        radius: 30,
        foregroundImage:
            NetworkImage(isAd ? elem.imagePaths[0] : elem['ad'].imagePaths[0])),
    subtitle: Text(
        "Highest bid ${isAd ? elem.highestBid : elem['ad'].highestBid.toString() + ", you bidded: " + elem['price'].toString()}"),
    onTap: () {
      Navigator.of(ctx).pushNamed('/ad', arguments: isAd ? elem : elem['ad']);
    },
  );
}
