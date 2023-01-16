import 'package:snow_daze/utilities/unitConverters.dart';

String getPrevious3DaysSnowFall (previousWeatherData) {
  /// Sums up the snowfall in cm from the last 3 days, converts to inches and returns as a string
  num previous3DaySnowfallTotal = 0.0;
  for(var day in previousWeatherData) {
    previous3DaySnowfallTotal += double.parse(day['totalSnow_cm']);
  }

  return convertCmToIn(previous3DaySnowfallTotal).toString();

}