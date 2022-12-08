import 'package:flutter/material.dart';

import '../utilities/bottom_nav_bar.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  static const List<Widget> _pages = <Widget>[
    Icon(
      Icons.home_outlined,
      size: 150,
    ),
    Icon(
      Icons.downhill_skiing_outlined,
      size: 150,
    ),
    Icon(
      Icons.ac_unit_outlined,
      size: 150,
    ),
    Icon(
      Icons.traffic_outlined,
      size: 150,
    ),
    Icon(
      Icons.settings_outlined,
      size: 150,
    ),

  ];

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text("SnowDaze"),
        //actions: <Widget>[LogoutButton()],
      ),
      body: Center(
        child: _pages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar (
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        iconSize: 40,
        items:  const [
          BottomNavigationBarItem(
              icon: Icon(
                  Icons.home_outlined,
                  color: Colors.white,
              ),
            label: "Home",
            backgroundColor: Colors.indigo
          ),
          BottomNavigationBarItem(
              icon: Icon(
                  Icons.downhill_skiing_outlined,
                  color: Colors.white
              ),
            label: "Resorts",
            backgroundColor: Colors.blueAccent
          ),
          BottomNavigationBarItem(
              icon: Icon(
                  Icons.ac_unit_outlined,
                  color: Colors.white
              ),
            label: "Weather",
            backgroundColor: Colors.red
          ),
          BottomNavigationBarItem(
              icon: Icon(
                  Icons.traffic_outlined,
                  color: Colors.white
              ),
            label: "Traffic",
            backgroundColor: Colors.green
          ),
          BottomNavigationBarItem(
              icon: Icon(
                  Icons.settings_outlined,
                  color: Colors.white
              ),
            label: "Settings",
            backgroundColor: Colors.grey
          ),
        ],
      ),
    );
  }
}