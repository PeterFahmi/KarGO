import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ProfileComponent extends StatefulWidget {
  String imagePath;
  VoidCallback editProfileCallBack;
  Function setUploadedImage;
  bool isEditable;

  ProfileComponent({
    Key? key,
    required this.imagePath,
    required this.editProfileCallBack,
    required this.setUploadedImage,
    required this.isEditable,
  }) : super(key: key);

  @override
  State<ProfileComponent> createState() => _ProfileComponentState();
}

class _ProfileComponentState extends State<ProfileComponent> {
  XFile? uploadedImage;

  final ImagePicker picker = ImagePicker();

  //we can upload image from camera or from gallery based on parameter
  Future getImage(ImageSource media) async {
    XFile? img = await picker.pickImage(source: media);
    if (img == null) {
      return;
    }
    widget.setUploadedImage(img);

    setState(() {
      uploadedImage = img;
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = Colors.black;
    return Center(
      child: Stack(children: [
        getProfilePic(uploadedImage == null
            ? null
            : FileImage(File(uploadedImage!.path))),
        Positioned(
          bottom: 0,
          right: 4,
          child: getEditIcon(color),
        )
      ]),
    );
  }

  getProfilePic(newImage) {
    final image = NetworkImage(widget.imagePath);

    return ClipOval(
      child: Material(
        color: Colors.transparent,
        child: Ink.image(
          image: uploadedImage == null ? image : newImage,
          colorFilter: new ColorFilter.mode(
              Colors.black.withOpacity(widget.isEditable ? 0.6 : 1),
              BlendMode.dstATop),
          fit: BoxFit.cover,
          width: 128,
          height: 128,
        ),
      ),
    );
  }

  getEditIcon(color) {
    return widget.isEditable
        ? getCircle(
            4,
            Colors.white,
            GestureDetector(
              child: Icon(
                Icons.camera_enhance,
                color: Colors.black,
                size: 35,
              ),
              onTap: uploadPhoto,
            ))
        : getCircle(
            3,
            Colors.white,
            getCircle(
                8,
                color,
                GestureDetector(
                  onTap: widget.editProfileCallBack,
                  child: Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 20,
                  ),
                )));
  }

  getCircle(double insets, color, child) {
    return ClipOval(
      child: Container(
        padding: EdgeInsets.all(insets),
        color: color,
        child: child,
      ),
    );
  }

  void uploadPhoto() {
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
}
