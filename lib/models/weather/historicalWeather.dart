/// Class model for historical weather

class HistoricalWeather {
  String? lat;
  String? lon;
  String? timezone; // timezone name for the requested location
  int? timezone_offset; // shift in seconds from UTC
  Map? data;

  HistoricalWeather(
      {required String this.lat,
        required String this.lon,
        required String this.timezone,
        required int this.timezone_offset,
        required Map this.data});

  // maps the historical weather response from OpenWeatherAPI to a HistoricalWeather class object
  factory HistoricalWeather.fromJson(Map<String, dynamic> json) {
    return HistoricalWeather(
        lat: json['lat'] as String,
        lon: json['lon'] as String,
        timezone: json['timezone'] as String,
        timezone_offset: json['timezone_offset'] as int,
        data: json['data'] as Map);
  }
}