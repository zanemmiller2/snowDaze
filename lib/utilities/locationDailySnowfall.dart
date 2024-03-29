// Dart imports:
import 'dart:async';

// Project imports:
import '../interactions/nwsWeatherClass.dart';

Future<double> nwsLocationDailySnowfall (DateTime startTime, String latitude, String longitude) async {
  /// calculates the daily snowfall for the specified day

  // get map of hourly data from nws
  NWSWeatherForecast nwsWeatherForecast = NWSWeatherForecast(latitude, longitude);
  await nwsWeatherForecast.initialize();

  List<Map> dailyDetails = [];

  var currentDayKey = nwsWeatherForecast.startTimes[0];
  var nextDayStart = nwsWeatherForecast.startTimes[0].day + 1;
  var currentDayIndex = 0;

  for(int i = 0; i < nwsWeatherForecast.startTimes.length - 1; i++) {

    if(i == 0) {
      dailyDetails.add({nwsWeatherForecast.startTimes[i] : {"snow": 0.0, "rain": 0.0}});
    }

    // add to current days total
    if(nwsWeatherForecast.startTimes[i].day < nextDayStart) {
      // day includes snow
      if (nwsWeatherForecast.weatherConditionsType[i].contains('snow') ||
          nwsWeatherForecast.weatherConditionsType[i].contains('Snow')) {
        dailyDetails[currentDayIndex][currentDayKey]['snow'] +=
            nwsWeatherForecast.hourlyQpf[i];
      } else if (nwsWeatherForecast.weatherConditionsType[i].contains('rain')) {
        dailyDetails[currentDayIndex][currentDayKey]['rain'] +=
            nwsWeatherForecast.hourlyQpf[i];
      }
      // Start a new day
    } else {
      currentDayKey = nwsWeatherForecast.startTimes[i];
      nextDayStart = nwsWeatherForecast.startTimes[i].day + 1;
      currentDayIndex++;
      dailyDetails.add({
        nwsWeatherForecast.startTimes[i]: {'snow': 0.0, 'rain': 0.0}
      });

      if (nwsWeatherForecast.weatherConditionsType[i].contains('snow') ||
          nwsWeatherForecast.weatherConditionsType[i].contains('Snow')) {
        dailyDetails[currentDayIndex][currentDayKey]['snow'] +=
            nwsWeatherForecast.hourlyQpf[i];
      } else if (nwsWeatherForecast.weatherConditionsType[i].contains('rain')) {
        dailyDetails[currentDayIndex][currentDayKey]['rain'] +=
            nwsWeatherForecast.hourlyQpf[i];
      }
    }
  }

  // return the snow fall total for that day as predicted in the NWS data
  for (var element in dailyDetails) {
    // print(element.keys);
    for(DateTime key in element.keys) {
      if(key == startTime) {
        return element[key]['snow'];
      }
    }
  }
  return 0.0;
}
