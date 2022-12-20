import 'package:flutter/material.dart';
import 'package:snow_daze/screens/weatherScreens/listAllLocationsWeatherScreen.dart';
import 'package:snow_daze/widgets/sideDrawer.dart';

import '../screens/weatherScreens/listFavoritesWeatherScreen.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key? key}) : super(key : key);
  
  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  // Pages
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
    AllLocations(),
    Icon(
      Icons.settings_outlined,
      size: 150,
    ),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SnowDaze"),
      ),
      drawer: const SideDrawer(),
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
                  Icons.add_location,
                  color: Colors.white
              ),
              label: "Add New",
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