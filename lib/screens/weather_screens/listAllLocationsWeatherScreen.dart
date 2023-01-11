// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:weather/weather.dart';

// Project imports:
import 'package:snow_daze/screens/weather_screens/detailedForecastScreen.dart';
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
    // Gets the document snapshot of all resorts from firestore db,
    // checks if the widget is mounted before setting the _gotData to true,
    // signalling the widget that it is ok to build
    getSnapshots().whenComplete(() {
      if (mounted) {
        setState(() {
          _gotData = true;
        });
      }
    });
  }

  Future<void> getSnapshots() async {
    /// Future void function that gets the list of documents in 'resorts'
    /// and adds the data of each document to allResortsList list

    // get each document
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("resorts").get();
    // add each document.data to the allResortsList list
    for (var element in querySnapshot.docs) {
      allResortsList.add(element.data());
    }

    // instantiate a WeatherFactory object
    WeatherFactory wf = WeatherFactory(openWeatherAPIKey);

    for (var resort in allResortsList) {
      // for each resort in list, get the current weather at that (lat, long) location
      Weather w = await wf.currentWeatherByLocation(
          double.parse(resort['latitude']), double.parse(resort['longitude']));

      // add the locations current temperatures as integers to currentTemps list
      currentTemps.add(w.temperature?.fahrenheit?.toInt());

      // add the locations current weather descriptions to currentWeather map
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

  Widget _buildAvailableLocationsListItem(BuildContext context, index, allResortsList) {
    /// builds a list tile for each resort
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
              child: Image.network(
                'https://openweathermap.org/img/w/${currentWeather[index]["icon"]}.png',
                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                }),
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
        onTap: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    DetailedForecastScreen(
                      latitude: allResortsList[index]['latitude'],
                      longitude: allResortsList[index]['longitude'],
                      resortName: allResortsList[index]['resortName'],
                      resortTwitterUserName: allResortsList[index]['twitterUserName'],
                      resortState: allResortsList[index]['state'],
                      resortRoadConditions: allResortsList[index]['roadLinks'] ?? allResortsList[index]['roadConditionsLink']
                    )),
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO -- convert to stream builder?
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
                _buildAvailableLocationsListItem(context, index, allResortsList)));
  }
}
