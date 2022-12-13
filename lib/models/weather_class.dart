import 'dart:convert';
import 'package:snow_daze/models/weather_forecast.dart';
import 'package:xml2json/xml2json.dart';
import 'package:xml/xml.dart';

import 'package:http/http.dart' as http;

void main() async {
  var latitude = "46.9401";
  var longitude = "-121.4732";
  WeatherForecast weather = WeatherForecast(latitude, longitude);

  await weather.fetchXML();

  /* Meta Data */
  weather.setSourceCredit();
  print("Source Credit: ${weather.sourceCredit}");

  weather.setLayoutKeys();
  print("Time Layout Keys: ${weather.timeLayoutKeys}");

  weather.setStartEndTimes();
  print("Start Times: ${weather.startTimes}");
  print("End Times: ${weather.endTimes}");

  /* Location Data */
  weather.setLatLong();
  print("Latitude: ${weather.latitude}, Longitude: ${weather.longitude}");

  weather.setAreaDescription();
  print("Area Description: ${weather.areaDescription}");

  weather.setElevation();
  print("Elevation: ${weather.elevation} ${weather.elevationUnits}");

  weather.setTemperatures();
  print("Dew Points: ${weather.dewPointTemperatures}");
  print("Wind Chill: ${weather.windChillTemperatures}");
  print("Hourly Temps: ${weather.hourlyTemperatures}");


}

class WeatherForecast {
  XmlDocument? xmlData;
  String? nwsSourceURL;

  /* Meta Data */
  String? sourceCredit;
  List<String> timeLayoutKeys = [];
  List<String> startTimes = [];
  List<String> endTimes = [];

  /* Location Data */
  double? latitude;
  double? longitude;
  String? areaDescription;
  double? elevation;
  String? elevationUnits;

  /* Parameters */
  List<double> dewPointTemperatures = [];
  String dewPointUnits = "Fahrenheit";
  List<double> windChillTemperatures = [];
  String windChillUnits = "Fahrenheit";
  List<double> hourlyTemperatures = [];
  String hourlyTemperatureUnits = "Fahrenheit";


  // Class constructor
  WeatherForecast(String latitude, String longitude) {
    // sets weather forecast source url
    nwsSourceURL =
    "https://forecast.weather.gov/MapClick.php?lat=$latitude&lon=$longitude&FcstType=digitalDWML";
  }


  /*--------------------------------------------------------------------
  * #                                                                  #
  * #                         Converters                               #
  * #                                                                  #
  * --------------------------------------------------------------------*/

  // Get the XML from nws weather source and store in weather.xmlData
  Future<void> fetchXML() async {
    // TODO -- handle error where site returns response.code == 200 but is redirect
    bool requestSuccess = false;
    try {
      final response = await http.get(Uri.parse(nwsSourceURL!));
      // success
      print("REASON PHRASE ${response.request}");
      if (response.statusCode == 200) {
        requestSuccess = true;
        xmlData = XmlDocument.parse(response.body);
      }
    } catch (e) {
      if (requestSuccess == false) {
        print("####################  ERROR: $e");
        retryFutureRequest(fetchXML(), 1000);
      }
    }
  }

  retryFutureRequest(future, delay) {
    Future.delayed(Duration(milliseconds: delay), () {
      future();
    });
  }

  /*--------------------------------------------------------------------
  * #                                                                  #
  * #                         Setters  - MetaData                      #
  * #                                                                  #
  * --------------------------------------------------------------------*/

  // extract and store the source credit
  void setSourceCredit() {
    sourceCredit = (xmlData?.rootElement
        .getElement("head")
        ?.getElement("source")
        ?.getElement("credit")
        ?.text);
  }

  // extract layout keys from xml
  void setLayoutKeys() {
    xmlData?.findAllElements("layout-key").map((node) => node.text)
        .forEach((element) {
      timeLayoutKeys.add(element);
    });
  }

  // extract start and end times from xml
  void setStartEndTimes() {
    // get and store start times
    xmlData?.findAllElements("start-valid-time").map((node) => node.text)
        .forEach((element) {
      startTimes.add(element);
    });

    // get and store end times
    xmlData?.findAllElements("end-valid-time").map((node) => node.text)
        .forEach((element) {
      endTimes.add(element);
    });
  }

  // extract and store latitude and longitude
  void setLatLong() {
    latitude = double.parse(
        xmlData?.rootElement.getElement("data")?.getElement("location")
            ?.getElement("point")
            ?.getAttribute("latitude") as String);
    longitude = double.parse(
        xmlData?.rootElement.getElement("data")?.getElement("location")
            ?.getElement("point")
            ?.getAttribute("longitude") as String);
  }

  // extract and store the area description
  void setAreaDescription() {
    areaDescription = xmlData?.rootElement
        .getElement("data")
        ?.getElement("location")
        ?.getElement("area-description")
        ?.text;
  }

  // extract and store elevation and elevation units
  void setElevation() {
    elevation = double.parse(xmlData?.rootElement
        .getElement("data")
        ?.getElement("location")
        ?.getElement("height")
        ?.text as String);
    elevationUnits =
        xmlData?.rootElement.getElement("data")?.getElement("location")
            ?.getElement("height")
            ?.getAttribute("height-units");
  }

  // extract and store the list of dewPoint,windChill, and hourly temperatures
  void setTemperatures() {
    var tempTemps = xmlData?.findAllElements('temperature');
    for (var temp in tempTemps!) {
      if (temp.getAttribute('type') == 'dew point') {
        temp.findAllElements('value').map((node) => node.text)
            .forEach((element) {
          dewPointTemperatures.add(double.parse(element));
        });
      } else if (temp.getAttribute('type') == 'wind chill') {
        temp.findAllElements('value').map((node) => node.text)
            .forEach((element) {
          windChillTemperatures.add(double.parse(element));
        });
      } else if (temp.getAttribute('type') == 'hourly') {
        temp.findAllElements('value').map((node) => node.text)
            .forEach((element) {
          hourlyTemperatures.add(double.parse(element));
        });
      }
    }
  }
}