// page for weather repo
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {


  Widget _buildListItem(BuildContext context, MockWeatherInfo weatherInfo) {
    return ListTile(
      title: Row(
        children: [
          Expanded(
              child: Text(
                  weatherInfo.areaDescription,
                  style: Theme.of(context).textTheme.headlineMedium,
              ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xffddddff),
            ),
            padding: const EdgeInsets.all(10.0),
            child: Text(
              weatherInfo.latitude.toString(),
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xffddddff),
            ),
            padding: const EdgeInsets.all(10.0),
            child: Text(
              weatherInfo.longitude.toString(),
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ),
        ],
      ),
      onTap: () {
        print("should increase weather here");
      },
    );
  }

  static const List<MockWeatherInfo> _weatherList = [
    MockWeatherInfo(areaDescription: "Area 1", latitude: "1", longitude: "1"),
    MockWeatherInfo(areaDescription: "Area 2", latitude: "2", longitude: "2"),
    MockWeatherInfo(areaDescription: "Area 3", latitude: "3", longitude: "3")
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("weather page title"),
      ),
      body: ListView.builder(
        itemExtent: 80.0,
        itemCount: _weatherList.length,
        itemBuilder: (context, index) => _buildListItem(context, _weatherList[index]),
      ),
    );
  }
}

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text("weather page title"),
  //     ),
  //     body: StreamBuilder(
  //       stream: FirebaseFirestore.instance.collection('weather_forecasts').snapshots(),
  //       builder: (context, snapshot) {
  //         if(!snapshot.hasData){
  //           return const Text('Loading...');
  //         }
  //         return ListView.builder(
  //             itemExtent: 80.0,
  //             itemCount: _weatherList.length,
  //             itemBuilder: (context, index) => _buildListItem(context, _weatherList[index]));
  //       }
  //     ),
  //   );
  // }

class MockWeatherInfo {

  const MockWeatherInfo({required this.areaDescription, required this.latitude, required this.longitude});
  final String areaDescription;
  final String latitude;
  final String longitude;
}
