// Flutter imports:
// Package imports:
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:snow_daze/utilities/timeConversions.dart';

// Project imports:
import '../../interactions/OpenWeatherClass.dart';
import '../../models/weather/currentWeather.dart';
import '../../utilities/locationDailySnowfall.dart';
import '../../widgets/snowFlakeProgressIndicator.dart';
import 'detailedDailyForecastScreen.dart';

//    <script defer src="/dist/mountain.snowReport.bundle.cdee8458df92cf7fda7f.js"></script>
//     <script defer src="/dist/mountain.weatherForecast.bundle.3f14a47049492eb3117e.js"></script>

class DetailedAllWeatherView extends StatefulWidget {
  final String latitude;
  final String longitude;
  final String title;

  const DetailedAllWeatherView(
      {super.key,
      required this.latitude,
      required this.longitude,
      required this.title});

  get snowFall => null;

  @override
  State<DetailedAllWeatherView> createState() => _DetailedAllWeatherViewState();
}

class _DetailedAllWeatherViewState extends State<DetailedAllWeatherView> {

  DocumentSnapshot? detailedLocationForecastSnapshot;
  late CurrentWeather detailedLocationForecastData;
  bool _gotData = false;
  static const daysOfWeekAbr = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  get title => widget.title;
  get latitude => widget.latitude;
  get longitude => widget.longitude;
  get detailedLocationForecastDataCurrent =>
      detailedLocationForecastData.current;

  @override
  void initState() {
    super.initState();
    // get the location data for the specified location
    fetchLocationData().whenComplete(() {
      setState(() {
        _gotData = true;
      });
    });
  }

  Future<void> fetchLocationData() async {
    /// fetchLocationData fetches current detailed weather data from API or DB

    OpenWeather openWeatherClass =
        OpenWeather(latitude: latitude, longitude: longitude);

    // If the data exists in the db and its been updated less than an hour ago use the data from the db
    if (await openWeatherClass.checkIfDocExistsForLocation()) {
      CurrentWeather detailedWeatherForecastFromDB =
          await openWeatherClass.fetchCurrentWeatherForecastFromFirestore();
      // data in db was updated less than an hour ago
      if (detailedWeatherForecastFromDB.lastUpdated >
          DateTime.now().millisecondsSinceEpoch ~/ 1000 - 360) {
        detailedLocationForecastData = detailedWeatherForecastFromDB;
        print('USING DATA FROM DB');
        // data was updated more than an hour ago ... use data from API call
      } else {
        detailedLocationForecastData =
            await openWeatherClass.fetchCurrentWeatherForecast(
                await openWeatherClass.getCurrentWeatherAPIUrl(
                    latitude: widget.latitude, longitude: widget.longitude));
        print('USING DATA FROM API');
      }

      // Data doesn't currently exist in the database ... use the data from the API Call
    } else {
      detailedLocationForecastData =
          await openWeatherClass.fetchCurrentWeatherForecast(
              await openWeatherClass.getCurrentWeatherAPIUrl(
                  latitude: widget.latitude, longitude: widget.longitude));
      print('USING DATA FROM API');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_gotData) {
      return const ProgressWithIcon();
    }

    return Scaffold(
        appBar: AppBar(title: Text('$title Detailed')),
        body: Column(
          children: [
            SizedBox(
                height: 100,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDetailedCurrentWeatherWidget(context)
                  ],
                )),
            Expanded(
              child: ListView.builder(
                  itemCount: detailedLocationForecastData?.daily.length,
                  itemBuilder: (context, index) =>
                      _buildDetailedDailyWeatherWidget(
                          context,
                          index,
                          latitude,
                          longitude)),
            ),
          ],
        ));
  }

  Widget _buildDetailedDailyWeatherWidget(
      BuildContext context, index, latitude, longitude) {

    List precipitation = getDailyPrecipitation(detailedLocationForecastData, index);
    String weatherType = precipitation[0];
    String dailyQpf = precipitation[1];

    List dailyMinMaxTemp = getDailyTemperatures(detailedLocationForecastData, index);
    String minTemp = dailyMinMaxTemp[0].toString();
    String maxTemp = dailyMinMaxTemp[1].toString();

    // use the larger of the two predictions between NWS and OpenWeather
    var dayStartTime = convertEpochToDateTime(detailedLocationForecastData.daily[index]['dt']);
    nwsLocationDailySnowfall(dayStartTime, latitude, longitude)
        .then((value) {
          if(value > double.parse(dailyQpf)) {
            print('USING NWS SNOWFALL PREDICTIONS');
            dailyQpf = value.toString();
          } else {
            print('USING OPENWEATHER SNOWFALL PREDICTIONS');
          }
    });

    return ListTile(
        title: Row(
      children: [
        // Day and Date
        Expanded(
          child: Text(
            daysOfWeekAbr[
                convertToLocationLocalTime(latitude, longitude, detailedLocationForecastData.daily[index]['dt'])
                    .weekday],
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ),
        // precip probability
        Expanded(
          child: Text(
            'Chance\n${detailedLocationForecastData.daily[index]['pop'] * 100}%',
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ),
        // temperatures
        Expanded(
          child: Text(
            'Temperatures\nMin: $minTemp\n Max: $maxTemp',
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ),
        // snowfall
        Expanded(
          child: Text(
            'Precipitation\n$weatherType $dailyQpf',
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
                DailyDetailedWeatherView(
                  title: '$title ${daysOfWeekAbr[
                  convertToLocationLocalTime(latitude, longitude, detailedLocationForecastData.daily[index]['dt'])
                      .weekday]}',
                  detailedLocationForecastData: detailedLocationForecastData,
                )
            )
          );
        });
  }

  Widget _buildDetailedCurrentWeatherWidget (BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
      child: Row (
        children: [
          // current temp
          Expanded(
            child: Text(
              'Current Temp\n${(detailedLocationForecastDataCurrent['temp'] / 1).floor()}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          // feels like
          Expanded(
            child: Text(
              'Feels Like\n${(detailedLocationForecastDataCurrent['feels_like'] / 1).floor()}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          // time
          Expanded(
            child: Text(
              'Date/Time\n${dateTimeToHumanReadable(convertToLocationLocalTime(detailedLocationForecastData.lat, detailedLocationForecastData.lon, detailedLocationForecastDataCurrent['dt']))}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          // time
          Expanded(
            child: Text(
              'Humidity\n${detailedLocationForecastDataCurrent['humidity']}%',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          // time
          Expanded(
            child: Text(
              'Wind\n${detailedLocationForecastDataCurrent['wind_speed']} mph\n${detailedLocationForecastDataCurrent['wind_gust']} gusts',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Transform.rotate(
            angle: detailedLocationForecastDataCurrent['wind_deg'] * (pi / 180),
            child: const Icon(Icons.north)
            ),
          Expanded(
            child: Text(
              'Weather\n${detailedLocationForecastDataCurrent['weather'][0]['description']}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

} // class _DetailedAllWeatherViewState extends State<DetailedAllWeatherView>

double convertMmToIn (qpf) {
  /// converts a double mm measurement to double inches
  return (qpf / 25.4).ceil().toDouble();
}
List<String> getDailyPrecipitation (detailedLocationForecastData, index) {

  String? precipitationRainQpf = convertMmToIn(detailedLocationForecastData?.daily[index]['rain'] ?? 0.0).toString();
  String? precipitationSnowQpf = convertMmToIn(detailedLocationForecastData?.daily[index]['snow'] ?? 0.0).toString();
  String? dailyQpf = '0.0';
  String? weatherType;

  // snow and rain count as snow only
  if(double.parse(precipitationRainQpf) > 0.0 && double.parse(precipitationSnowQpf) > 0.0) {
    double tempSnow = double.parse(precipitationSnowQpf) + double.parse(precipitationRainQpf);
    dailyQpf = tempSnow.toString();
    weatherType = 'Snow';
  }
  // rain only
  else if (double.parse(precipitationRainQpf) > 0.0 && double.parse(precipitationSnowQpf) <= 0.0) {
    dailyQpf = precipitationRainQpf;
    weatherType = 'Rain';
    // Snow only
  } else if (double.parse(precipitationRainQpf) <= 0.0 && double.parse(precipitationSnowQpf) > 0.0) {
    dailyQpf = precipitationSnowQpf;
    weatherType = 'Snow';
    // no snow or rain
  } else {
    dailyQpf = '0.0';
    weatherType = 'No rain or snow';
  }

  return [weatherType, dailyQpf];
}
List<num> getDailyTemperatures (detailedLocationForecastData, index) => [detailedLocationForecastData.daily[index]['temp']['min'], detailedLocationForecastData.daily[index]['temp']['max']];





