import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kargo/components/uploaded_photos_row.dart';

import '../../components/CarouselWithDots.dart';
import '../../components/my_textfield.dart';

class CarPage extends StatefulWidget {
  static const _subheader = TextStyle(fontWeight: FontWeight.w600);
  List<Image> imgs;
  List<XFile> imgsXFile;
  TextEditingController yearCtrl;
  TextEditingController kmCtrl;
  TextEditingController colorCtrl;
  bool noImages;
  VoidCallback onChange;
  CarPage(
      {required this.imgs,
      required this.colorCtrl,
      required this.kmCtrl,
      required this.yearCtrl,
      required this.noImages,
      required this.onChange,
      required this.imgsXFile});
  @override
  State<CarPage> createState() => _CarPageState();
}

class _CarPageState extends State<CarPage> {
  final ImagePicker picker = ImagePicker();
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
    return Column(children: [
      Container(
        height: 55,
        padding: EdgeInsets.all(5),
        width: double.infinity,
        color: Color.fromRGBO(0, 0, 0, 0.2),
        child: const Text(
          'Car details',
          style: TextStyle(
              color: Colors.white, fontSize: 40, fontWeight: FontWeight.w700),
        ),
      ),
      Expanded(
        child: ListView(
          padding: EdgeInsets.all(15),
          children: [
            const Text('Upload car photos', style: CarPage._subheader),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              elevation: 0,
              color: Colors.white60,
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
                              UploadedPhotosRow(
                                  imgs: widget.imgs,
                                  removeCallback: (e) {
                                    removeFromList(e);
                                  }),
                              addButton
                            ],
                          ),
                        ]),
                  ),
                  SizedBox(height: 5),
                ],
              ),
            ),
            const Divider(height: 10),
            const Text('Car model year', style: CarPage._subheader),
            MyTextField(
              controller: widget.yearCtrl,
              labelText: "Model year",
              keyboardType: TextInputType.number,
              onSubmitted: widget.onChange,
            ),
            const Divider(height: 24),
            const Text('Car km', style: CarPage._subheader),
            MyTextField(
              controller: widget.kmCtrl,
              labelText: "Car km",
              keyboardType: TextInputType.number,
              onSubmitted: widget.onChange,
            ),
            const Divider(height: 24),
            const Text('Car color', style: CarPage._subheader),
            MyTextField(
              controller: widget.colorCtrl,
              labelText: "Car color",
              onSubmitted: widget.onChange,
            ),
          ],
        ),
      ),
    ]);
  }

  List<Image> getImgsToShow() {
    print(widget.imgs.length);
    if (widget.imgs.length == 0) {
      List<Image> placeHolder = [];
      placeHolder.add(Image(
          image: AssetImage('assets/images/carPlaceHolder.jpg'),
          fit: BoxFit.fill,
          width: double.infinity));
      print(placeHolder);
      return [];
    }
    return widget.imgs;
  }

  removeFromList(Image e) {
    setState(() {
      int idx = widget.imgs.indexOf(e);
      widget.imgs.removeAt(idx);
      if (!widget.noImages) widget.imgsXFile.removeAt(idx);
      if (widget.imgs.length == 0) {
        widget.noImages = true;
        widget.imgs.add(Image(
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
        if (widget.noImages) {
          widget.imgs.removeAt(0);
          widget.noImages = false;
        }
        ImageProvider image = FileImage(File(img.path));
        widget.imgs
            .add(Image(image: image, fit: BoxFit.fill, width: double.infinity));
        widget.imgsXFile.add(img);
      });
  }
}
