import 'dart:math';

import 'package:flutter/material.dart';
import 'package:snow_daze/utilities/unitConverters.dart';

class CurrentDetailedWeatherView extends StatelessWidget {
  final String resortName;
  final Map detailedLocationForecastDataCurrent;
  const CurrentDetailedWeatherView({super.key, required this.resortName, required this.detailedLocationForecastDataCurrent});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: AppBar(title: Text('$resortName Current Detailed')),
        body: GridView(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
          children: [
            // Weather, Precipitation (probability, rain/snow)
            weatherDetailWidget(),
            // Temperature, Feels Like, Dew Point
            temperatureDetailWidget(),
            // UVI
            uvIndexDetailWidget(),
            // Clouds
            cloudsDetailWidget(),
            // Wind
            windDetailWidget(),
            // Pressure
            airPressureDetailWidget(),
            // Humidity
            humidityDetailWidget(),
            // Sunset/Sunrise
            sunRiseSunSetDetailWidget(),
            // Visibility
            visibilityDetailWidget(),
          ],)
    );
  }

  Widget temperatureDetailWidget () {
    return Card (
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text('Current Temperature'),
          Image.asset('assets/images/fahrenheit_gradient_icon.png'),
          Text('Current Temperature: ${detailedLocationForecastDataCurrent['temp'].toString()}\u{00B0}'),
          Text('Feels Like: ${detailedLocationForecastDataCurrent['feels_like'].toString()}\u{00B0}'),
          Text('Dew Point: ${detailedLocationForecastDataCurrent['dew_point'].toString()}\u{00B0}'),
        ],
      ),
    );
  }

  Widget weatherDetailWidget () {
    /// Card with weather_icon, weather description, precipitation amount, precipitation probability

    num dailyQpf = 0.0;
    if(detailedLocationForecastDataCurrent['rain'] != null){
      num rainQpf = detailedLocationForecastDataCurrent['rain']['1h'] ?? 0.0;
      rainQpf = convertMmToIn(rainQpf);
      dailyQpf = dailyQpf + rainQpf;
    } else {
      num rainQpf = 0.0;
      dailyQpf = dailyQpf + rainQpf;
    }
    if(detailedLocationForecastDataCurrent['snow'] != null){
      num snowQpf = detailedLocationForecastDataCurrent['snow']['1h'] ?? 0.0;
      snowQpf = convertMmToIn(snowQpf);
      dailyQpf = dailyQpf + snowQpf;
    } else {
      num snowQpf = 0.0;
      dailyQpf = dailyQpf + snowQpf;
    }
    String weatherDescription = detailedLocationForecastDataCurrent['weather'][0]['description'];
    String dailyQpfString = dailyQpf.toStringAsFixed(2);

    Image weatherIcon;
    if(weatherDescription.contains('snow') || weatherDescription.contains('Snow')) {
      weatherIcon = Image.asset('assets/images/snow_gradient_icon.png');
    } else if(weatherDescription.contains('rain') || weatherDescription.contains('Rain')) {
      weatherIcon = Image.asset('assets/images/rain_gradient_icon.png');
    } else {
      weatherIcon = Image.asset('assets/images/umbrella_gradient_icon.png');
    }

    if(dailyQpfString == '1.00') {
      dailyQpfString = '$dailyQpfString inch';
    } else {
      dailyQpfString = '$dailyQpfString inches';
    }

    return Card (
        child: Column (
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text('Current Weather'),
            weatherIcon,
            Text(weatherDescription),
            Text('1hr Snowfall: $dailyQpfString'),
          ],
        )
    );
  }

  Widget uvIndexDetailWidget () {
    /// returns the uv widget with index, color, level and icon
    num uvi = detailedLocationForecastDataCurrent['uvi'];
    return Card (
        color: uvColor(uvi),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text('UV Index'),
            Image.asset('assets/images/sunshades_gradient_icon.png'),
            Text('UV Index: $uvi'),
            Text(uvLevel(uvi)),
          ],
        )
    );
  }

  Widget cloudsDetailWidget () {
    /// returns the daily cloud detail with icon based on time of day and cloud coverage and coverage %
    return Card(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text('Cloud Coverage'),
            getCloudsIcon(detailedLocationForecastDataCurrent),
            Text('Coverage: ${detailedLocationForecastDataCurrent['clouds'].toString()}%'),
          ]
      ),
    );
  }

  Widget windDetailWidget() {
    /// returns the daily detail on wind speed, direction, gusts and icon rotated to match wind_deg
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text('Wind'),
          Transform.rotate(
            // rotated to reflect actual wind direction in degrees true north
              angle: (detailedLocationForecastDataCurrent['wind_deg'] + 90.0) * (pi / 180),
              child: getWindBarb(detailedLocationForecastDataCurrent)
          ),
          Text('Wind Speed: ${detailedLocationForecastDataCurrent['wind_speed']} mph ${getWindDirectionFromDeg(detailedLocationForecastDataCurrent['wind_deg'])}'),
          Text('Wind Gusts: ${detailedLocationForecastDataCurrent['wind_gust']} mph'),
        ],
      ),
    );
  }


  Widget airPressureDetailWidget () {
    /// returns the air pressure daily detail with icon and air pressure value
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text('Air Pressure'),
          Image.asset('assets/images/pressure_gauge_gradient_icon.png'),
          Text('Air Pressure: ${converthPaToInHg(detailedLocationForecastDataCurrent['pressure']).toStringAsFixed(1)} inHg'),
        ],
      ),
    );
  }

  Widget humidityDetailWidget () {
    /// returns the humidity daily detail with icon and humidity value
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text('Humidity'),
          Image.asset('assets/images/humidity_gradient_icon.png'),
          Text('Humidity: ${detailedLocationForecastDataCurrent['humidity']}%'),
        ],
      ),
    );
  }

  Widget sunRiseSunSetDetailWidget () {
    /// returns the sunrise and sunset daily detail with icon and times
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text('Sunrise'),
          Image.asset('assets/images/sunrise_gradient_icon.png'),
          Text('Sunrise: ${convertEpochTimeTo12Hour(detailedLocationForecastDataCurrent['sunrise'])}'),
          const Text('Sunset'),
          Image.asset('assets/images/sunset_gradient_icon.png'),
          Text('Sunrise: ${convertEpochTimeTo12Hour(detailedLocationForecastDataCurrent['sunset'])}'),
        ],
      ),
    );
  }

  Widget visibilityDetailWidget () {
    num visibilityDistance = convertMetersToMiles(detailedLocationForecastDataCurrent['visibility']);
    String visibilityString = '${visibilityDistance.toStringAsFixed(2)} miles';
    if(visibilityDistance < 0.5) {
      visibilityDistance = visibilityDistance * 5280;
      visibilityString = '${visibilityDistance.toStringAsFixed(0)} feet';
    }
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text('Visibility'),
          Image.asset('assets/images/eye_gradient_icon.png'),
          Text('Visibility: $visibilityString'),
        ],
      ),
    );
  }

}

Image getCloudsIcon(dailyDetailedLocationForecastData) {
  /// assigns the cloudIcon based on coverage % and time of day
  Image cloudIcon;
    // Its night time
    if (DateTime.now().hour >= convertEpochToDateTime(dailyDetailedLocationForecastData['sunset']).hour
        || DateTime.now().hour <= convertEpochToDateTime(dailyDetailedLocationForecastData['sunrise']).hour) {
      // cloudy night
      if (dailyDetailedLocationForecastData['clouds'] > 10) {
        cloudIcon = Image.asset('assets/images/cloudy_night_gradient_icon.png');
        // Clear night
      } else {
        cloudIcon =  Image.asset('assets/images/clear_night_gradient_icon.png');
      }
    } else {
      // clear day
      if(dailyDetailedLocationForecastData['clouds'] <= 10) {
        cloudIcon =  Image.asset('assets/images/smiling_sun_gradient_icon.png');
        // medium cloudy day
      } else if(dailyDetailedLocationForecastData['clouds'] > 10 && dailyDetailedLocationForecastData['clouds'] <= 50) {
        cloudIcon =  Image.asset('assets/images/cloudy_day_gradient_icon.png');
        // extra cloudy
      } else if(dailyDetailedLocationForecastData['clouds'] > 50 && dailyDetailedLocationForecastData['clouds'] <= 85) {
        cloudIcon =  Image.asset('assets/images/cloudy_gradient_icon.png');
        // super cloudy
      } else {
        cloudIcon =  Image.asset('assets/images/extra_cloudy_gradient_icon.png');
      }
    }
  return cloudIcon;
}

Image getWindBarb(dailyDetailedLocationForecastData) {
  num windSpeedMph = dailyDetailedLocationForecastData['wind_speed'];
  num windSpeedKnots = convertMphToKnots(windSpeedMph);
  Image windBarbIcon;

  if(windSpeedKnots <= 2) {
    windBarbIcon = Image.asset('assets/images/windbarbs/wind-speed-1-2.png');
  }else if(windSpeedKnots > 2 && windSpeedKnots <= 7){
    windBarbIcon = Image.asset('assets/images/windbarbs/wind-speed-3-7.png');
  }else if(windSpeedKnots > 7 && windSpeedKnots <= 12){
    windBarbIcon = Image.asset('assets/images/windbarbs/wind-speed-8-12.png');
  }else if(windSpeedKnots > 12 && windSpeedKnots <= 17){
    windBarbIcon = Image.asset('assets/images/windbarbs/wind-speed-13-17.png');
  }else if(windSpeedKnots > 17 && windSpeedKnots <= 22){
    windBarbIcon = Image.asset('assets/images/windbarbs/wind-speed-18-22.png');
  }else if(windSpeedKnots > 22 && windSpeedKnots <= 27){
    windBarbIcon = Image.asset('assets/images/windbarbs/wind-speed-23-27.png');
  }else if(windSpeedKnots > 27 && windSpeedKnots <= 32){
    windBarbIcon = Image.asset('assets/images/windbarbs/wind-speed-28-32.png');
  }else if(windSpeedKnots > 32 && windSpeedKnots <= 37){
    windBarbIcon = Image.asset('assets/images/windbarbs/wind-speed-33-37.png');
  }else if(windSpeedKnots > 37 && windSpeedKnots <= 42){
    windBarbIcon = Image.asset('assets/images/windbarbs/wind-speed-38-42.png');
  }else if(windSpeedKnots > 42 && windSpeedKnots <= 47){
    windBarbIcon = Image.asset('assets/images/windbarbs/wind-speed-43-47.png');
  }else if(windSpeedKnots > 47 && windSpeedKnots <= 52){
    windBarbIcon = Image.asset('assets/images/windbarbs/wind-speed-48-52.png');
  }else if(windSpeedKnots > 52 && windSpeedKnots <= 57){
    windBarbIcon = Image.asset('assets/images/windbarbs/wind-speed-53-57.png');
  }else if(windSpeedKnots > 57 && windSpeedKnots <= 62){
    windBarbIcon = Image.asset('assets/images/windbarbs/wind-speed-58-62.png');
  }else if(windSpeedKnots > 62 && windSpeedKnots <= 67){
    windBarbIcon = Image.asset('assets/images/windbarbs/wind-speed-63-67.png');
  }else if(windSpeedKnots > 67 && windSpeedKnots <= 72){
    windBarbIcon = Image.asset('assets/images/windbarbs/wind-speed-68-72.png');
  }else if(windSpeedKnots > 72 && windSpeedKnots <= 77){
    windBarbIcon = Image.asset('assets/images/windbarbs/wind-speed-73-77.png');
  }else if(windSpeedKnots > 77 && windSpeedKnots <= 82){
    windBarbIcon = Image.asset('assets/images/windbarbs/wind-speed-78-82.png');
  }else if(windSpeedKnots > 82 && windSpeedKnots <= 87){
    windBarbIcon = Image.asset('assets/images/windbarbs/wind-speed-83-87.png');
  }else if(windSpeedKnots > 87 && windSpeedKnots <= 92){
    windBarbIcon = Image.asset('assets/images/windbarbs/wind-speed-88-92.png');
  }else if(windSpeedKnots > 92 && windSpeedKnots <= 97){
    windBarbIcon = Image.asset('assets/images/windbarbs/wind-speed-93-97.png');
  }else if(windSpeedKnots > 97 && windSpeedKnots <= 102){
    windBarbIcon = Image.asset('assets/images/windbarbs/wind-speed-98-102.png');
  }else {
    windBarbIcon = Image.asset('assets/images/windbarbs/wind-speed-103-107.png');
  }
  return windBarbIcon;
}
