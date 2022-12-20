import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:snow_daze/models/weather_class.dart';

import '../../utilities/apiCallURLs.dart';
import '../../widgets/snowFlakeProgressIndicator.dart';

class DetailedAllWeatherView extends StatefulWidget {
  final String latitude;
  final String longitude;
  final String title;

  const DetailedAllWeatherView({super.key, required this.latitude, required this.longitude, required this.title});

  @override
  State<DetailedAllWeatherView> createState() => _DetailedAllWeatherViewState();
}

class _DetailedAllWeatherViewState extends State<DetailedAllWeatherView> {

  late WeatherForecast detailedWeatherForecast;
  late DocumentSnapshot detailedLocationForecastFromDb;
  CurrentWeather? detailedLocationForecastFromAPI;
  bool _gotData = false;

  @override
  void initState() {
    super.initState();
    fetchLocationDataFromAPI()
        .whenComplete(() => setState(() {
          _gotData = true;
    }));


  }

  Future<void> fetchLocationDataFromDb () async {
    // gets the existing forecast for the given coordinates and returns the db data as a map
    detailedLocationForecastFromDb = await FirebaseFirestore.instance.collection('weather_forecasts').doc('${widget.latitude}${widget.longitude}').get();
  }

  Future<void> fetchLocationDataFromAPI () async {
    // gets the existing forecast for the given coordinates and returns the db data as a map
    var url = await getCurrentWeatherAPIUrl(latitude: widget.latitude, longitude: widget.longitude);
    detailedLocationForecastFromAPI = await fetchCurrentWeatherForecast(url);
  }


  //
  @override
  Widget build(BuildContext context) {
    if(!_gotData){
      return const ProgressWithIcon();
    }
    return Scaffold(
      body: ListTile(
              title: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xffddddff),
                      ),
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        "Area Description: ${detailedLocationForecastFromAPI}",
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
                        "Source Credit: ${detailedLocationForecastFromAPI?.hourly}",
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
                        "Wind Chill Temperatures: ${detailedLocationForecastFromAPI?.timezone}",
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
                        "ALERTS: ${detailedLocationForecastFromAPI?.alerts}",
                        style: Theme
                            .of(context)
                            .textTheme
                            .subtitle1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
        }
  }


