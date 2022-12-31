import 'package:flutter/material.dart';
import '../components/my_text_field.dart';
import '../models/user.dart' as UserModel;

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

  @override
  Widget build(BuildContext context) {
    final routeArgs =
        ModalRoute.of(context)!.settings.arguments as Map<String, Object>;

    final curUser = routeArgs['user'] as UserModel.User;
    return Scaffold(
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
                    onPressed: () async {},
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
          ],
        ));
  }
}
