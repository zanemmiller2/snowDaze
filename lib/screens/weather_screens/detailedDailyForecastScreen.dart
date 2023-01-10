
import 'dart:math';

import 'package:flutter/material.dart';

import '../../utilities/unitConverters.dart';

class DailyDetailedWeatherView extends StatelessWidget {

  final Map dailyDetailedLocationForecastDataWWO;
  final String resortName;
  final int index;

  const DailyDetailedWeatherView(
      {super.key, required this.dailyDetailedLocationForecastDataWWO, required this.resortName, required this.index});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('$resortName Detailed')),
        body: SingleChildScrollView(
          child: Column(
              children: [
                baseDetailWidget(context),
              // Base Detail
              // Mid Detail
              // Top Detail
              // Cloud Cover
              // Freezing Level
              // humidity
              // precipitation inches
              // snowfall
              // air pressure
              // visibility

            ])));
  }

  Widget baseDetailWidget(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(left: 10.0),
          alignment: Alignment.centerLeft,
          child: const Text('Hourly DETAIL')
        ),
        ListView.builder(
            shrinkWrap: true,
            itemCount: dailyDetailedLocationForecastDataWWO['hourly'].length,
            itemBuilder: (context, index) => _buildIndividualHourlyComponents(context, index)
        ),
      ],
    );
  }

  Widget _buildIndividualHourlyComponents(BuildContext context, index) {
    return ListTile(
          title: Column(
            children: [
              Text('Time: ${dailyDetailedLocationForecastDataWWO['hourly'][index]['time']}'),
              FittedBox(
                fit: BoxFit.fitWidth,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Bottom - '),
                    Text('Temperature: ${dailyDetailedLocationForecastDataWWO['hourly'][index]['bottom'][0]['tempF']}'),
                    Text('Wind: ${dailyDetailedLocationForecastDataWWO['hourly'][index]['bottom'][0]['windspeedMiles']} mph ${dailyDetailedLocationForecastDataWWO['hourly'][index]['bottom'][0]['winddir16Point']}'),
                    Text('Weather: ${dailyDetailedLocationForecastDataWWO['hourly'][index]['bottom'][0]['weatherDesc'][0]['value']}'),
                  ],
                ),
              ),
              FittedBox(
                fit: BoxFit.fitWidth,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Mid - '),
                    Text('Temperature: ${dailyDetailedLocationForecastDataWWO['hourly'][index]['mid'][0]['tempF']}'),
                    Text('Wind: ${dailyDetailedLocationForecastDataWWO['hourly'][index]['mid'][0]['windspeedMiles']} mph ${dailyDetailedLocationForecastDataWWO['hourly'][index]['mid'][0]['winddir16Point']}'),
                    Text('Weather: ${dailyDetailedLocationForecastDataWWO['hourly'][index]['mid'][0]['weatherDesc'][0]['value']}'),
                  ],
                ),
              ),
              FittedBox(
                fit: BoxFit.fitWidth,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Top - '),
                    Text('Temperature: ${dailyDetailedLocationForecastDataWWO['hourly'][index]['top'][0]['tempF']}'),
                    Text('Wind: ${dailyDetailedLocationForecastDataWWO['hourly'][index]['top'][0]['windspeedMiles']} mph ${dailyDetailedLocationForecastDataWWO['hourly'][index]['top'][0]['winddir16Point']}'),
                    Text('Weather: ${dailyDetailedLocationForecastDataWWO['hourly'][index]['top'][0]['weatherDesc'][0]['value']}'),
                  ],
                ),
              ),
              FittedBox(
                fit: BoxFit.fitWidth,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Cloud Cover: ${dailyDetailedLocationForecastDataWWO['hourly'][index]['cloudcover']}% '),
                    Text('Freezing Level: ${convertMetersToFeet(dailyDetailedLocationForecastDataWWO['hourly'][index]['freezeLevel'])} feet '),
                    Text('Humidity: ${dailyDetailedLocationForecastDataWWO['hourly'][index]['humidity']}% '),
                  ],
                ),
              ),
              FittedBox(
                fit: BoxFit.fitWidth,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Pressure: ${dailyDetailedLocationForecastDataWWO['hourly'][index]['pressureInches']} inHg '),
                    Text('Snowfall: ${convertCmToIn(double.parse(dailyDetailedLocationForecastDataWWO['hourly'][index]['snowfall_cm']))} inches '),
                    Text('Visibility: ${dailyDetailedLocationForecastDataWWO['hourly'][index]['visibilityMiles']} miles'),
                  ],
                ),
              ),
            ],
          ),
    );
  }

}