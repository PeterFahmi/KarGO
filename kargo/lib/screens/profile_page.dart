import 'package:flutter/material.dart';
import 'package:kargo/models/user.dart';
import '../components/profile_component.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditable = false;
  editProfile() {
    setState(() {
      isEditable = !isEditable;
    });
  }

  late TextEditingController nameController;

  @override
  Widget build(BuildContext context) {
    final routeArgs =
        ModalRoute.of(context)!.settings.arguments as Map<String, User>;

    final curUser = routeArgs['user'];
    nameController = TextEditingController(text: curUser!.name);
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Colors.black,
        ),
        actions: [
          isEditable
              ? TextButton(
                  onPressed: () {
                    editProfile();
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
          const SizedBox(height: 34),
          ProfileComponent(
            imagePath: curUser!.imagePath,
            onClicked: () {
              editProfile();
            },
            isEditable: isEditable,
          ),
          const SizedBox(height: 24),
          buildName(curUser),
        ],
      ),
    );
  }

  Widget buildName(User user) => Column(
        children: [
          isEditable
              ? buildTextField("Full Name", 10)
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

  Widget buildTextField(label, double inset) {
    return Container(
      padding: EdgeInsets.all(inset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
