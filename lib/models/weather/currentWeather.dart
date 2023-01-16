/// Class model for current weather and forecast
class CurrentWeather {
  /// Current Weather class that maps OpenWeather API/Firestore weather_forecast document data
  String lat;
  String lon;
  String timezone; // timezone name for the requested location
  int timezone_offset; // shift in seconds from UTC
  Map current = {};
  int lastUpdated;
  List<dynamic> minutely = [];
  List<dynamic> hourly = [];
  List<dynamic> daily = [];
  List<dynamic> alerts = [];

  CurrentWeather(
      {required this.lat,
        required this.lon,
        required this.timezone,
        required this.timezone_offset,
        required this.current,
        required this.minutely,
        required this.hourly,
        required this.daily,
        required this.alerts,
        required this.lastUpdated});

  // maps the current weather forecast response from OpenWeatherAPI to a CurrentWeather class object
  factory CurrentWeather.fromJson(Map<dynamic, dynamic> json) {

    return CurrentWeather(
        lat: json['lat'].toString(),
        lon: json['lon'].toString(),
        timezone: json['timezone'] as String,
        timezone_offset: json['timezone_offset'] as int,
        current: json['current'],
        minutely: json['minutely'],
        hourly: json['hourly'],
        daily: json['daily'],
        alerts: json['alerts'] ?? [],
        lastUpdated: json['lastUpdated'] ?? DateTime.now().millisecondsSinceEpoch ~/ 1000
    );
  }
}