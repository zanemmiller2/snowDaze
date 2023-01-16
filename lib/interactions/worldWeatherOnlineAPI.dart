// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

// Project imports:
import 'package:snow_daze/auth/secrets.dart';
import 'package:snow_daze/utilities/unitConverters.dart';
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

  Future<bool> checkIfDocExistsForLocation() async {
    /// Checks if the document exists in the weather_forecast collection and returns a boolean value
    DocumentSnapshot detailedLocationForecastFromDb;
    detailedLocationForecastFromDb = await FirebaseFirestore.instance.collection('weather_forecasts')
        .doc(resortName)
        .get();

    return detailedLocationForecastFromDb.exists;
  }

  Future<ForecastWeatherWWO> fetchCurrentWeatherForecastFromWWOAPI(String currentWeatherURL) async {
    int retryRequestCounter = 0;
    var response = await http.get(Uri.parse(currentWeatherURL));
    if (response.statusCode == 200) {
      // Store the data in the database
      var tempAlerts = await getForecastAlerts();
      Map<dynamic, dynamic> tempPrevious3DaysWeather = await getPrevious3DayWeather();
      await loadToWeatherForecastsDb(response.body, tempAlerts, tempPrevious3DaysWeather);
      // return the map of the data
      return ForecastWeatherWWO.fromJson(jsonDecode(response.body), latitude, longitude, tempAlerts, tempPrevious3DaysWeather);
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
      retryFutureRequest(fetchCurrentWeatherForecastFromWWOAPI(currentWeatherURL), 1000);
      if (retryRequestCounter > 5) {
        print(
            '${response.statusCode} -- unresolved after $retryRequestCounter attempts');
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

  Future<ForecastWeatherWWO> fetchCurrentWeatherForecastFromFirestore() async {
    /// Fetches the Current Weather Forecast from Firestore
    DocumentSnapshot detailedLocationForecastFromDb;

    detailedLocationForecastFromDb = await FirebaseFirestore.instance.collection('weather_forecasts')
        .doc(resortName)
        .get();

    var tempAlerts = detailedLocationForecastFromDb['alerts'];
    // Get previous 3 days from api
    var tempPrevious3DaysWeather = detailedLocationForecastFromDb['previous3DaysWeather'];

    return ForecastWeatherWWO.fromJson(detailedLocationForecastFromDb.data() as Map, latitude, longitude, tempAlerts, tempPrevious3DaysWeather);
  }

  Future<void> loadToWeatherForecastsDb(String jsonData, alerts, previous3DaysWeather) async {
    /// Loads the weather forecast into the Firestore collection weather_forecasts
    CollectionReference weatherForecasts = FirebaseFirestore.instance.collection('weather_forecasts');
    var weatherForecastMap = jsonDecode(jsonData);
    weatherForecastMap['latitude'] = latitude;
    weatherForecastMap['longitude'] = longitude;
    weatherForecastMap['lastUpdated'] = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    weatherForecastMap['alerts'] = alerts;
    weatherForecastMap['previous3DaysWeather'] = previous3DaysWeather;
    await weatherForecasts
        .doc(resortName)
        .set(weatherForecastMap);
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

        // data was updated more than an hour ago ... use data from API call
      } else {
        detailedLocationForecastData =
        await openWeatherClass.fetchCurrentWeatherForecast(
            await openWeatherClass.getCurrentWeatherAPIUrl(
                latitude: latitude, longitude: longitude));
      }

      // Data doesn't currently exist in the database ... use the data from the API Call
    } else {
      detailedLocationForecastData =
      await openWeatherClass.fetchCurrentWeatherForecast(
          await openWeatherClass.getCurrentWeatherAPIUrl(
              latitude: latitude, longitude: longitude));

    }
    return detailedLocationForecastData.alerts;
  }

  Future <Map> getPrevious3DayWeather () async {
    /// Uses the API call to fetch weather data from the previous 3 days

    // Set start and end time (3 day period ending yesterday)
    DateTime timeNow = DateTime.now();
    String startDate = convertDateTimeToYYYMMDD(DateTime(timeNow.year, timeNow.month, timeNow.day - 3));
    String endDate = convertDateTimeToYYYMMDD(DateTime(timeNow.year, timeNow.month, timeNow.day - 1));

    return jsonDecode((await http.get(Uri.parse(await getHistoricalWeatherAPIUrl(startDate, endDate)))).body);
  }

}
