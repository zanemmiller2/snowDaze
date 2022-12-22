// Converts UTC time to local 12hr time format "MMMd h:mm a)
import 'package:intl/intl.dart';
import 'package:lat_lng_to_timezone/lat_lng_to_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

String convertUTCToLocalTimeMMMd (String time) => DateFormat.MMMd().add_jm().format(DateTime.parse(time).toLocal());

DateTime convertEpochToLocalTime (int time) => DateTime.fromMillisecondsSinceEpoch(time * 1000).toLocal();

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
