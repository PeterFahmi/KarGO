import 'dart:io';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kargo/components/my_scaffold.dart';
import 'package:kargo/components/my_textfield.dart';

import 'package:image_picker/image_picker.dart';
import '../components/CarouselWithDots.dart';

class CreateAdScreen extends StatefulWidget {
  @override
  State<CreateAdScreen> createState() => _CreateAdScreenState();
}

class _CreateAdScreenState extends State<CreateAdScreen> {
  static const _subheader = TextStyle(fontWeight: FontWeight.w600);
  static const _header = TextStyle(fontSize: 20, fontWeight: FontWeight.w800);
  static const list = ["audi", "honda", "balabizo"];
  static const carList = ["audi", "honda", "balabizo"];
  static const modelList = ["civic", "corrola", "balabizo"];
  static const imgUrls = [
    'https://www.hdcarwallpapers.com/download/abt_sportsline_audi_tt-2880x1800.jpg',
    'https://th.bing.com/th/id/OIP.zpu1nHs3RCyeRXikR-nFGgHaFj?pid=ImgDet&w=1600&h=1200&rs=1'
  ];
  List<Image> imgs = imgUrls.map((e) => Image.network(e)).toList();
  bool noImages = false;

  final ImagePicker picker = ImagePicker();
  final manufacturerDropdownCtrl = TextEditingController(),
      modelDropdownCtrl = TextEditingController(),
      yearCtrl = TextEditingController(),
      kmCtrl = TextEditingController(),
      colorCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var addButton = Container(
        color: Colors.grey,
        margin: EdgeInsets.only(top: 10, right: 10, left: 5, bottom: 5),
        height: 50,
        width: 50,
        child: IconButton(
          icon: Icon(
            Icons.add,
            size: 30,
            color: Colors.white,
          ),
          onPressed: addImage,
        ));
    var carPart = [
      Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 0,
        color: Colors.white60,
        margin: EdgeInsets.all(10),
        child: Column(
          children: [
            CarouselWithDotsPage(
              imgList: getImgsToShow(),
              isURLList: false,
            ),
            Container(
              margin: EdgeInsets.all(10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                            width: 250,
                            height: 70,
                            child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: (imgs
                                    .map((e) => Stack(children: [
                                          Container(
                                              color: Colors.grey,
                                              margin: EdgeInsets.only(
                                                  top: 10,
                                                  right: 10,
                                                  left: 5,
                                                  bottom: 5),
                                              height: 50,
                                              width: 50,
                                              child: e),
                                          Positioned(
                                              right: 0,
                                              child: Container(
                                                margin: EdgeInsets.all(3.5),
                                                width: 20.0,
                                                height: 20.0,
                                                decoration: new BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: IconButton(
                                                    padding: EdgeInsets.all(0),
                                                    onPressed: () =>
                                                        removeFromList(e),
                                                    icon: Icon(
                                                      Icons.close,
                                                      size: 15,
                                                      color: Colors.black,
                                                    )),
                                              )),
                                        ]))
                                    .toList()))),
                        addButton
                      ],
                    ),
                  ]),
            ),
            SizedBox(height: 5),
          ],
        ),
      ),
      const Text('Car details', style: _header),
      const Divider(
        height: 30,
        thickness: 3,
      ),
      const Text('Car manufacturer', style: _subheader),
      CustomDropdown.search(
        hintText: 'Select manufacturer',
        items: carList,
        controller: manufacturerDropdownCtrl,
        excludeSelected: false,
      ),
      const Divider(height: 24),
      const Text('Car model', style: _subheader),
      CustomDropdown.search(
        hintText: 'Select model',
        items: modelList,
        controller: modelDropdownCtrl,
        excludeSelected: false,
      ),
      const Divider(height: 24),
      const Text('Car model year', style: _subheader),
      MyTextField(
        controller: yearCtrl,
        labelText: "Model year",
        keyboardType: TextInputType.number,
      ),
      const Divider(height: 24),
      const Text('Car km', style: _subheader),
      MyTextField(
        controller: kmCtrl,
        labelText: "Car km",
        keyboardType: TextInputType.number,
      ),
      const Divider(height: 24),
      const Text('Car color', style: _subheader),
      MyTextField(
        controller: colorCtrl,
        labelText: "Car color",
      ),
    ];

    return MyScaffold(
        hasLeading: false,
        body: Container(
          color: Colors.black12,
          child: ListView(
              padding: const EdgeInsets.all(16.0), children: [...carPart]),
        ));
  }

  List<Image> getImgsToShow() {
    print(imgs.length);
    if (imgs.length == 0) {
      List<Image> placeHolder = [];
      placeHolder.add(Image(
          image: AssetImage('assets/images/carPlaceHolder.jpg'),
          fit: BoxFit.fill,
          width: double.infinity));
      print(placeHolder);
      return [];
    }
    print(imgs);
    return imgs;
  }

  removeFromList(Image e) {
    setState(() {
      imgs.remove(e);
      if (imgs.length == 0) {
        noImages = true;
        imgs.add(Image(
            image: AssetImage('assets/images/carPlaceHolder.jpg'),
            fit: BoxFit.fill,
            width: double.infinity));
      }
    });
  }

  addImage() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: Text('Please choose media to select'),
            content: Container(
              height: MediaQuery.of(context).size.height / 6,
              child: Column(
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.black)),
                    //if user click this button, user can upload image from gallery
                    onPressed: () {
                      Navigator.pop(context);
                      getImage(ImageSource.gallery);
                    },
                    child: Row(
                      children: [
                        Icon(Icons.image),
                        Text('From Gallery'),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.black)),
                    //if user click this button. user can upload image from camera
                    onPressed: () {
                      Navigator.pop(context);
                      getImage(ImageSource.camera);
                    },
                    child: Row(
                      children: [
                        Icon(Icons.camera),
                        Text('From Camera'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future getImage(ImageSource media) async {
    XFile? img = await picker.pickImage(source: media);

//   copy the file to a new path
    if (img != null)
      setState(() {
        if (noImages) {
          imgs.removeAt(0);
          noImages = false;
        }
        ImageProvider image = FileImage(File(img!.path));
        imgs.add(Image(image: image, fit: BoxFit.fill, width: double.infinity));
      });
  }
}
