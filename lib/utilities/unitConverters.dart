// Converts UTC time to local 12hr time format "MMMd h:mm a)
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lat_lng_to_timezone/lat_lng_to_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// String UTC
/// DateTime DateTime
/// int Epoch

String convertUTCToLocalTimeMMMd(String time) =>
    DateFormat.MMMEd().add_jm().format(DateTime.parse(time).toLocal());

/// String '2022-12-24T12:54:51Z' => String 'DEC 24, 2022'

DateTime convertUTCtoDateTime(String time) => DateTime.parse(time).toLocal();

/// String '2022-12-24T12:54:51Z' => DateTime()

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

int convertUTCtoEpoch(String time) =>
    DateTime.parse(time).millisecondsSinceEpoch ~/ 1000;

/// '2022-12-24T12:54:51Z' => int 1671886491

DateTime convertEpochToLocalTime(int time) =>
    DateTime.fromMillisecondsSinceEpoch(time * 1000).toLocal();

/// int 1671886491 => DateTime(systemLocal)

DateTime convertEpochToDateTime(int time) =>
    DateTime.fromMillisecondsSinceEpoch(time * 1000);

/// int 1671886491 => DateTime()

String convertEpochTimeTo12Hour(int time) =>
    (DateFormat.jm().format(DateTime.fromMillisecondsSinceEpoch(time * 1000)))
        .toString();

/// int 1671886491 => '4:54 AM'

int convertDateTimeToEpoch(DateTime time) =>
    time.millisecondsSinceEpoch ~/ 1000;

/// DateTime() => int 1671886491

String dateTimeToHumanReadable(DateTime time) =>
    DateFormat.MMMEd().add_jm().format(time);

/// DateTime() => 'Mon, Jan 1 12:01 AM'

double convertMetersToMiles(num meters) => meters * 0.000621371;

double converthPaToInHg (num hpa) => hpa * 0.02953;

double convertMmToIn(qpf) {
  /// converts a double mm measurement to double inches
  return (qpf / 25.4).ceil().toDouble();
}

double convertCmToIn(qpf) {
  return (qpf / 2.54).ceil().toDouble();
}

DateTime convertYYYMMDDToDateTime(String date) {
  return DateTime.parse(date);
}

double convertMphToKnots(num windSpeed) => windSpeed * 0.868976;

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
  DateTime DateTimeTime = DateTime.now();
  String UTCTime = '2022-12-24T12:54:51Z';
  int EpochTime = 1671886491;
  String lat = '40.7128';
  String long = '-74.0060';

  print(convertUTCToLocalTimeMMMd(UTCTime)); // 'Sat, Dec 24 4:54 AM'
  print(convertUTCtoDateTime(UTCTime)); // DateTime 2022-12-24 04:54:51.000
  print(convertEpochToLocalTime(
      EpochTime)); // DateTime 2022-12-24 04:54:51.000 (System Local)
  print(convertEpochToDateTime(EpochTime)); // DateTime 2022-12-24 04:54:51.000
  print(convertUTCtoEpoch(UTCTime)); // 1671886491
  print(convertDateTimeToEpoch(DateTimeTime)); // 1671887457
  print(convertToLocationLocalTime(
      lat, long, EpochTime)); // DateTime 2022-12-24 07:54:51.000-0500 (EST)
  print(dateTimeToHumanReadable(DateTimeTime)); // 'Sat, Dec 24 5:10 AM'
  print(convertEpochTimeTo12Hour(1671886491)); // '4:54 AM'
}
