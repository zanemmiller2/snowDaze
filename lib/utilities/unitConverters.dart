// Converts UTC time to local 12hr time format "MMMd h:mm a)

// Dart imports:
import 'dart:ui';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';
import 'package:lat_lng_to_timezone/lat_lng_to_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// String UTC
/// DateTime DateTime
/// int Epoch

String convertUTCToLocalTimeMMMd(String time) {
  /// String '2022-12-24T12:54:51Z' => String 'DEC 24, 2022'
  return DateFormat.MMMEd().add_jm().format(DateTime.parse(time).toLocal());
}

DateTime convertUTCtoDateTime(String time) {
  /// String '2022-12-24T12:54:51Z' => DateTime()
  return DateTime.parse(time).toLocal();
}

DateTime convertToLocationLocalTime(String lat, String long, int time) {
  /// Receives (int EpochTime, latitude, and longitude),
  /// gets the locations time zone from (lat, long) and
  /// returns the time as a DateTime() object local to the coordinates time zone.

  // initialize the timezone database
  tz.initializeTimeZones();

  // get time zone from coordinates
  final timeZone = tz.getLocation(
      latLngToTimezoneString(double.parse(lat), double.parse(long)));

  // convert epoch time to DateTime
  var utcTime = convertEpochToDateTime(time);

  // return the coordinates local time
  return tz.TZDateTime.from(utcTime, timeZone);
}

int convertUTCtoEpoch(String time) {
  /// '2022-12-24T12:54:51Z' => int 1671886491
  return DateTime.parse(time).millisecondsSinceEpoch ~/ 1000;
}

DateTime convertEpochToLocalTime(int time) {
  /// int 1671886491 => DateTime(systemLocal)
  return DateTime.fromMillisecondsSinceEpoch(time * 1000).toLocal();
}

DateTime convertEpochToDateTime(int time) {
  /// int 1671886491 => DateTime()
  return DateTime.fromMillisecondsSinceEpoch(time * 1000);
}

String convertEpochTimeTo12Hour(int time) {
  /// int 1671886491 => '4:54 AM'
  return (DateFormat.jm().format(DateTime.fromMillisecondsSinceEpoch(time * 1000)))
        .toString();
}

int convertDateTimeToEpoch(DateTime time) {
  /// DateTime() => int 1671886491
  return time.millisecondsSinceEpoch ~/ 1000;
}

String dateTimeToHumanReadable(DateTime time) {
  /// DateTime() => 'Mon, Jan 1 12:01 AM'
  return DateFormat.MMMEd().add_jm().format(time);
}

double convertMetersToMiles(num meters) {
  /// Convert meters to miles = (meters * 0.000621371)
  return meters * 0.000621371;
}

double converthPaToInHg (num hpa) {
  /// Converts pressure in hPa to InHg = (hPa * 0.02953)
  return hpa * 0.02953;
}

double convertMmToIn(qpf) {
  /// converts a double mm measurement to double inches
  return (qpf / 25.4).ceil().toDouble();
}

double convertCmToIn(qpf) {
  /// converts Cm to In = (cm / 2.54) rounded up
  return (qpf / 2.54).ceil().toDouble();
}

DateTime convertYYYMMDDToDateTime(String date) {
  /// Converts string YYYY-MM-DD to DateTime Object
  return DateTime.parse(date);
}

String convertDateTimeToYYYMMDD(DateTime date) {
  /// Converts DateTimeObject to String formatted YYYY-MM-DD
  DateTime shortenedTime = DateTime(date.year, date.month, date.day);
  String stringTime = shortenedTime.toUtc().toString();
  stringTime = stringTime.split(' ')[0];
  return stringTime;

}

double convertMphToKnots(num windSpeed) {
  /// Converts MpH to Knots = (mph * 0.868976)
  return windSpeed * 0.868976;
}

Color uvColor(uvi) {
  /// returns the uv level color
  if (uvi <= 2) {
    return Colors.green;
  } else if (2 < uvi && uvi <= 5) {
    return Colors.yellow;
  } else if (5 < uvi && uvi <= 7) {
    return Colors.orange;
  } else if (7 < uvi && uvi <= 10) {
    return Colors.red;
  } else {
    return Colors.purple;
  }
}

String uvLevel(uvi) {
  /// Converts uv index into uv level
  if (uvi <= 2) {
    return 'Low';
  } else if (2 < uvi && uvi <= 5) {
    return 'Moderate';
  } else if (5 < uvi && uvi <= 7) {
    return 'High';
  } else if (7 < uvi && uvi <= 10) {
    return 'Very High';
  } else {
    return 'Extreme';
  }
}

String getWindDirectionFromDeg(windDeg) {
  if((windDeg >= 0 && windDeg <= 11.25) || (windDeg <= 360 && windDeg > 348.75)) {
    return 'N';
  } else if(windDeg > 11.25 && windDeg <= 33.75) {
    return 'NNE';
  } else if(windDeg > 33.75 && windDeg <= 56.25) {
    return 'NE';
  } else if(windDeg > 56.25 && windDeg <= 78.75) {
    return 'ENE';
  } else if(windDeg > 78.75 && windDeg <= 101.25) {
    return 'E';
  } else if(windDeg > 101.25 && windDeg <= 123.75) {
    return 'ESE';
  } else if(windDeg > 123.75 && windDeg <= 146.25) {
    return 'SE';
  } else if(windDeg > 146.25 && windDeg <= 168.75) {
    return 'SSE';
  } else if(windDeg > 168.75 && windDeg <= 191.25) {
    return 'S';
  } else if(windDeg > 191.25 && windDeg <= 213.75) {
    return 'SSW';
  } else if(windDeg > 213.75 && windDeg <= 236.25) {
    return 'SW';
  } else if(windDeg > 236.25 && windDeg <= 258.75) {
    return 'WSW';
  } else if(windDeg > 258.75 && windDeg <= 281.25) {
    return 'W';
  } else if(windDeg > 281.25 && windDeg <= 303.75) {
    return 'WNW';
  } else if(windDeg > 303.75 && windDeg <= 326.25) {
    return 'NW';
  } else {
    return 'NNW';
  }
}

String getMoonPhaseFromPercent(moonPhase) {
  if(moonPhase == 1 || moonPhase == 0) {
    return 'New Moon';
  } else if(moonPhase > 0 && moonPhase < 0.25) {
    return 'Waxing Crescent Moon';
  } else if(moonPhase == 0.25) {
    return 'First Quarter Moon';
  } else if(moonPhase > 0.25 && moonPhase < 0.5) {
    return 'Waxing Gibbous Moon';
  }else if(moonPhase == 0.5) {
    return 'Full Moon';
  } else if(moonPhase > 0.5 && moonPhase < 0.75) {
    return 'Waning Gibbous Moon';
  } else if(moonPhase == 0.75) {
    return 'Last Quarter Moon';
  }  else{
    return 'Waning Crescent Moon';
  }
}

String convertMetersToFeet (String meters) {
  return ((double.parse(meters) * 3.28084 / 100).ceil() * 100).toString();
}

void main() {
  DateTime timeNow = DateTime.now();
  convertDateTimeToYYYMMDD(DateTime(timeNow.year, timeNow.month, timeNow.day - 3));
  convertDateTimeToYYYMMDD(DateTime(timeNow.year, timeNow.month, timeNow.day));

  // DateTime DateTimeTime = DateTime.now();
  // String UTCTime = '2022-12-24T12:54:51Z';
  // int EpochTime = 1671886491;
  // String lat = '40.7128';
  // String long = '-74.0060';
  //
  // print(convertUTCToLocalTimeMMMd(UTCTime)); // 'Sat, Dec 24 4:54 AM'
  // print(convertUTCtoDateTime(UTCTime)); // DateTime 2022-12-24 04:54:51.000
  // print(convertEpochToLocalTime(
  //     EpochTime)); // DateTime 2022-12-24 04:54:51.000 (System Local)
  // print(convertEpochToDateTime(EpochTime)); // DateTime 2022-12-24 04:54:51.000
  // print(convertUTCtoEpoch(UTCTime)); // 1671886491
  // print(convertDateTimeToEpoch(DateTimeTime)); // 1671887457
  // print(convertToLocationLocalTime(
  //     lat, long, EpochTime)); // DateTime 2022-12-24 07:54:51.000-0500 (EST)
  // print(dateTimeToHumanReadable(DateTimeTime)); // 'Sat, Dec 24 5:10 AM'
  // print(convertEpochTimeTo12Hour(1671886491)); // '4:54 AM'
}
