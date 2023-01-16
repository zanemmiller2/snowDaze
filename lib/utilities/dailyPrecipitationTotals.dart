import 'package:snow_daze/utilities/unitConverters.dart';

List<String> getDailyPrecipitation(detailedLocationForecastData, index) {
  /// gets daily precipitation totals in mm and returns total in inches

  // get the days rain total in mm and convert to inches
  String? precipitationRainQpf = convertMmToIn(double.parse(
      detailedLocationForecastData[index]['precipMM'] ?? '0.0'))
      .toString();
  // get the days rain total in mm and convert to inches
  String? precipitationSnowQpf = convertCmToIn(double.parse(
      detailedLocationForecastData[index]['totalSnowfall_cm'] ?? '0.0') * 0.65)
      .toString();

  String? dailyQpf = '0.0';
  String? weatherType;

  // snow and rain count as snow only in mountains
  if (double.parse(precipitationRainQpf) > 0.0 &&
      double.parse(precipitationSnowQpf) > 0.0) {
    dailyQpf = precipitationSnowQpf.toString();
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