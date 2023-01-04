import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kargo/screens/ad_screen2.dart';
import 'package:kargo/screens/chat_list_screen.dart';
import 'package:kargo/screens/chat_screen.dart';
import 'package:kargo/screens/create_ad_screen.dart';
import 'package:kargo/screens/home_page.dart';
import 'package:kargo/screens/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kargo/screens/loading_screen.dart';
import 'package:kargo/screens/login_page.dart';
import './screens/change_password_screen.dart';

void main() {
  initializeDateFormatting().then((_) {
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
  bool internetConnection = true;
  bool _error = false;

  // This widget is the root of your application.
  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
      });
    } catch (e) {
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
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(primaryColor: Colors.black),
      routes: {
        '/': (ctx) => getLandingScreen(),
        '/Chats': (context) => ChatListScreen(),
        '/ChatDetail': (context) => ChatScreen(),
        '/profile_page': (ctx) => ProfilePage(),
        '/update_password_screen': (ctx) => UpdatePasswordScreen(),
        '/create_ad': (context) => CreateAdScreen(),
        '/ad': (ctx) => AdScreen(),
      },
    );
  }

  getLandingScreen() {
    return _initialized != true
        ? LoadingScreen()
        : StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (ctx, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return LoadingScreen();
              }
              if (userSnapshot.hasData && internetConnection) {
                return HomePage();
              } else if (internetConnection)
                return LoginScreen();
              else {
                return Text("No Internet!");
              }
            });
  }
}
