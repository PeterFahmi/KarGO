import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';

class MyBottomNavagationBar extends StatefulWidget {
  const MyBottomNavagationBar({super.key});

  @override
  State<MyBottomNavagationBar> createState() => _MyBottomNavagationBarState();
}

class _MyBottomNavagationBarState extends State<MyBottomNavagationBar> {
  var _selectedItemPosition = 0;

  @override
  Widget build(BuildContext context) {
    return SnakeNavigationBar.color(
      backgroundColor: Colors.black,
      // height: 80,
      behaviour: SnakeBarBehaviour.floating,
      snakeShape: SnakeShape.circle,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      padding: EdgeInsets.all(12),

      ///configuration for SnakeNavigationBar.color
      snakeViewColor: Colors.white,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.white,

      ///configuration for SnakeNavigationBar.gradient
      // snakeViewGradient: selectedGradient,
      // selectedItemGradient: snakeShape == SnakeShape.indicator ? selectedGradient : null,
      // unselectedItemGradient: unselectedGradient,

      showUnselectedLabels: false,
      showSelectedLabels: false,

      currentIndex: _selectedItemPosition,
      onTap: (index) => setState(() => _selectedItemPosition = index),
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.notifications), label: 'tickets'),
        BottomNavigationBarItem(
            icon: Icon(Icons.ac_unit_outlined), label: 'calendar'),
        BottomNavigationBarItem(
            icon: Icon(Icons.ac_unit_outlined), label: 'home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.ac_unit_outlined), label: 'microphone'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'search')
      ],
      selectedLabelStyle: const TextStyle(fontSize: 14),
      unselectedLabelStyle: const TextStyle(fontSize: 10),
    );
  }
}
