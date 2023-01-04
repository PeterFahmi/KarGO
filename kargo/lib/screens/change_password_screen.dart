import 'package:flutter/material.dart';
import 'package:kargo/components/no_Internet.dart';
import '../components/my_text_field.dart';
import '../models/user.dart' as UserModel;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class UpdatePasswordScreen extends StatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  bool allFilled = false;
  TextEditingController curPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool wrongPass = false;
  bool passMismatch = false;
  bool passChanged = false;
  bool loading = false;
  bool internetConnection = true;
  void onChanged() {
    if (curPasswordController.text == "" ||
        newPasswordController.text == "" ||
        confirmPasswordController.text == "") {
      setState(() {
        allFilled = false;
      });
    } else {
      setState(() {
        allFilled = true;
      });
    }
  }

  void updatePassStatus(wrong, mis, succ, prog) {
    setState(() {
      wrongPass = wrong;
      passMismatch = mis;
      passChanged = succ;
      loading = prog;
    });
  }

  void updatePassword() async {
    updatePassStatus(false, false, false, true);
    User user = FirebaseAuth.instance.currentUser!;
    AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!, password: curPasswordController.text);
    user.reauthenticateWithCredential(credential).then((res) {
      user.updatePassword(newPasswordController.text).then((res) {
        updatePassStatus(false, false, true, false);
      }).catchError((err) {
        updatePassStatus(false, true, false, false);
      });
    }).catchError((err) {
      updatePassStatus(true, false, false, false);
    });
  }

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
  Widget build(BuildContext context) {
    checkConnectitivy();
    final routeArgs =
        ModalRoute.of(context)!.settings.arguments as Map<String, Object>;

    final curUser = routeArgs['user'] as UserModel.User;
    return internetConnection
        ? (Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                "Update Password",
                style: TextStyle(color: Colors.black, fontSize: 15),
              ),
              leading: BackButton(
                color: Colors.black,
              ),
              actions: [
                allFilled
                    ? TextButton(
                        onPressed: updatePassword,
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
                MyTextField(
                  inset: 10,
                  label: "Current password",
                  controller: curPasswordController,
                  obscureText: true,
                  onChanged: onChanged,
                ),
                if (wrongPass)
                  Row(
                    children: [
                      SizedBox(
                        width: 15,
                      ),
                      Text(
                        "Password is incorrect",
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                MyTextField(
                  inset: 10,
                  label: "New password",
                  controller: newPasswordController,
                  onChanged: onChanged,
                  obscureText: true,
                ),
                MyTextField(
                  inset: 10,
                  label: "Confirm password",
                  controller: confirmPasswordController,
                  onChanged: onChanged,
                  obscureText: true,
                ),
                if (passMismatch)
                  Row(
                    children: [
                      SizedBox(
                        width: 15,
                      ),
                      Text(
                        "Password does not match",
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                if (passChanged)
                  Column(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 60,
                        color: Colors.green,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Password has been changed successfully",
                        style: TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                SizedBox(height: 30),
                if (loading)
                  Center(child: Container(child: CircularProgressIndicator()))
              ],
            )))
        : (noInternet());
  }
}
