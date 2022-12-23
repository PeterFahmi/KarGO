import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';

class MyBottomNavagationBar extends StatefulWidget {
  Function(int) notifyParent;
  MyBottomNavagationBar({required this.notifyParent});
  @override
  State<MyBottomNavagationBar> createState() => _MyBottomNavagationBarState();
}

class _MyBottomNavagationBarState extends State<MyBottomNavagationBar> {
  var _selectedTabPosition = 0;

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

      currentIndex: _selectedTabPosition,
      onTap: (index) => onNavigationChange(index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'tickets'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'calendar'),
        BottomNavigationBarItem(icon: Icon(Icons.sell), label: 'home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.car_crash_rounded), label: 'microphone'),
      ],
      selectedLabelStyle: const TextStyle(fontSize: 14),
      unselectedLabelStyle: const TextStyle(fontSize: 10),
    );
  }

  onNavigationChange(int index) {
    setState(() {
      _selectedTabPosition = index;
    });
    widget.notifyParent(index);
  }
}
