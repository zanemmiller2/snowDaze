import 'dart:math';

import 'package:flutter/material.dart';
import 'package:snow_daze/utilities/unitConverters.dart';

import '../../models/weather/currentWeather.dart';

class GridDetailView extends StatelessWidget {
  final String category;
  final String resortName;
  final String actualTitle;
  final CurrentWeather detailedLocationForecastData;

  const GridDetailView(
      {super.key,
      required this.category,
      required this.detailedLocationForecastData,
      required this.resortName,
      required this.actualTitle});
  @override
  Widget build(BuildContext context) {
    return hourlyDetailList();
  }

  Widget hourlyDetailList() {
    // Sunrise doesn't use list view
    if (category == 'sun_rise') {
      return Scaffold(
          appBar: AppBar(
            title: Text("Today"
                "'s $actualTitle at $resortName"),
          ),
          body: Center(
              child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Card(
                        child: Column(
                          children: [
                            Image.asset('assets/images/sunrise_icon.png'),
                            Text(
                              convertEpochTimeTo12Hour(
                                  detailedLocationForecastData.current['sunrise']),
                            ),
                          ],
                        ),
                      ),
                      Card(
                        child: Column(
                          children: [
                            Image.asset('assets/images/sunset_icon.png'),
                            Text(
                              convertEpochTimeTo12Hour(
                                  detailedLocationForecastData.current['sunset']),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
              )
          )
      );
    } else {
      return Scaffold(
          appBar: AppBar(
            title: Text('Hourly $actualTitle at $resortName'),
          ),
          body: Center(
              child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(left: 10.0),
                        alignment: Alignment.centerLeft,
                        child: Text(actualTitle),
                      ),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const ScrollPhysics(),
                        itemCount: 24,
                        itemBuilder: (context, index) => _buildHourly(context, index),
                        separatorBuilder: (BuildContext context, int index) {
                          return const Divider(
                            height: 10,
                            thickness: 1,
                            indent: 10,
                            endIndent: 10,
                            color: Colors.grey,
                          );
                        },
                      ),
                    ],
                  )
              )
          )
      );
    }
  }

  Widget _buildHourly(BuildContext context, index) {
    String? temp;
    String? visibilityDistance;
    var time = convertEpochTimeTo12Hour(
        detailedLocationForecastData.hourly[index]['dt']);

    /// builds the daily simple widget rows

    // temperature widgets
    if (category == 'temp' || category == 'feels_like' || category == 'dew_point') {
      temp =
          '${(detailedLocationForecastData.hourly[index]['$category'] / 1).ceil().toString()}\u{00B0}';
      return ListTile(
          title: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Day and Date
          Expanded(
            child: Text(
              time,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          Flexible(
            child: Text(
              temp,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
        ],
      ));
    } else if (category == 'visibility') {
      num distance = convertMetersToMiles(
          detailedLocationForecastData.hourly[index]['$category']);
      if (distance < .10) {
        distance = distance * 5280;
        visibilityDistance = '${distance.toStringAsFixed(2)} feet';
      } else {
        visibilityDistance = '${distance.toStringAsFixed(2)} miles';
      }

      return ListTile(
          title: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Day and Date
          Expanded(
            child: Text(
              time,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          Flexible(
            child: Text(
              visibilityDistance,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
        ],
      ));
    } else if (category == 'wind') {
      String windSpeed =
          '${detailedLocationForecastData.hourly[index]['wind_speed']} mph';
      String windGust =
          '${detailedLocationForecastData.hourly[index]['wind_gust']} mph';
      int windDeg = detailedLocationForecastData.hourly[index]['wind_deg'];

      return ListTile(
          title: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Day and Date
          Expanded(
            child: Text(
              time,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          Flexible(
            child: Text(
              windSpeed,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          Flexible(
            child: Text(
              '$windGust gust',
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          Transform.rotate(
              // rotated to reflect actual wind direction in degrees true north
              angle: windDeg * (pi / 180),
              child: const Icon(Icons.north, size: 100.0, color: Colors.blue))
        ],
      ));
    } else if (category == 'pressure') {
      String pressure =
          '${converthPaToInHg(detailedLocationForecastData.hourly[index]['$category']).toStringAsFixed(1)} inHg';

      return ListTile(
          title: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Day and Date
          Expanded(
            child: Text(
              time,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          Flexible(
            child: Text(
              pressure,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
        ],
      ));
    } else if (category == 'uvi') {
      num uviNum = detailedLocationForecastData.hourly[index]['$category'];

      return ListTile(
          tileColor: uvColor(uviNum),
          title: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Day and Date
              Expanded(
                child: Text(
                  time,
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
              Flexible(
                child: Text(
                  uvLevel(uviNum),
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
            ],
          ));
    } else if (category == 'humidity') {
      return ListTile(
          title: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Day and Date
          Expanded(
            child: Text(
              time,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          Flexible(
            child: Text(
              '${detailedLocationForecastData.hourly[index]['humidity']} %',
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
        ],
      ));
    } else if (category == 'pop') {
      return ListTile(
          title: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Day and Date
          Expanded(
            child: Text(
              time,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          Flexible(
            child: Text(
              '${(detailedLocationForecastData.hourly[index]['pop'] * 100).ceil()} %',
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
        ],
      ));
    }
    return const SizedBox.shrink();
  }


}
