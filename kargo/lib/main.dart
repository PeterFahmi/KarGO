import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kargo/screens/chat_list_screen.dart';
import 'package:kargo/screens/chat_screen.dart';
import 'package:kargo/screens/chat_screen.dart';
import 'package:kargo/screens/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kargo/screens/loading_screen.dart';
import 'package:kargo/screens/login_page.dart';
void main() {
  initializeDateFormatting()
  .then((_){
    runApp(const MyApp());
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _initialized = false;
 bool _error = false;
  // This widget is the root of your application.
   void initializeFlutterFire() async {
 try {
 // Wait for Firebase to initialize and set `_initialized` state to true
 await Firebase.initializeApp();
 setState(() {
 _initialized = true;
 });
 } catch(e) {
 // Set `_error` state to true if Firebase initialization fails
 setState(() {
 _error = true;
 });
 }
 }
 @override
 void initState() {
 initializeFlutterFire();
 super.initState();
 }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Colors.black
      ),
 home: _initialized!=true
 ? LoadingScreen()
 : StreamBuilder(stream: FirebaseAuth.instance.authStateChanges(),
 builder: (ctx, userSnapshot) {
 if (userSnapshot.connectionState == ConnectionState.waiting) {

 return LoadingScreen();
 }
 if (userSnapshot.hasData) {

 return HomePage();
 }
 return LoginScreen();


 })
      routes: {
        '/': (ctx) => HomePage(),
        '/Chats': (context) => ChatListScreen(),
        '/ChatDetail':(context) => ChatScreen()
      },
    );
  }
}
