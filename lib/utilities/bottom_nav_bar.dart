import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:snow_daze/screens/weather_page.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key? key}) : super(key : key);
  
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int currentIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: [
        const WeatherScreen(),
      ][currentIndex],
      bottomNavigationBar:
      BottomNavigationBar(
        backgroundColor: Colors.indigo,
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        }, 
        items: const [
          BottomNavigationBarItem(
              icon: Icon(
                  Icons.home_outlined,
                  color: Colors.white
              )
          ),
          BottomNavigationBarItem(
              icon: Icon(
                  Icons.downhill_skiing_outlined,
                  color: Colors.white
              )
          ),
          BottomNavigationBarItem(
              icon: Icon(
                  Icons.ac_unit_outlined,
                  color: Colors.white
              )
          ),
          BottomNavigationBarItem(
              icon: Icon(
                  Icons.traffic_outlined,
                  color: Colors.white
              )
          ),
          BottomNavigationBarItem(
              icon: Icon(
                  Icons.settings_outlined,
                  color: Colors.white
              )
          ),
        ],
      ),
    );
  }
  
  
  
}