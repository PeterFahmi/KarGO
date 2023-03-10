import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kargo/components/no_Internet.dart';
import 'dart:convert';
import '../components/errorBar.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool internetConnection = true;
  Country _selectedCountry = Country(
      code: '1',
      name: 'United States',
      flagUrl: 'https://flagcdn.com/w320/us.png');
  List<Country> _countries = [];
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var passwordController1 = TextEditingController();
  var usernameController = TextEditingController();
  var phoneNumberController = TextEditingController();
  final authenticationInstance = FirebaseAuth.instance;
  var authenticationMode = 0;
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
  void initState() {
    super.initState();
    checkConnectitivy();
    if (internetConnection) {
      _fetchCountries();
    }
  }

  void toggleAuthMode() {
    if (authenticationMode == 0) {
      setState(() {
        authenticationMode = 1;
      });
    } else {
      setState(() {
        authenticationMode = 0;
      });
    }
  }

  void _fetchCountries() async {
    try {
      final response =
          await http.get(Uri.parse("https://restcountries.com/v2/all"));
      if (response.statusCode == 200) {
        setState(() {
          _countries = (json.decode(response.body) as List)
              .map((data) => Country.fromJson(data))
              .toList();
        });
      }
    } on Exception catch (error) {
      setState(() {
        internetConnection = false;
      });
    }
  }

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    checkConnectitivy();
    return internetConnection
        ? (Scaffold(
            body: SingleChildScrollView(
            child: Container(
              padding:
                  EdgeInsets.only(bottom: authenticationMode == 0 ? 750 : 600),
              decoration: BoxDecoration(
                  image: DecorationImage(
                image: NetworkImage(
                    'https://i.pinimg.com/736x/2b/25/90/2b259027d014fd2234af64d3e626bb39--bubbles-green.jpg'),
                fit: BoxFit.fitWidth,
              )),
              child: Center(
                child: Container(
                  width: double.infinity,
                  height: authenticationMode == 1 ? 550 : 400,
                  margin: EdgeInsets.only(top: 200, left: 10, right: 10),
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Form(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          children: [
                            Center(
                              child: Image(
                                image: AssetImage('assets/images/logo.png'),
                                width: 150,
                                height: 100,
                              ),
                            ),
                            SizedBox(height: 10),
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(labelText: "Email"),
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter a valid email address';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(height: 10),
                            Expanded(
                              child: TextFormField(
                                decoration:
                                    InputDecoration(labelText: "Password"),
                                controller: passwordController,
                                obscureText: true,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter a password';
                                  }
                                  if (value.length < 6 &&
                                      authenticationMode == 1)
                                    return 'Password is too short';
                                  return null;
                                },
                              ),
                            ),
                            if (authenticationMode == 0)
                              TextButton(
                                onPressed: () async {
                                  // 1. Display a form or a dialog to collect the email address of the user whose password needs to be reset
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      String _email = "";
                                      return AlertDialog(
                                        title: Text("Reset Password"),
                                        content: Form(
                                          key: _formKey,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              TextFormField(
                                                decoration: InputDecoration(
                                                    labelText: "Email"),
                                                validator: (value) {
                                                  if (value!.isEmpty) {
                                                    return "Please enter an email";
                                                  }
                                                  return null;
                                                },
                                                onSaved: (value) =>
                                                    _email = value!,
                                              ),
                                            ],
                                          ),
                                        ),
                                        actions: [
                                          ElevatedButton(
                                            style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        Colors.black)),
                                            child: Text("Cancel"),
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                          ),
                                          ElevatedButton(
                                            style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        Colors.black)),
                                            child: Text("Send"),
                                            onPressed: () async {
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                _formKey.currentState!.save();
                                                try {
                                                  await FirebaseAuth.instance
                                                      .sendPasswordResetEmail(
                                                          email: _email);
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                        content: Text(
                                                            "Password reset email sent")),
                                                  );
                                                } catch (e) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                        content:
                                                            Text("Error: $e")),
                                                  );
                                                }
                                                Navigator.of(context).pop();
                                              }
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: Text("Forgot Password",
                                    style: TextStyle(color: Colors.black)),
                              ),
                            if (authenticationMode == 1) ...[
                              SizedBox(height: 10),
                              Expanded(
                                child: TextFormField(
                                  decoration: InputDecoration(
                                      labelText: "Reenter Password"),
                                  controller: passwordController1,
                                  obscureText: true,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please reenter the password';
                                    }
                                    if (value != passwordController.text.trim())
                                      return 'Password does not match';
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(height: 10),
                              Expanded(
                                child: TextFormField(
                                  decoration:
                                      InputDecoration(labelText: "Name"),
                                  controller: usernameController,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please enter your Name';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(height: 10),
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                    maxWidth: double.infinity, minHeight: 48),
                                child: Row(
                                  children: [
                                    Image.network(
                                      _selectedCountry.flagUrl,
                                      width: 32,
                                      height: 32,
                                    ),
                                    SizedBox(width: 8),
                                    Text(" +" + _selectedCountry.code,
                                        style: TextStyle(fontSize: 15)),
                                    PopupMenuButton(
                                      onSelected: (Country country) {
                                        setState(() {
                                          _selectedCountry = country;
                                        });
                                      },
                                      itemBuilder: (BuildContext context) {
                                        return _countries
                                            .map((Country country) {
                                          return PopupMenuItem(
                                            value: country,
                                            child: Text(country.name),
                                          );
                                        }).toList();
                                      },
                                    ),
                                    SizedBox(width: 5),
                                    Expanded(
                                      child: TextField(
                                        decoration: InputDecoration(
                                            labelText: "Phone Number"),
                                        controller: phoneNumberController,
                                        keyboardType: TextInputType.phone,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            SizedBox(height: 8),
                            TextButton(
                                onPressed: () {
                                  loginORsignup();
                                },
                                child: authenticationMode == 1
                                    ? (Text('     Sign Up     ',
                                        style: TextStyle(
                                            color: Colors.white,
                                            //fontWeight: FontWeight.bold,
                                            fontSize: 15)))
                                    : (Text('      Login      ',
                                        style: TextStyle(
                                            color: Colors.white,
                                            //fontWeight: FontWeight.bold,
                                            fontSize: 15))),
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.black),
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                            side: BorderSide(
                                                color: Colors.black))))),
                            SizedBox(height: 5),
                            TextButton(
                              onPressed: () {
                                toggleAuthMode();
                              },
                              child: (authenticationMode == 1)
                                  ? Text("Login instead",
                                      style: TextStyle(color: Colors.black))
                                  : Text("Sign up instead",
                                      style: TextStyle(color: Colors.black)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )))
        : (noInternet());
  }

  void loginORsignup() async {
    var email = emailController.text.trim();
    var password = passwordController.text.trim();
    var username = usernameController.text.trim();
    var phoneNumber =
        "+" + _selectedCountry.code + " " + phoneNumberController.text.trim();
    UserCredential authResult;
    try {
      if (authenticationMode == 1) // sign up
      {
        authResult =
            await authenticationInstance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        await FirebaseFirestore.instance
            .collection('users')
            .doc(authResult.user!.uid)
            .set({
          'name': username,
          'email': email,
          'phoneNumber': phoneNumber,
          'photoURL':
              'https://firebasestorage.googleapis.com/v0/b/mobileapp-18909.appspot.com/o/profile_pictures%2Fimage_picker6613525771089450064.jpg?alt=media&token=b89b540f-341f-4f04-81ed-c7d0be17e960',
          'favAds': [],
          'myAds': [],
          'myBids': [],
          'chats': [],
        });
      } else //log in
      {
        authResult = await authenticationInstance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
    } catch (err) {
      final error = err.toString();
// ScaffoldMessenger.of(context).showSnackBar(

//    const SnackBar(
//      content: CustomSnackBarContent(
//        errorText:
//            "That Email Address is already in use! Please try with a different one.",
//      ),

//      behavior: SnackBarBehavior. floating,
//      backgroundColor: Colors. transparent,
//      elevation: 0,
//    )
// );

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Container(
            padding: const EdgeInsets.all(16),
            height: 90,
            decoration: const BoxDecoration(
              color: Color(0xFFC72C41),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("Oh snap!",
                  style: TextStyle(fontSize: 18, color: Colors.white)),
              Text(
                error.split("]")[1],
                style: TextStyle(color: Colors.white, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            ])),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ));

      // showDialog(
      //               context: context,
      //               builder: (ctx) => AlertDialog(
      //                 title: const Text("Error"),
      //                 content:  Text(error),
      //                 actions: <Widget>[
      //                   TextButton(
      //                     onPressed: () {
      //                       Navigator.of(ctx).pop();
      //                     },
      //                     child: Container(
      //                       color: Colors.green,
      //                       padding: const EdgeInsets.all(14),
      //                       child: const Text("okay"),
      //                     ),
      //                   ),
      //                 ],
      //               ),
      //             );
      print(err.toString());
    }
  }
}

Future<bool> sendPasswordResetRequest(String email) async {
  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    return true;
  } catch (error) {
    print(error);
    return false;
  }
}

class Country {
  final String code;
  final String name;
  final String flagUrl;

  Country({required this.code, required this.name, required this.flagUrl});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      code: json['callingCodes'][0],
      name: json['name'],
      flagUrl: json['flags']['png'],
    );
  }
}
