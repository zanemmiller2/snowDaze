import 'package:snow_daze/auth/secrets.dart';
import 'package:http/http.dart' as http;

import '../services/debugLogFunction.dart';

String worldWeatherOnlineForecastRequestURL(String latitude, String longitude) {
  return 'https://api.worldweatheronline.com/premium/v1/ski.ashx?key=$worldWeatherOnlineAPIKey&q=$latitude,$longitude&format=json';
}

String worldWeatherOnlinePastWeatherRequestURL(
    String latitude, String longitude, String startDate, String endDate) {
  return 'https://api.worldweatheronline.com/premium/v1/past-weather.ashx?key=$worldWeatherOnlineAPIKey&q=$latitude,$longitude&date=$startDate&enddate=$endDate&format=json';
}

Future<void> getWorldWeatherOnlineWeatherData(String getRequestURL) async {
  bool requestSuccess = false;
  try {
    final response = await http.get(Uri.parse(getRequestURL));
    // success
    if (kDebugMode) {
      log("REASON PHRASE ${response.request}");
    }
    if (response.statusCode == 200) {
      print(response.body);
    }
  } catch (e) {
    if (requestSuccess == false) {
      if (kDebugMode) {
        log("####################  ERROR: $e");
      }
      retryFutureRequest(getWorldWeatherOnlineWeatherData(getRequestURL), 1000);
    }
  }
}

// helper to resend http request if fails
retryFutureRequest(future, delay) {
  Future.delayed(Duration(milliseconds: delay), () {
    future();
  });
}

void main() {
  String latitude = '39.2875';
  String longitude = '-120.1047';
  String startDate = '2022-12-30';
  String endDate = '2023-01-02';
  // getWorldWeatherOnlineWeatherData(worldWeatherOnlineForecastRequestURL(latitude, longitude));
  getWorldWeatherOnlineWeatherData(worldWeatherOnlinePastWeatherRequestURL(
      latitude, longitude, startDate, endDate));
}
