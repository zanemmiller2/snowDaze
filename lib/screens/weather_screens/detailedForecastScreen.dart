// Flutter imports:
// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:snow_daze/utilities/timeConversions.dart';

// Project imports:
import '../../interactions/OpenWeatherClass.dart';
import '../../models/weather/currentWeather.dart';
import '../../widgets/snowFlakeProgressIndicator.dart';



class DetailedAllWeatherView extends StatefulWidget {
  final String latitude;
  final String longitude;
  final String title;

  const DetailedAllWeatherView(
      {super.key,
      required this.latitude,
      required this.longitude,
      required this.title});

  @override
  State<DetailedAllWeatherView> createState() => _DetailedAllWeatherViewState();
}

class _DetailedAllWeatherViewState extends State<DetailedAllWeatherView> {
  DocumentSnapshot? detailedLocationForecastSnapshot;
  CurrentWeather? detailedLocationForecastData;
  bool _gotData = false;

  get title => widget.title;

  get latitude => widget.latitude;

  get longitude => widget.longitude;

  get detailedLocationForecastDataCurrent => detailedLocationForecastData?.current;

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
          DateTime
              .now()
              .millisecondsSinceEpoch ~/ 1000 - 360) {
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

    const daysOfWeekAbr = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Scaffold(
            appBar: AppBar(title: Text('$title Detailed')),
            body: Column(
              children: [
                SizedBox(
                    height: 100,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                            'CURRENT WEATHER CONDITIONS GO HERE',
                            textAlign: TextAlign.center,
                        ),
                      ],
                    )
                ),
                Expanded(
                  child: ListView.builder(
                      itemCount: detailedLocationForecastData?.daily.length,
                      itemBuilder: (context, index) =>
                          _buildDetailedDailyWeatherWidget(context, index, latitude, longitude, detailedLocationForecastData?.daily[index]['dt'])),
                ),
              ],
            )
    );
  }

} // class _DetailedAllWeatherViewState extends State<DetailedAllWeatherView>


  Widget _buildDetailedDailyWeatherWidget (BuildContext context, index, latitude, longitude, currentDt) {

  const daysOfWeekAbr = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  return ListTile(
    title: Row(
      children: [
        // Day and Date
        Expanded(
          child: Text(
            daysOfWeekAbr[convertToLocationLocalTime(latitude, longitude, currentDt).weekday],
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ),
        // temperatures
        Expanded(
          child: Text(
            'Temperatures here',
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ),
        // snowfall
        Expanded(
          child: Text(
            'Snowfall here',
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ),
      ],
    )
  );
}



