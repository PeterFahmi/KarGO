import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kargo/screens/chat_list_screen.dart';
import 'package:kargo/screens/chat_screen.dart';
import 'package:kargo/screens/chat_screen.dart';
import 'package:kargo/screens/home_page.dart';

void main() {
  initializeDateFormatting()
  .then((_){
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/': (ctx) => HomePage(),
        '/Chats': (context) => ChatListScreen(),
        '/ChatDetail':(context) => ChatScreen()
      },
    );
  }
}
