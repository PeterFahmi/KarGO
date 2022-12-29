import 'dart:io';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kargo/components/my_scaffold.dart';
import 'package:kargo/components/my_textfield.dart';

import 'package:image_picker/image_picker.dart';
import 'package:kargo/components/uploaded_photos_row.dart';
import 'package:kargo/screens/pages/new_ad_car_page.dart';
import 'package:kargo/screens/pages/new_ad_details_page.dart';
import 'package:kargo/screens/pages/new_ad_manufacture_page.dart';
import '../components/CarouselWithDots.dart';

class CreateAdScreen extends StatefulWidget {
  @override
  State<CreateAdScreen> createState() => _CreateAdScreenState();
}

class _CreateAdScreenState extends State<CreateAdScreen> {
  //constants
  static const imgUrls = [
    'https://www.hdcarwallpapers.com/download/abt_sportsline_audi_tt-2880x1800.jpg',
    'https://th.bing.com/th/id/OIP.zpu1nHs3RCyeRXikR-nFGgHaFj?pid=ImgDet&w=1600&h=1200&rs=1'
  ];

  final PageController _pageController = PageController();
  int index = 0;

  //carpage
  List<Image> imgs = imgUrls.map((e) => Image.network(e)).toList();
  final yearCtrl = TextEditingController(),
      kmCtrl = TextEditingController(),
      colorCtrl = TextEditingController();

  bool noImages = false;

  @override
  Widget build(BuildContext context) {
    var pages = [
      ManufacturePage(),
      CarPage(
          imgs: imgs,
          yearCtrl: yearCtrl,
          kmCtrl: kmCtrl,
          colorCtrl: colorCtrl,
          noImages: noImages),
      AdDetailsPage()
    ];
    return MyScaffold(
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
                      color: Colors.white,
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
                        margin:
                            EdgeInsets.symmetric(vertical: 2, horizontal: 2),
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
                        onPressed: showBottomSheet,
                        child: Text(
                          "Next",
                          style: TextStyle(color: Colors.white),
                        ))
                    : IconButton(
                        onPressed: (() => changePage(index + 1)),
                        icon: Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 30,
                        )),
              ],
            ),
          )
        ],
      ),
    );
  }

  void changePage(int idx) {
    _pageController.animateToPage(idx,
        duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
    setState(() {
      index = idx;
    });
  }

  void showBottomSheet() {
    showModalBottomSheet<dynamic>(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext bc) {
          return Wrap(children: <Widget>[
            Container(
              child: Container(
                decoration: new BoxDecoration(
                    color: Colors.black,
                    borderRadius: new BorderRadius.only(
                        topLeft: const Radius.circular(25.0),
                        topRight: const Radius.circular(25.0))),
                child: Container(
                  child: Column(
                    children: [
                      UploadedPhotosRow(imgs: imgs, removeCallback: null)
                    ],
                  ),
                ),
              ),
            )
          ]);
        });
  }
}
