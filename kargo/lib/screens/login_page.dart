import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/errorBar.dart';
class LoginScreen extends StatefulWidget {
 @override
 _LoginScreenState createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
 var emailController = TextEditingController();
 var passwordController = TextEditingController();
 var usernameController = TextEditingController();
  var phoneNumberController = TextEditingController();
 final authenticationInstance = FirebaseAuth.instance;
 var authenticationMode = 0;

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
 
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
 }
 @override
 Widget build(BuildContext context) {


 return Scaffold(
 body: 
 Container(
 width: double.infinity,
 height: 480,
 margin: EdgeInsets.only(top: 60, left: 10, right: 10),
 child: Card(
 elevation: 5,
 shape: RoundedRectangleBorder(
 borderRadius: BorderRadius.circular(20),
 ),
 child: Padding(
 padding: const EdgeInsets.all(8.0),
 child: Column(
 children: [
 Center(
 child: Image(
                image: AssetImage('assets/images/logo.png'),
                width: 150,
                height: 100,
              )
 ),
 TextField(
 decoration: InputDecoration(labelText: "Email"),
 controller: emailController,
 keyboardType: TextInputType.emailAddress,
 ),
 TextField(
 decoration: InputDecoration(labelText: "Password"),
 controller: passwordController,
 obscureText: true,
 ),
 if (authenticationMode == 1)
 TextField(
 decoration: InputDecoration(labelText: "Username"),
 controller: usernameController,
  ),
   if (authenticationMode == 1)
 TextField(
 decoration: InputDecoration(labelText: "Phone Number"),
 controller: phoneNumberController,
  keyboardType: TextInputType.phone,
  ),
 ElevatedButton(style: ButtonStyle(
                      backgroundColor:MaterialStateProperty.all(Colors.black)),
 onPressed: () {
 loginORsignup();
 },
 child: (authenticationMode == 1)
 ? Text("Sign up")
 : Text("Login"),
 ),
 TextButton(
 onPressed: () {
 toggleAuthMode();
 },
 child: (authenticationMode == 1)
 ? Text("Login instead", style: TextStyle(color: Colors.black))
 : Text("Sign up instead", style: TextStyle(color: Colors.black)),
 ),
 ],
 ),
 ),
 ),
 ),
 );
 }
 void loginORsignup() async {

 var email = emailController.text.trim();
 var password = passwordController.text.trim();
 var username = usernameController.text.trim();
  var phoneNumber = phoneNumberController.text.trim();
 UserCredential authResult;
try {
 if (authenticationMode == 1) // sign up
 {
 
 authResult = await authenticationInstance.createUserWithEmailAndPassword(
 email: email,
 password: password,
 );
 await FirebaseFirestore.instance
 .collection('users')
 .doc(authResult.user!.uid)
 .set({
 'username': username,
 'email': email,
 'phoneNumber': phoneNumber,
'photoURL':""
 });

 }
 else //log in
 {authResult = await authenticationInstance.signInWithEmailAndPassword(
 email: email,
 password: password,
 );


 }
} catch (err) {
  final error =err.toString();
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

ScaffoldMessenger.of(context).showSnackBar(
  
    SnackBar(

          content: 
     
     Container(
padding: const EdgeInsets.all(16),
height: 90,
decoration: const BoxDecoration(
color: Color(0xFFC72C41),
borderRadius: BorderRadius.all(Radius. circular(20) ) ,
),child: Column(
crossAxisAlignment: CrossAxisAlignment. start,
children: [
const Text(
"Oh snap!",
style: TextStyle(fontSize: 18, color: Colors.white)),
 Text(error.split("]")[1]
,style: TextStyle(
color: Colors .white,
fontSize: 12),
maxLines: 2,
overflow: TextOverflow.ellipsis,
  )]))
     
     ,
     behavior: SnackBarBehavior. floating,
     backgroundColor: Colors. transparent,
     elevation: 0,
   )
);



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