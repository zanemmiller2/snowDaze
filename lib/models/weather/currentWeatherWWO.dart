// Project imports:
import 'currentWeather.dart';

class ForecastWeatherWWO {
  List<dynamic> dailyWeather;
  int lastUpdated;
  List alerts;
  String latitude;
  String longitude;
  late CurrentWeather detailedLocationForecastData;


  ForecastWeatherWWO(
      {
        required this.alerts,
        required this.latitude,
        required this.longitude,
        required this.dailyWeather,
        required this.lastUpdated
      });

  // maps the current weather forecast response from OpenWeatherAPI to a CurrentWeather class object
  factory ForecastWeatherWWO.fromJson(Map<dynamic, dynamic> json, latitude, longitude, alerts) {

    return ForecastWeatherWWO(
      dailyWeather: json['data']['weather'],
      lastUpdated: json['lastUpdated'] ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
      alerts: json['alerts'] ?? alerts,
      latitude: json['latitude'] ?? latitude,
      longitude: json['longitude'] ?? longitude
    );
  }
}
