import 'package:flutter/material.dart';
import 'package:snow_daze/models/weather_class.dart';

class DetailedWeatherView extends StatefulWidget {
  final String latitude;
  final String longitude;

  const DetailedWeatherView({super.key, required this.latitude, required this.longitude});

  @override
  State<DetailedWeatherView> createState() => _DetailedWeatherViewState();
}

class _DetailedWeatherViewState extends State<DetailedWeatherView> {

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
              title: const Text("detailed location view page"),
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

