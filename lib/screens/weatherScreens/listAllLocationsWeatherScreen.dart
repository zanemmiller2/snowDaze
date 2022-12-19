import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:snow_daze/screens/weatherScreens/detailedForecastScreen.dart';
import 'package:weather/weather.dart';

import '../../auth/secrets.dart';
import '../../widgets/snowFlakeProgressIndicator.dart';

class AllLocations extends StatefulWidget {
  const AllLocations({super.key});

  @override
  State<AllLocations> createState() => _AllLocationsState();
}

class _AllLocationsState extends State<AllLocations> {
  List allResortsList = [];
  List currentTemps = [];
  List currentWeather = [];
  bool _gotData = false;

  @override
  void initState() {
    super.initState();
    getSnapshots().whenComplete(() => setState(() {
          _gotData = true;
        }));
  }

  Future<void> getSnapshots() async {
    // get resorts from db
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("resorts").get();
    querySnapshot.docs.forEach((element) {
      allResortsList.add(element.data());
    });

    // get current weather
    WeatherFactory wf = WeatherFactory(openWeatherAPI);
    for (var resort in allResortsList) {
      Weather w = await wf.currentWeatherByLocation(
          double.parse(resort['latitude']), double.parse(resort['longitude']));
      currentTemps.add(w.temperature?.fahrenheit?.toInt());
      currentWeather.add({
        'main': w.weatherMain,
        'description': w.weatherDescription,
        'icon': w.weatherIcon
      });
    }

    // get forecast

    // get pow alert status
  }

  @override
  void dispose() {
    super.dispose();
  }

  /* BUilds each list tile */
  Widget _buildAvailableLocationsListItem(BuildContext context, index) {
    return ListTile(
        title: Row(
          children: [
            Expanded(
              child: Text(
                allResortsList[index]['resortName'],
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xffddddff),
              ),
              padding: const EdgeInsets.all(10.0),
              child: Text(
                currentWeather[index]['main'].toString(),
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xffddddff),
              ),
              padding: const EdgeInsets.all(10.0),
              child: Image.network(
                'http://openweathermap.org/img/w/${currentWeather[index]["icon"]}.png',
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xffddddff),
              ),
              padding: const EdgeInsets.all(10.0),
              child: Text(
                '${currentTemps[index].toString()}\u00b0',
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    DetailedAllWeatherView(
                      latitude: allResortsList[index]['latitude'],
                      longitude: allResortsList[index]['longitude'],
                      title: allResortsList[index]['resortName'],
                    )),
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_gotData) {
      return const ProgressWithIcon();
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text("search all resorts page"),
        ),
        body: ListView.builder(
            itemExtent: 80.0,
            itemCount: allResortsList.length,
            itemBuilder: (context, index) =>
                _buildAvailableLocationsListItem(context, index)));
  }
}
