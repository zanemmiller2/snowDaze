
import 'package:flutter/material.dart';
import 'package:snow_daze/models/weather/currentWeather.dart';

class DailyDetailedWeatherView extends StatefulWidget {

  final CurrentWeather detailedLocationForecastData;
  final String title;
  const DailyDetailedWeatherView({super.key, required this.detailedLocationForecastData, required this.title});

  @override
  State<StatefulWidget> createState() => _DailyDetailedWeatherViewState();
}

class _DailyDetailedWeatherViewState extends State<DailyDetailedWeatherView> {
  get title => widget.title;


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(title: Text('$title Hourly')),
      body: Container(
        child: const Text('DAILY DETAIL SCREEN'),
      ),
    );
  }

}