// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

// Project imports:
import 'package:snow_daze/auth/secrets.dart';
import '../models/weather/currentWeather.dart';

class OpenWeather {
  String latitude;
  String longitude;
  String? language;
  String? units;
  List? excludedList;
  String? currentWeatherURL;

  OpenWeather({required this.latitude, required this.longitude});


  Future<String> getCurrentWeatherAPIUrl(
      {required String latitude,
        required String longitude,
        List<String> excludeList = const [],
        String language = 'en',
        String units = 'imperial'}) async {
    /// getCurrentWeatherAPIUrl function builds the API url for current weather and forecast

    // make uri with exclusion parameters omitted
    if (excludeList.isNotEmpty) {
      var currentWeatherURL =
          'https://api.openweathermap.org/data/3.0/onecall?lat=$latitude&lon=$longitude&lang=$language&units=$units&appid=$openWeatherAPIKey';
      return currentWeatherURL;
    }

    // include exclusion parameters by converting the list to a string
    var currentWeatherURL = 'https://api.openweathermap.org/data/3.0/onecall?'
        'lat=$latitude&lon=$longitude'
        '&lang=$language&units=$units'
        '&exclude=${excludeList.join()}&appid=$openWeatherAPIKey';

    return currentWeatherURL;
  }

  String getHistoricalWeatherAPIUrl(
      {required String latitude,
        required String longitude,
        required int unixTime,
        String language = 'en',
        String units = 'imperial'}) {
    /// getHistoricalWeatherAPIUrl function builds the API url for historical weather data for specified unix time

    // if the requested time is earlier than the first available time use the openWeather default first date (Jan 1, 1979)
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

  Future<CurrentWeather> fetchCurrentWeatherForecast(
      String currentWeatherURL) async {
    /// Fetches the Current Detailed Weather Forecast from the specified URL
    int _retryRequestCounter = 0;
    var response = await http.get(Uri.parse(currentWeatherURL));

    if (response.statusCode == 200) {
      await loadToWeatherForecastsDb(response.body);
      return CurrentWeather.fromJson(jsonDecode(response.body));
    }

    // Incorrect API Key
    if (response.statusCode == 401) {
      print('${response.statusCode} -- Wrong API Key');

      // Incorrect city, zip or ID
    } else if (response.statusCode == 404) {
      print(
          '${response.statusCode} -- API format incorrect or wrong city name, ZIP-code or city ID Specified.');

      // Exceeded call limit
    } else if (response.statusCode == 429) {
      print(
          '${response.statusCode} -- Exceeded the number of allowed API Calls per minute.');

      // Server error response - retry the request
    } else if (response.statusCode >= 500) {
      _retryRequestCounter++;
      retryFutureRequest(fetchCurrentWeatherForecast(currentWeatherURL), 1000);
      if (_retryRequestCounter > 5) {
        print(
            '${response.statusCode} -- unresolved after $_retryRequestCounter attempts');
      }
    }
    // get from database when there is an error with the URL
    return fetchCurrentWeatherForecastFromFirestore();
  }

  retryFutureRequest(future, delay) {
    /// helper to resend http request if fails
    Future.delayed(Duration(milliseconds: delay), () {
      future();
    });
  }

  Future<CurrentWeather> fetchCurrentWeatherForecastFromFirestore() async {
    /// Fetches the Current Weather Forecast from Firestore
    DocumentSnapshot detailedLocationForecastFromDb;

      detailedLocationForecastFromDb = await FirebaseFirestore.instance.collection('weather_forecasts')
          .doc('$latitude$longitude')
          .get();

      return CurrentWeather.fromJson(detailedLocationForecastFromDb.data() as Map);
  }

  Future<bool> checkIfDocExistsForLocation() async {
    /// Checks if the document exists in the weather_forecast collection and returns a boolean value
    DocumentSnapshot detailedLocationForecastFromDb;
    detailedLocationForecastFromDb = await FirebaseFirestore.instance.collection('weather_forecasts')
        .doc('$latitude$longitude')
        .get();

    return detailedLocationForecastFromDb.exists;
  }

  Future<void> loadToWeatherForecastsDb(String jsonData) async {
    /// Loads the weather forecast into the Firestore collection weather_forecasts
    CollectionReference weatherForecasts =
    FirebaseFirestore.instance.collection('weather_forecasts');
    var weatherForecastMap = jsonDecode(jsonData);
    weatherForecastMap['lastUpdated'] = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await weatherForecasts
        .doc('${weatherForecastMap['lat']}${weatherForecastMap['lon']}')
        .set(weatherForecastMap);
  }
}
