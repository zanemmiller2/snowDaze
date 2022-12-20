

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snow_daze/auth/secrets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/* getCurrentWeatherAPIUrl function builds the API url for current weather and forecast */
Future<String> getCurrentWeatherAPIUrl(
    {required String latitude, required String longitude, List<
        String> excludeList = const [
    ], String language = 'en', String units = 'standard'}) async {
  // no exclusion parameters set
  if (excludeList.isNotEmpty) {
    var currentWeatherURL = 'https://api.openweathermap.org/data/3.0/onecall?lat=$latitude&lon=$longitude&lang=$language&units=$units&appid=$openWeatherAPIKey';
    return await currentWeatherURL;
  }

  // include exclusion parameters
  String excludeParametersString = '';
  for (String parameter in excludeList) {
    excludeParametersString += parameter;
  }

  var currentWeatherURL = 'https://api.openweathermap.org/data/3.0/onecall?'
      'lat=$latitude&lon=$longitude'
      '&lang=$language&units=$units'
      '&exclude=$excludeParametersString&appid=$openWeatherAPIKey';

  return currentWeatherURL;
}

/* getHistoricalWeatherAPIUrl function builds the API url for historical weather data for specified unix time */
String getHistoricalWeatherAPIUrl(
    {required String latitude, required String longitude, required int unixTime, String language = 'en', String units = 'imperial'}) {
  int openWeatherHistoricalStartDate = 284025600;

  if (unixTime <= openWeatherHistoricalStartDate) {
    print('Historical data not available before (January 1, 1979');
    unixTime = openWeatherHistoricalStartDate;
  }

  String historicalWeatherUrl =
      'https://api.openweathermap.org/data/3.0/onecall/timemachine?lat=$latitude&lon=$longitude'
      '&lang=$language&units=$units'
      '&dt=$unixTime&appid=$openWeatherAPIKey';

  return historicalWeatherUrl;
}

Future<CurrentWeather?> fetchCurrentWeatherForecast(
    String currentWeatherURL) async {
  int _retryRequestCounter = 0;
  await http.get(Uri.parse(currentWeatherURL))
      .then((response) {
    // OK
    if (response.statusCode == 200) {
      loadToWeatherForecastsDb(response.body);
      return CurrentWeather.fromJson(jsonDecode(response.body));
    }

    // Incorrect API Key
    if (response.statusCode == 401) {
      print('${response.statusCode} -- Wrong API Key');

      // Incorrect city, zip or ID
    } else if (response.statusCode == 404) {
      print('${response
          .statusCode} -- API format incorrect or wrong city name, ZIP-code or city ID Specified.');

      // Exceeded call limit
    } else if (response.statusCode == 429) {
      print('${response
          .statusCode} -- Exceeded the number of allowed API Calls per minute.');

      // Server error response - retry the request
    } else if (response.statusCode >= 500) {
      _retryRequestCounter ++;
      retryFutureRequest(fetchCurrentWeatherForecast(currentWeatherURL), 1000);
      if (_retryRequestCounter > 5) {
        print('${response
            .statusCode} -- unresolved after $_retryRequestCounter attempts');
      }
    }});
  // On error -- return the last record stored in firestore

  return null;
}

// helper to resend http request if fails
retryFutureRequest(future, delay) {
  Future.delayed(Duration(milliseconds: delay), () {
    future();
  });
}

void loadToWeatherForecastsDb(String jsonData) async {

  CollectionReference weatherForecasts = FirebaseFirestore.instance.collection('weather_forecasts');
  var weatherForecastMap = jsonDecode(jsonData);
  weatherForecastMap['lastUpdated'] = DateTime.now();
  await weatherForecasts
      .doc('${weatherForecastMap['lat']}${weatherForecastMap['lon']}')
      .set(weatherForecastMap);
}


class CurrentWeather {
  String? lat;
  String? lon;
  String? timezone; // timezone name for the requested location
  int? timezone_offset; // shift in seconds from UTC
  List<Map?> current = [];
  List<Map?> minutely = [];
  List<Map?> hourly = [];
  List<Map?> daily = [];
  List<Map?> alerts = [];

  CurrentWeather(
      {required this.lat, required this.lon, required this.timezone, required this.timezone_offset, current, minutely, hourly, daily, alerts});

  // maps the current weather forecast response from OpenWeatherAPI to a CurrentWeather class object
  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
        lat: json['lat'].toString(),
        lon: json['lon'].toString(),
        timezone: json['timezone'] as String,
        timezone_offset: json['timezone_offset'] as int,
        current: json['current'],
        minutely: json['minutely'],
        hourly: json['hourly'],
        daily: json['daily'],
        alerts: json['alerts']
    );
  }

}

class HistoricalWeather {
  String? lat;
  String? lon;
  String? timezone; // timezone name for the requested location
  int? timezone_offset; // shift in seconds from UTC
  Map? data;

  HistoricalWeather(
      {required String this.lat, required String this.lon, required String this.timezone, required int this.timezone_offset, required Map this.data});

  // maps the historical weather response from OpenWeatherAPI to a HistoricalWeather class object
  factory HistoricalWeather.fromJson(Map<String, dynamic> json) {
    return HistoricalWeather(
        lat: json['lat'] as String,
        lon: json['lon'] as String,
        timezone: json['timezone'] as String,
        timezone_offset: json['timezone_offset'] as int,
        data: json['data'] as Map
    );
  }
}

// void main() async {
//   String latitudeCrystal = '46.9401';
//   String longitudeCrystal = '-121.4732';
//   String currentWeatherUrl = getCurrentWeatherAPIUrl(latitude: latitudeCrystal,
//       longitude: longitudeCrystal,
//       language: 'en',
//       units: 'imperial');
//
//
//
// }
