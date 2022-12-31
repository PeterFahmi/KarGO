import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kargo/models/user.dart' as UserModel;
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
          Padding(
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
          ),
          tabIndex == 2
              ? getSettingsList(curUser, context)
              : tabIndex == 1
                  ? Center(
                      child: Text(
                        "No Bids",
                        style: TextStyle(color: Colors.black),
                      ),
                    )
                  : Center(
                      child: Text(
                        "No Ads",
                        style: TextStyle(color: Colors.black),
                      ),
                    )
          // myExpansionTile(
          //   myTitle: "Settings",
          //   myIcon: Icons.settings,
          //   children: [
          //     TextButton(
          //         onPressed: () {
          //           Navigator.of(context).pushNamed('/update_password_screen',
          //               arguments: {'user': curUser});
          //         },
          //         child: Text(
          //           "Change Password",
          //           style: TextStyle(color: Colors.black, fontSize: 17),
          //         ))
          //   ],
          // ),
          // myExpansionTile(
          //     myTitle: "My Ads",
          //     myIcon: Icons.ad_units,
          //     children: childrenList.map((e) {
          //       return getListTile(e);
          //     }).toList()),
          // myExpansionTile(
          //     myTitle: "My Bids",
          //     myIcon: Icons.monetization_on_outlined,
          //     children: childrenList.map((e) {
          //       return getListTile(e);
          //     }).toList()),
          // const SizedBox(height: 30),
          // TextButton(
          //   style: ButtonStyle(
          //     foregroundColor: MaterialStateProperty.all<Color>(Colors.red),
          //   ),
          //   onPressed: () {
          //     FirebaseAuth.instance.signOut();
          //   },
          //   child: Text('Log out'),
          // )
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
          onPressed: (() {}),
          child: Text(
            "Log out",
            style: TextStyle(color: Colors.red),
          ))
    ]),
  );
}

Widget getListTile(elem) {
  File image = File('./assets/images/default.png');
  return ListTile(
    title: Text(elem),
    leading: CircleAvatar(backgroundImage: FileImage(image)),
    subtitle: Text('subtitle'),
    trailing: IconButton(
      icon: Icon(Icons.delete),
      onPressed: () {},
    ),
  );
}
