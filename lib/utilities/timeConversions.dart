// Converts UTC time to local 12hr time format "MMMd h:mm a)
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:lat_lng_to_timezone/lat_lng_to_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;


String convertUTCToLocalTimeMMMd (String time) => DateFormat.MMMEd().add_jm().format(DateTime.parse(time).toLocal());

DateTime convertUTCtoDateTime (String time) => DateTime.parse(time).toLocal();

DateTime convertEpochToLocalTime (int time) => DateTime.fromMillisecondsSinceEpoch(time * 1000).toLocal();

int convertUTCtoEpoch (String time) => DateTime.parse(time).millisecondsSinceEpoch ~/ 1000;

int convertDateTimeToEpoch (DateTime time) => time.millisecondsSinceEpoch ~/ 1000;

DateTime convertEpochToDateTime (int time) => DateTime.fromMillisecondsSinceEpoch(time * 1000);

DateTime convertToLocationLocalTime (String lat, String long, int time) {

  // initialize the timezone database
  tz.initializeTimeZones();

  // get time zone from coordinates
  final timeZone = tz.getLocation(latLngToTimezoneString(double.parse(lat), double.parse(long)));

  // convert epoch time to DateTime
  var utcTime = convertEpochToDateTime(time);

  // return the coordinates local time
  return tz.TZDateTime.from(utcTime, timeZone);

}

String dateTimeToHumanReadable (DateTime time) => DateFormat.MMMEd().add_jm().format(time);


String convertEpochTimeTo12Hour (int time) => (DateFormat.jm().format(DateTime.fromMillisecondsSinceEpoch(time * 1000))).toString();