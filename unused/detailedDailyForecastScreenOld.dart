
import 'dart:math';

import 'package:flutter/material.dart';

import '../lib/utilities/unitConverters.dart';

class DailyDetailedWeatherView extends StatelessWidget {

  final Map dailyDetailedLocationForecastData;
  final Map dailyDetailedLocationForecastDataWWO;
  final String resortName;
  final int index;
  const DailyDetailedWeatherView({super.key, required this.dailyDetailedLocationForecastData, required this.dailyDetailedLocationForecastDataWWO, required this.resortName, required this.index});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(title: Text('$resortName Detailed')),
      body: GridView(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        children: [
          // Weather, Precipitation (probability, rain/snow)
          weatherDetailWidget(),
          // Temperature
          temperatureDetailWidget(),
          // // Feels Like
          // feelsLikeDetailWidget(),
          // // UVI
          // uvIndexDetailWidget(),
          // // Clouds
          // cloudsDetailWidget(),
          // // Wind
          // windDetailWidget(),
          // // Dew point
          // dewPointDetailWidget(),
          // // Pressure
          // airPressureDetailWidget(),
          // // Humidity
          // humidityDetailWidget(),
          // // Sunset/Sunrise
          // sunRiseSunSetDetailWidget(),
          // // Moonset/Moonrise
          // moonRiseSunSetDetailWidget(),
          // // Moon Phase
          // moonPhaseDetailWidget(),
      ],)
    );
  }

  Widget temperatureDetailWidget () {
    return Card (
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text('Temperature'),
          Image.asset('assets/images/fahrenheit_gradient_icon.png'),
          Text('Base Minimum: ${dailyDetailedLocationForecastData['bottom'][0]['mintempF']}\u{00B0}'),
          Text('Base Maximum: ${dailyDetailedLocationForecastData['bottom'][0]['maxtempF']}\u{00B0}'),
          Text('Mid Mountain Minimum: ${dailyDetailedLocationForecastData['mid'][0]['mintempF']}\u{00B0}'),
          Text('Mid Mountain Maximum:     ${dailyDetailedLocationForecastData['mid'][0]['maxtempF']}\u{00B0}'),
          Text('Top Mountain Minimum: ${dailyDetailedLocationForecastData['top'][0]['mintempF']}\u{00B0}'),
          Text('Top Mountain Maximum:   ${dailyDetailedLocationForecastData['mid'][0]['maxtempF']}\u{00B0}'),
        ],
      ),
    );
  }

  Widget weatherDetailWidget () {
    /// Card with weather_icon, weather description, precipitation amount, precipitation probability

    List precipitation = getDailyPrecipitation(dailyDetailedLocationForecastData);
    String weatherType = precipitation[0];
    String dailyQpf = precipitation[1];

    Image weatherIcon;
    if(weatherType == 'Snow') {
      weatherIcon = Image.asset('assets/images/snow_gradient_icon.png');
    } else if(weatherType == 'Rain') {
      weatherIcon = Image.asset('assets/images/rain_gradient_icon.png');
    } else {
      weatherIcon = Image.asset('assets/images/umbrella_gradient_icon.png');
    }

    if(dailyQpf == '1.0') {
      dailyQpf = '$dailyQpf inch';
    } else {
      dailyQpf = '$dailyQpf inches';
    }

    return Card (
      child: Column (
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text('Weather'),
          weatherIcon,
          Text('${(dailyDetailedLocationForecastData['pop'] * 100).toString()} %'),
          Text(dailyDetailedLocationForecastData['weather'][0]['description']),
          Text(dailyQpf),
        ],
      )
    );
  }

  Widget feelsLikeDetailWidget () {
    // returns the feelsLike widget with morning, day, evening, night temperatures and icon
    return Card (
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text('Wind Chill'),
          Image.asset('assets/images/wind_gradient_icon.png'),
          Text('Morning: ${dailyDetailedLocationForecastData['feels_like']['morn'].toString()}\u{00B0}'),
          Text('Day:     ${dailyDetailedLocationForecastData['feels_like']['day'].toString()}\u{00B0}'),
          Text('Evening: ${dailyDetailedLocationForecastData['feels_like']['eve'].toString()}\u{00B0}'),
          Text('Night:   ${dailyDetailedLocationForecastData['feels_like']['night'].toString()}\u{00B0}'),
        ],
      ),
    );
  }

  Widget uvIndexDetailWidget () {
    /// returns the uv widget with index, color, level and icon
    num uvi = dailyDetailedLocationForecastData['uvi'];
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
            getCloudsIcon(dailyDetailedLocationForecastData, index),
            Text('Coverage: ${dailyDetailedLocationForecastData['clouds'].toString()} %'),
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
            angle: (dailyDetailedLocationForecastData['wind_deg'] + 90.0) * (pi / 180),
            child: getWindBarb(dailyDetailedLocationForecastData)
          ),
          Text('Wind Speed: ${dailyDetailedLocationForecastData['wind_speed']} mph ${getWindDirectionFromDeg(dailyDetailedLocationForecastData['wind_deg'])}'),
          Text('Wind Gusts: ${dailyDetailedLocationForecastData['wind_gust']} mph'),
        ],
      ),
    );
  }

  Widget dewPointDetailWidget () {
    /// returns the dew point daily detail with icon and dew point value
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text('Dew Point'),
          Image.asset('assets/images/dew_point_gradient_icon.png'),
          Text('Dew Point: ${dailyDetailedLocationForecastData['dew_point'].toString()}\u{00B0}'),
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
          Text('Air Pressure: ${converthPaToInHg(dailyDetailedLocationForecastData['pressure']).toStringAsFixed(1)} inHg'),
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
          Text('Humidity: ${dailyDetailedLocationForecastData['humidity']} %'),
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
          Text('Sunrise: ${convertEpochTimeTo12Hour(dailyDetailedLocationForecastData['sunrise'])}'),
          const Text('Sunset'),
          Image.asset('assets/images/sunset_gradient_icon.png'),
          Text('Sunrise: ${convertEpochTimeTo12Hour(dailyDetailedLocationForecastData['sunset'])}'),
        ],
      ),
    );
  }

  Widget moonRiseSunSetDetailWidget () {
    /// returns the moonrise and moonset daily detail with icon and times
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text('Moonrise'),
          Image.asset('assets/images/moonrise_gradient_icon.png'),
          Text('Sunrise: ${convertEpochTimeTo12Hour(dailyDetailedLocationForecastData['moonrise'])}'),
          const Text('Moonset'),
          Image.asset('assets/images/moonset_gradient_icon.png'),
          Text('Sunrise: ${convertEpochTimeTo12Hour(dailyDetailedLocationForecastData['moonset'])}'),
        ],
      ),
    );
  }

  Widget moonPhaseDetailWidget () {
    /// returns the moonphase description and icon
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text('Moon Phase'),
          Image.asset('assets/images/full_moon_gradient_icon.png'),
          Text(getMoonPhaseFromPercent(dailyDetailedLocationForecastData['moon_phase'])),
        ],
      ),
    );
  }


}

List<String> getDailyPrecipitation(dailyDetailedLocationForecastData) {
  /// gets daily precipitation totals in mm and returns total in inches

  // get the days rain total in mm and convert to inches
  String? precipitationRainQpf =
  convertMmToIn(dailyDetailedLocationForecastData['rain'] ?? 0.0)
      .toString();
  // get the days rain total in mm and convert to inches
  String? precipitationSnowQpf =
  convertMmToIn(dailyDetailedLocationForecastData['snow'] ?? 0.0)
      .toString();

  String? dailyQpf = '0.0';
  String? weatherType;
  // snow and rain count as snow only in mountains
  if (double.parse(precipitationRainQpf) > 0.0 &&
      double.parse(precipitationSnowQpf) > 0.0) {
    double tempSnow =
        double.parse(precipitationSnowQpf) + double.parse(precipitationRainQpf);
    dailyQpf = tempSnow.toString();
    weatherType = 'Snow';
  }
  // rain only
  else if (double.parse(precipitationRainQpf) > 0.0 &&
      double.parse(precipitationSnowQpf) <= 0.0) {
    dailyQpf = precipitationRainQpf;
    weatherType = 'Rain';
    // Snow only
  } else if (double.parse(precipitationRainQpf) <= 0.0 &&
      double.parse(precipitationSnowQpf) > 0.0) {
    dailyQpf = precipitationSnowQpf;
    weatherType = 'Snow';
    // no snow and no rain
  } else {
    dailyQpf = '0.0';
    weatherType = 'No rain or snow';
  }

  return [weatherType, dailyQpf];
}

Image getCloudsIcon(dailyDetailedLocationForecastData, index) {
  /// assigns the cloudIcon based on coverage % and time of day
  Image cloudIcon;
  if (index == 0) {
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
  }
  else {
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