// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:snow_daze/screens/weather_screens/listAllLocationsWeatherScreen.dart';
import 'package:snow_daze/widgets/sideDrawer.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key? key}) : super(key : key);
  
  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  // Pages
  static const List<Widget> _pages = <Widget>[
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
        backgroundColor: Color(0xff7686A6),
        title: const Text("SnowDaze"),
      ),
      drawer: const SideDrawer(),
      body: Center(
        child: _pages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar (
        type: BottomNavigationBarType.shifting,
        currentIndex: _selectedIndex,
        backgroundColor: Color(0xff7686A6),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        iconSize: 40,
        items:  const [
          BottomNavigationBarItem(
              icon: Icon(
                  Icons.my_location_sharp,
                  color: Color(0xffA66370)
              ),
              label: "All Locations",
              backgroundColor: Color(0xff7686A6),
          ),
          BottomNavigationBarItem(
              icon: Icon(
                  Icons.settings_outlined,
                  color: Color(0xffA66370)
              ),
              label: "Settings",
              backgroundColor: Color(0xff7686A6),
          ),
        ],
      ),
    );
  }
}
