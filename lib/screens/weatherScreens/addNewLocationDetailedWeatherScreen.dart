import 'package:flutter/material.dart';
import 'package:snow_daze/models/weather_class.dart';

class AddNewDetailedWeatherView extends StatefulWidget {
  final String latitude;
  final String longitude;
  final String title;

  const AddNewDetailedWeatherView({super.key, required this.latitude, required this.longitude, required this.title});

  @override
  State<AddNewDetailedWeatherView> createState() => _AddNewDetailedWeatherViewState();
}

class _AddNewDetailedWeatherViewState extends State<AddNewDetailedWeatherView> {

  late WeatherForecast detailedWeatherForecast;

  @override
  void initState() {
    super.initState();
    detailedWeatherForecast = WeatherForecast(widget.latitude, widget.longitude);
  }

  //
  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: detailedWeatherForecast.initialize(),
      builder: (context, snapshot) {
        if(detailedWeatherForecast.areaDescription != null) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.title),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xffddddff),
                    ),
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      "Area Description: ${detailedWeatherForecast.areaDescription}",
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
                      "Source Credit: ${detailedWeatherForecast.sourceCredit}",
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
                      "Source Link: ${detailedWeatherForecast.nwsSourceURL}",
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
                      "Elevation: ${detailedWeatherForecast.elevation} ${detailedWeatherForecast.elevationUnits}",
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
                      "Wind Chill Temperatures: ${detailedWeatherForecast.windChillTemperatures}",
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
                      "Dew Point Temperatures: ${detailedWeatherForecast.dewPointTemperatures}",
                      style: Theme
                          .of(context)
                          .textTheme
                          .subtitle1,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const Text("Loading...");
        }
      },
    );
  }
}

