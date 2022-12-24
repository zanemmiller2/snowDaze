// Converts UTC time to local 12hr time format "MMMd h:mm a)
import 'dart:convert';

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
