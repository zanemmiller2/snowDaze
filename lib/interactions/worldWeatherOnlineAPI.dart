// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

// Project imports:
import 'package:snow_daze/auth/secrets.dart';
import '../models/weather/currentWeather.dart';
import '../models/weather/currentWeatherWWO.dart';
import 'openWeatherClass.dart';

class WorldWeatherClass {
  String latitude;
  String longitude;
  String resortName;
  late CurrentWeather detailedLocationForecastData;

  WorldWeatherClass({required this.latitude, required this.longitude, required this.resortName});

  Future<String> getCurrentWeatherAPIUrl() async {
    return 'https://api.worldweatheronline.com/premium/v1/ski.ashx?key=$worldWeatherOnlineAPIKey&q=$latitude,$longitude&format=json';
  }

  Future<String> getHistoricalWeatherAPIUrl(String startDate, String endDate) async {
    return 'https://api.worldweatheronline.com/premium/v1/past-weather.ashx?key=$worldWeatherOnlineAPIKey&q=$latitude,$longitude&date=$startDate&enddate=$endDate&format=json';
  }

  Future<ForecastWeatherWWO> fetchCurrentWeatherForecast(String currentWeatherURL) async {
    int retryRequestCounter = 0;
    var response = await http.get(Uri.parse(currentWeatherURL));
    if (response.statusCode == 200) {
      await loadToWeatherForecastsDb(response.body);
      var tempAlerts = await getForecastAlerts();
      return ForecastWeatherWWO.fromJson(jsonDecode(response.body), latitude, longitude, tempAlerts);
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
      retryRequestCounter++;
      retryFutureRequest(fetchCurrentWeatherForecast(currentWeatherURL), 1000);
      if (retryRequestCounter > 5) {
        print(
            '${response.statusCode} -- unresolved after $retryRequestCounter attempts');
      }
    }
    // get from database when there is an error with the URL
    return fetchCurrentWeatherForecastFromFirestore();
  }

// helper to resend http request if fails
  retryFutureRequest(future, delay) {
    Future.delayed(Duration(milliseconds: delay), () {
      future();
    });
  }

  Future<void> loadToWeatherForecastsDb(String jsonData) async {
    /// Loads the weather forecast into the Firestore collection weather_forecasts
    CollectionReference weatherForecasts = FirebaseFirestore.instance.collection('weather_forecasts');
    var weatherForecastMap = jsonDecode(jsonData);
    weatherForecastMap['latitude'] = latitude;
    weatherForecastMap['longitude'] = longitude;
    weatherForecastMap['lastUpdated'] = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    weatherForecastMap['alerts'] = await getForecastAlerts();
    await weatherForecasts
        .doc(resortName)
        .set(weatherForecastMap);
  }

  Future<bool> checkIfDocExistsForLocation() async {
    /// Checks if the document exists in the weather_forecast collection and returns a boolean value
    DocumentSnapshot detailedLocationForecastFromDb;
    detailedLocationForecastFromDb = await FirebaseFirestore.instance.collection('weather_forecasts')
        .doc(resortName)
        .get();

    return detailedLocationForecastFromDb.exists;
  }

  Future<ForecastWeatherWWO> fetchCurrentWeatherForecastFromFirestore() async {
    /// Fetches the Current Weather Forecast from Firestore
    DocumentSnapshot detailedLocationForecastFromDb;

    detailedLocationForecastFromDb = await FirebaseFirestore.instance.collection('weather_forecasts')
        .doc(resortName)
        .get();
    var tempAlerts = await getForecastAlerts();
    return ForecastWeatherWWO.fromJson(detailedLocationForecastFromDb.data() as Map, latitude, longitude, tempAlerts);
  }

  Future<List> getForecastAlerts () async {
    OpenWeather openWeatherClass = OpenWeather(latitude: latitude, longitude: longitude);
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
                latitude: latitude, longitude: longitude));
        print('USING DATA FROM API');
      }

      // Data doesn't currently exist in the database ... use the data from the API Call
    } else {
      detailedLocationForecastData =
      await openWeatherClass.fetchCurrentWeatherForecast(
          await openWeatherClass.getCurrentWeatherAPIUrl(
              latitude: latitude, longitude: longitude));
      print('Getting ALERTS from Open Weather API');
    }
    return detailedLocationForecastData.alerts;
  }

}
