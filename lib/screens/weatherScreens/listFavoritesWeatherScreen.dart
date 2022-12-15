// page for weather repo


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snow_daze/screens/weatherScreens/detailedFavoritesWeatherScreen.dart';


class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return ListTile(
      title: Row(
        children: [
          Expanded(
            child: Text(
              document["areaDescription"],
              style: Theme
                  .of(context)
                  .textTheme
                  .subtitle1,
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xffddddff),
            ),
            padding: const EdgeInsets.all(10.0),
            child: Text(
             document["latitude"].toString(),
              style: Theme
                  .of(context)
                  .textTheme
                  .subtitle1,
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xffddddff),
            ),
            padding: const EdgeInsets.all(10.0),
            child: Text(
              document["longitude"].toString(),
              style: Theme
                  .of(context)
                  .textTheme
                  .subtitle1,
            ),
          ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  DetailedWeatherView(
                      latitude: document["latitude"].toString(),
                      longitude: document["longitude"].toString())
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("weather page title"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('weather_forecasts').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Text('Loading...');
          }
          return ListView.builder(
              itemExtent: 80.0,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) =>
                  _buildListItem(context, snapshot.data!.docs[index]));
          }
        ),
      );
    }
}

class MockWeatherInfo {

  const MockWeatherInfo({required this.areaDescription, required this.latitude, required this.longitude});
  final String areaDescription;
  final String latitude;
  final String longitude;
}
