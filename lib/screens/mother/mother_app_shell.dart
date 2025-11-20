import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:project_frontend/screens/mother/caregiver_list_screen.dart';
import 'package:project_frontend/screens/mother/home_screen.dart';

class MotherAppShell extends StatefulWidget {
  const MotherAppShell({super.key});

  @override
  State<MotherAppShell> createState() => _MotherAppShellState();
}

final iconList = [Icons.home, Icons.abc, Icons.search, Icons.person];

final screens = [
  HomeScreen(),
  HomeScreen(),
  CaregiverListScreen(),
  HomeScreen(),
];

class _MotherAppShellState extends State<MotherAppShell> {
  int _bottomNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[_bottomNavIndex],
      bottomNavigationBar: Container(
        width: double.infinity,
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        child: AnimatedBottomNavigationBar(
          icons: iconList,
          activeIndex: _bottomNavIndex,
          gapLocation: GapLocation.none, // removes center notch gap
          leftCornerRadius: 0,
          rightCornerRadius: 0,
          notchSmoothness: NotchSmoothness.sharpEdge,
          onTap: (index) => setState(() => _bottomNavIndex = index),
          backgroundColor: const Color.fromARGB(237, 237, 204, 235), // optional
          elevation: 0,
        ),
      ),
    );
    ;
  }
}
