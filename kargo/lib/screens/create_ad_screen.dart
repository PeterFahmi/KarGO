import 'dart:ffi';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kargo/components/my_scaffold.dart';
import 'package:kargo/components/no_Internet.dart';
import 'package:kargo/components/uploaded_photos_row.dart';
import 'package:kargo/models/ad.dart';
import 'package:kargo/screens/pages/new_ad_car_page.dart';
import 'package:kargo/screens/pages/new_ad_details_page.dart';
import 'package:kargo/screens/pages/new_ad_manufacture_page.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class CreateAdScreen extends StatefulWidget {
  @override
  State<CreateAdScreen> createState() => _CreateAdScreenState();
}

class _CreateAdScreenState extends State<CreateAdScreen> {
  final PageController _pageController = PageController();
  int index = 0;

  bool internetConnection = true;
  //carpage
  List<Image> imgs = [
    Image(
        image: AssetImage('assets/images/carPlaceHolder.jpg'),
        fit: BoxFit.fill,
        width: double.infinity)
  ];
  List<XFile> imgsXfiles = [];
  List<String> imgPaths = [];

  final yearCtrl = TextEditingController(),
      kmCtrl = TextEditingController(),
      ccCtrl = TextEditingController(),
      colorCtrl = TextEditingController(),
      manufacturerDropdownCtrl = TextEditingController(),
      modelDropdownCtrl = TextEditingController(),
      adTitle = TextEditingController(),
      adDescription = TextEditingController(),
      askPrice = TextEditingController(),
      adDuration = TextEditingController(),
      transmissionCtrl = TextEditingController(),
      manufacturerOtherCtrl = TextEditingController(),
      modelOtherCtrl = TextEditingController();

  bool noImages = true;
  bool nextEnabled = false;
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

  bool hasLoaded = false;

  @override
  Widget build(BuildContext context) {
    checkConnectitivy();

    final routeArgs =
        ModalRoute.of(context)!.settings.arguments as Map<String, Object>;

    bool isEditable = routeArgs['isEditable'] as bool;
    Ad? editableAd;
    if (isEditable) {
      editableAd = routeArgs['ad'] as Ad;
      if (editableAd != null && !hasLoaded) {
        imgPaths = editableAd.imagePaths;
        yearCtrl.text = editableAd.year.toString();
        kmCtrl.text = editableAd.km.toString();
        ccCtrl.text = editableAd.cc.toString();
        colorCtrl.text = editableAd.colour.toString();
        adTitle.text = editableAd.title.toString();
        adDescription.text = editableAd.desc.toString();
        askPrice.text = editableAd.askPrice.toString();
        adDuration.text = editableAd.endDate
            .toDate()
            .difference(editableAd.startDate.toDate())
            .inDays
            .toString();
        editableAd.imagePaths.forEach((element) {
          imgs.add(Image(
              image: NetworkImage(element),
              fit: BoxFit.fill,
              width: double.infinity));
        });
      }
      hasLoaded = true;
    }
    var pages = [
      ManufacturePage(
        ad: editableAd,
        manufacturerDropdownCtrl: manufacturerDropdownCtrl,
        modelDropdownCtrl: modelDropdownCtrl,
        transmissionCtrl: transmissionCtrl,
        manufacturerOtherCtrl: manufacturerOtherCtrl,
        modelOtherCtrl: modelOtherCtrl,
        onChanged: setCanGoNext,
      ),
      CarPage(
        imgPaths: !isEditable ? null : editableAd!.imagePaths,
        imgs: imgs,
        imgsXFile: imgsXfiles,
        yearCtrl: yearCtrl,
        kmCtrl: kmCtrl,
        ccCtrl: ccCtrl,
        colorCtrl: colorCtrl,
        noImages: noImages,
        onChange: setCanGoNext,
      ),
      AdDetailsPage(
        adDescription: adDescription,
        adDuration: adDuration,
        adTitle: adTitle,
        askPrice: askPrice,
        onChange: setCanGoNext,
      )
    ];
    // if (editableAd != null) {
    //   setState(() {
    //     nextEnabled = true;
    //   });
    // }

    return internetConnection
        ? (MyScaffold(
            hasLeading: false,
            body: Column(
              children: [
                Expanded(
                  child: PageView(
                    onPageChanged: (value) => setState(() {
                      index = value;
                    }),
                    controller: _pageController,
                    children: pages,
                  ),
                ),
                Container(
                  color: Colors.black,
                  height: 50,
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: (() => changePage(index - 1)),
                          icon: Icon(
                            Icons.arrow_back,
                            color: index == 0 ? Colors.black : Colors.white,
                            size: 30,
                          )),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: pages.map((e) {
                            int current = pages.indexOf(e);
                            return Container(
                              width: 10,
                              height: 8,
                              margin: EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: index == current
                                    ? Color.fromRGBO(255, 255, 255, 0.9)
                                    : Color.fromRGBO(255, 255, 255, 0.4),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      index == pages.length - 1
                          ? TextButton(
                              onPressed: () {
                                showBottomSheet(isEditable, editableAd);
                              },
                              child: Text(
                                "Next",
                                style: TextStyle(
                                    color: nextEnabled
                                        ? Colors.white
                                        : Colors.grey),
                              ))
                          : IconButton(
                              onPressed: (() => changePage(index + 1)),
                              icon: Icon(
                                Icons.arrow_forward,
                                color: nextEnabled ? Colors.white : Colors.grey,
                                size: 30,
                              )),
                    ],
                  ),
                )
              ],
            ),
          ))
        : (noInternet());
  }

  void changePage(int idx) {
    if (idx < 0) return;
    if (idx > index && !nextEnabled) return;
    _pageController.animateToPage(idx,
        duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
    setState(() {
      index = idx;
    });
    setCanGoNext();
  }

  List<Widget> getAdDetailsEntry(String title, String data,
      {bool hasDivider = true}) {
    return [
      Row(
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
          Spacer(),
          Text(data, style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
      if (hasDivider)
        Divider(
          height: 10,
          thickness: 1,
        ),
    ];
  }

  setCanGoNext() {
    bool canGoNext = true;
    if (index == 0) {
      canGoNext &= manufacturerDropdownCtrl.text.isNotEmpty;
      canGoNext &= (manufacturerDropdownCtrl.text == "other...")
          ? manufacturerOtherCtrl.text.isNotEmpty
          : true;
      canGoNext &= modelDropdownCtrl.text.isNotEmpty;
      canGoNext &= (modelDropdownCtrl.text == "other...")
          ? modelOtherCtrl.text.isNotEmpty
          : true;
      canGoNext &= transmissionCtrl.text.isNotEmpty;
    } else if (index == 1) {
      canGoNext &= yearCtrl.text.isNotEmpty;
      canGoNext &= colorCtrl.text.isNotEmpty;
      canGoNext &= kmCtrl.text.isNotEmpty;
      canGoNext &= ccCtrl.text.isNotEmpty;
    } else {
      canGoNext &= adTitle.text.isNotEmpty;
      canGoNext &= adDescription.text.isNotEmpty;
      canGoNext &= adDuration.text.isNotEmpty;
      canGoNext &= askPrice.text.isNotEmpty;
    }
    setState(() {
      nextEnabled = canGoNext;
    });
    ;
  }

  void showBottomSheet(isEditable, editableAdBridge) {
    String manufacturer = (manufacturerDropdownCtrl.text == "other...")
        ? manufacturerOtherCtrl.text
        : manufacturerDropdownCtrl.text;
    String model = (modelDropdownCtrl.text == "other...")
        ? modelOtherCtrl.text
        : modelDropdownCtrl.text;
    if (!nextEnabled) return;
    showModalBottomSheet<dynamic>(
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext bc) {
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
                      child: Text('Your Ad details',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontSize: 20)),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Car Photos',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        UploadedPhotosRow(imgs: imgs, removeCallback: null),
                        ...getAdDetailsEntry('Title', adTitle.text),
                        ...getAdDetailsEntry('Manufacturer', manufacturer),
                        ...getAdDetailsEntry('Model', model),
                        ...getAdDetailsEntry('Year', yearCtrl.text),
                        ...getAdDetailsEntry('Car Km', kmCtrl.text),
                        ...getAdDetailsEntry('Car CC', ccCtrl.text),
                        ...getAdDetailsEntry('Car color', colorCtrl.text),
                        ...getAdDetailsEntry('Ask price', askPrice.text),
                        ...getAdDetailsEntry('Ad duration', adDuration.text,
                            hasDivider: false),
                      ],
                    ),
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        submit(isEditable, editableAdBridge);
                      },
                      child: Text('Submit'),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.green[400]!),
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]);
        });
  }

  void submit(isEditable, editableAd) async {
    showLoading();
    if (!isEditable) {
      String typeId = await createType();
      if (typeId == 'error') return;
      String carId = await createCar(typeId);
      if (carId == 'error') return;
      String adId = await createAd(carId);
      if (adId == 'error') return;
      await addAdToUser(adId);
    } else
      await updateAd(editableAd);
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pop(context);
  }

  updateAd(Ad editableAd) async {
    print("start updating");
    await FirebaseFirestore.instance
        .collection('types')
        .doc(editableAd.typeId)
        .update({
      'manufacturer': manufacturerDropdownCtrl.text == "other..."
          ? manufacturerOtherCtrl.text
          : manufacturerDropdownCtrl.text,
      'model': modelDropdownCtrl.text == "other..."
          ? modelOtherCtrl.text
          : modelDropdownCtrl.text,
    });
    print("type updated");
    List<String> images = await getImagesUrl(imgsXfiles);
    print("images retrieved");
    await FirebaseFirestore.instance
        .collection('cars')
        .doc(editableAd.carId)
        .update({
      'km': int.parse(kmCtrl.text),
      'cc': int.parse(ccCtrl.text),
      'year': int.parse(yearCtrl.text),
      'color': colorCtrl.text,
      'photos': images
    });
    print("car updated");
    await FirebaseFirestore.instance
        .collection('ads')
        .doc(editableAd.adId)
        .update({
      'title': adTitle.text,
      'desc': adDescription.text,
      'ask_price': int.parse(askPrice.text),
      'auto': transmissionCtrl.text == "Automatic" ? 0 : 1,
      'end_date': editableAd.startDate
          .toDate()
          .add(Duration(days: int.parse(adDuration.text)))
    });
    print("finish updating");
  }

  Future<String> createType() async {
    String res = '';
    String manufacturer = (manufacturerDropdownCtrl.text == "other...")
        ? manufacturerOtherCtrl.text
        : manufacturerDropdownCtrl.text;
    String model = (modelDropdownCtrl.text == "other...")
        ? modelOtherCtrl.text
        : modelDropdownCtrl.text;
    CollectionReference types = FirebaseFirestore.instance.collection('types');
    await types
        .where('manufacturer', isEqualTo: manufacturer)
        .where('model', isEqualTo: model)
        .get()
        .then((value) async {
      if (value.docs.length == 0) {
        await types.add({
          'manufacturer': manufacturer,
          'model': model,
        }).then((value) {
          res = value.id;
        }).catchError((err) {
          showErrorDialog(err);
          res = 'error';
        });
      } else {
        res = value.docs.first.id;
      }
    }).catchError((err) {
      showErrorDialog(err);
      res = 'error';
    });
    return res;
  }

  Future<String> createCar(String typeId) async {
    String res = '';
    CollectionReference cars = FirebaseFirestore.instance.collection('cars');
    List<String> images = await getImagesUrl(imgsXfiles);
    await cars.add({
      'color': colorCtrl.text,
      'km': int.parse(kmCtrl.text),
      'type_id': typeId,
      'cc': int.parse(ccCtrl.text),
      'year': int.parse(yearCtrl.text),
      'photos': images
    }).then((value) {
      res = value.id;
    }).catchError((err) {
      showErrorDialog(err);
      res = 'error';
    }).catchError((err) {
      showErrorDialog(err);
      res = 'error';
    });
    return res;
  }

  Future<String> createAd(String carId) async {
    String res = '';
    String uid = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference ads = FirebaseFirestore.instance.collection('ads');
    await ads.add({
      'ask_price': int.parse(askPrice.text),
      'title': adTitle.text,
      'desc': adDescription.text,
      'car_id': carId,
      'highest_bid': 0,
      'auto': transmissionCtrl.text == "Automatic" ? 0 : 1, //NEEDS FIX
      'highest_bidder_id': "",

      'end_date':
          DateTime.now().add(Duration(days: int.parse(adDuration.text))),
      'owner_id': uid,
      'start_date': DateTime.now(),
    }).then((value) {
      res = value.id;
    }).catchError((err) {
      showErrorDialog(err);
      res = 'error';
    }).catchError((err) {
      showErrorDialog(err);
      res = 'error';
    });
    return res;
  }

  addAdToUser(String adId) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    await users.doc(uid).get().then((value) async {
      final data = value.data() as Map<String, dynamic>;
      List<dynamic> myAds = data['myAds'] as List<dynamic>;
      myAds.add(adId);
      await users.doc(uid).update({'myAds': myAds});
    });
  }

  showErrorDialog(err) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text("Error Occured"),
            content: Text(err.toString()),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"))
            ],
          );
        });
  }

  getImagesUrl(List<XFile> imgs) async {
    List<String> res = [];
    final storageRef = FirebaseStorage.instance.ref();
    for (var img in imgs) {
      File imageFile = File(img.path);
      final imageRef = storageRef.child('car_images/${imgs[0].name}');
      var uploadTask = imageRef.putFile(imageFile);

      final snapshot = await uploadTask.then((value) async {
        await value.ref.getDownloadURL().then((value) {
          res.add(value);
        });
      });
    }
    return imgPaths + res;
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
}
