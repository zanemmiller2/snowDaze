
/*

** This class model was modified to use xml.getElements notation instead of converting xml to json
    and then indexing a json object for improved stability and reliability.
** The class model was also restructured to better match the structure of a different site using the
    digitalDWML forecast type instead of dwml.
** The new file is in lib/models/weather_class.dart

*/


import 'dart:convert';
import 'package:xml2json/xml2json.dart';

import 'package:http/http.dart' as http;


void main() async {
  var latitude = "39.6404";
  var longitude = "-106.3755";
  WeatherForecast weather = WeatherForecast(latitude, longitude);

  await weather.fetchXML();
  weather.convertXml2Json();
  print("url = ${weather.nwsSourceURL}");

  /* Forecast Conditions */
  print("-------------FORECAST CONDITIONS ----------------");
  weather.setDateCreated();
  print("date created: ${weather.dateCreated}");

  weather.setAreaDescription();
  print("area description: ${weather.areaDescription}");

  weather.setElevation();
  print("elevation: ${weather.elevation} ${weather.elevationUnits}");

  weather.setLatLong();
  print("latitude: ${weather.latitude}\nlongitude: ${weather.longitude}");

  weather.setExtendedForecastLayoutFields();
  print(weather.extendedForecastLayoutKey);
  for(int i=0; i < weather.extendedForecastPeriodNames.length; i++) {
    print("${weather.extendedForecastPeriodNames[i]}, ${weather.extendedForecastStartTimes[i]}");
  }

  weather.setExtendedSevenDayLayoutFields_1();
  print(weather.extendedSevenDayLayoutKey_1);
  for(int i=0; i < weather.extendedForecastPeriodNames_1.length; i++) {
    print("${weather.extendedForecastPeriodNames_1[i]}, ${weather.extendedForecastStartTimes_1[i]}");
  }

  weather.setExtendedSevenDayLayoutFields_2();
  print(weather.extendedSevenDayLayoutKey_2);
  for(int i=0; i < weather.extendedForecastPeriodNames_2.length; i++) {
    print("${weather.extendedForecastPeriodNames_2[i]}, ${weather.extendedForecastStartTimes_2[i]}");
  }

  weather.setMaxTemps();
  print("max temps: ${weather.maximumTemperatures}");

  weather.setMinTemps();
  print("min temps: ${weather.minimumTemperatures}");

  weather.setPrecipitationProbability();
  print("precipitation probabilities: ${weather.precipitationProbability}");

  weather.setWeatherSummaries();
  print("weather summaries: ${weather.weatherConditionsSummary}");

  weather.setWeatherIcons();
  print("weather icons: ${weather.weatherConditionsIcons}");

  weather.setHazards();
  for(int i=0; i < weather.hazardHeadlines.length; i++) {
    print("hazard headline: ${weather.hazardHeadlines[i]}, URL: ${weather.hazardTextURLs[i]}");
  }

  weather.setWordedForecast();
  print("\nworded forecasts:----------------");
  for(int i=0; i < weather.wordedForecasts.length; i++) {
    print("${weather.wordedForecasts[i]}");
  }

  /* Current Conditions */
  weather.setCurrentAreaDescription();
  print("\n\n-------------CURRENT CONDITIONS for ${weather.currentAreaDescription}  ----------------");

  weather.setCurrentElevation();
  print("elevation: ${weather.currentElevation} ${weather.currentElevationUnits}");


  weather.setCurrentConditionsLayoutFields();
  print(weather.currentConditionsLayoutKey);
  print("${weather.currentConditionsPeriodNames}, ${weather.currentConditionsStartTimes}");

  weather.setCurrentLatLong();
  print("latitude: ${weather.currentLatitude}\nlongitude: ${weather.currentLongitude}");

  weather.setCurrentTemperature();
  print("current temp: ${weather.currentTemperature} ${weather.currentTemperatureUnits}\ndew point: ${weather.currentDewPoint} ${weather.currentDewPointUnits}");

  weather.setCurrentRelativeHumidity();
  print("relative humidity: ${weather.currentRelativeHumidity}%");

  weather.setCurrentWeatherSummary();
  if(weather.hasCurrentWeatherSummary) {
    print("weather summary: ${weather.currentWeatherSummary}");
  } else {
    print("Current weather summary not available (${weather.currentWeatherSummary})");
  }

  weather.setCurrentVisibility();
  if(weather.hasCurrentVisibility) {
    print("visibility: ${weather.currentVisibilityDistance} ${weather.currentVisibilityUnits}");
  } else {
    print("Visibility data unavailable (${weather.currentVisibilityDistance} units: ${weather.currentVisibilityUnits})");
  }

  weather.setCurrentConditionsIcon();
  if(weather.currentConditionsIcon != null) {
    print("current conditions icon link: ${weather.currentConditionsIcon}");
  } else {
    print("No current conditions icon available");
  }

  weather.setWind();
  if(weather.currentWindGustsSpeed != null) {
    print("Gusts: ${weather.currentWindGustsSpeed} ${weather.currentWindGustUnits}");
  } else {
    print("No current wind gust data to show (${weather.currentWindGustUnits}");
  }

  if(weather.currentWindSustainedSpeed != null) {
    print("Sustained winds: ${weather.currentWindSustainedSpeed} ${weather.currentWindSustainedUnits}");
  } else {
    print("No current sustained wind data to show (${weather.currentWindSustainedUnits}");
  }

}

class WeatherForecast {

  /*
  * parametersType (scope = local, element only)
  * attribute = applicable-location, type = string, use = required anyOrder
  *   element = temperature, type = temperatureType, min = 0, max = unbounded
  *   element = precipitation, type = precipitationType, min = 0, max = unbounded
  *   element = probability-of-precipitation, type = probability-of-precipitationType, min = 0, max = unbounded
  *   element = convective-hazard, type = convective-hazardType, min = 0, max = unbounded
  *   element = wind-speed, type = wind-speedType, min = 0, max = unbounded
  *   element = direction, type = directionType, min = 0, max = unbounded
  *   element = cloud-amount, type = cloud-amountType, min = 0, max = unbounded
  *   element = weather, type = weatherType, min = 0, max = unbounded
  *   element = humidity, type = humidityType, min = 0, max = unbounded
  *   element = conditions-icon, type = conditions-iconType, min = 0, max = unbounded
  *   element = wordedForecast, type = wordedForecastType, min = 0, max = unbounded
  *   element = water-state, type = conditions-iconType, min = 0, max = unbounded
* */
  String? xmlData;
  dynamic jsonData;
  String? sourceCredit;

  /* Layouts */
  // TODO -- handle different layout keys p6h-n1??
  String? extendedForecastLayoutKey;
  List<String> extendedForecastPeriodNames = [];
  List<String> extendedForecastStartTimes = [];
  String? extendedSevenDayLayoutKey_1; // first half daily
  List<String> extendedForecastPeriodNames_1 = [];
  List<String> extendedForecastStartTimes_1 = [];
  String? extendedSevenDayLayoutKey_2; // second half daily
  List<String> extendedForecastPeriodNames_2 = [];
  List<String> extendedForecastStartTimes_2 = [];

  /* Parameters from forecast */
  String? temperatureUnits;
  List<int> maximumTemperatures = []; // daytime
  List<int> minimumTemperatures = []; // nighttime
  List<String> precipitationProbability = []; // n13
  List<String> weatherConditionsSummary = [];
  List<String> weatherConditionsIcons = [];
  List<String> wordedForecasts = [];
  String? dateCreated;
  String? areaDescription;
  String? elevation;
  String? elevationUnits;
  String? nwsSourceURL;
  String? latitude;
  String? longitude;
  bool hasHazard = false;
  List<String> hazardHeadlines = [];
  List<String> hazardTextURLs = [];

  /* Current conditions layouts */
  String? currentConditionsLayoutKey;
  String? currentConditionsPeriodNames;
  String? currentConditionsStartTimes;

  /* Current Conditions parameters */
  // location
  String? currentLatitude;
  String? currentLongitude;
  String? currentElevation;
  String? currentElevationUnits;
  String? currentAreaDescription;
  // current conditions
  int? currentTemperature;
  String? currentTemperatureUnits;
  int? currentDewPoint;
  String? currentDewPointUnits;
  int? currentRelativeHumidity;
  // weather summary
  bool hasCurrentWeatherSummary = false;
  String? currentWeatherSummary;
  //visibility
  bool hasCurrentVisibility = false;
  String? currentVisibilityUnits;
  String? currentVisibilityDistance;
  // icons
  String? currentConditionsIcon;
  // wind
  String? currentWindDirection;
  String? currentWindDirectionUnits;
  String? currentWindGustUnits;
  String? currentWindGustsSpeed;
  String? currentWindSustainedUnits;
  String? currentWindSustainedSpeed;

  // Class constructor
  WeatherForecast(String latitude, String longitude) {
    // sets weather forecast source url
    nwsSourceURL =
    "https://forecast.weather.gov/MapClick.php?lat=$latitude&lon=$longitude&unit=0&lg=english&FcstType=dwml";
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
      if(response.statusCode == 200) {
        requestSuccess = true;
        xmlData = response.body;
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

  // convert XML to JSON and store in weather.jsonData
  void convertXml2Json() {
    final myTransformer = Xml2Json();
    myTransformer.parse(xmlData!);
    // var temp = myTransformer.toParkerWithAttrs();
    // print(temp);
    jsonData = jsonDecode(myTransformer.toParkerWithAttrs());
  }

  /*--------------------------------------------------------------------
  * #                                                                  #
  * #                         Setters  - Forecast                      #
  * #                                                                  #
  * --------------------------------------------------------------------*/
  // TODO -- handle different layout keys p6h-n1??

  // set sourceCredit
  void setSourceCredit () {
    sourceCredit = jsonData["dwml"]["head"]["source"]["credit"];
  }

  // get dateCreated from JSON
  void setDateCreated() {
    dateCreated = jsonData["dwml"]["head"]["product"]["creation-date"]["value"];
  }

  // set areaDescription from JSON
  void setAreaDescription() {
    // if theres no "area-description" field in xml its probably just "description"
    areaDescription = jsonData["dwml"]["data"][0]["location"]["area-description"] ?? jsonData["dwml"]["data"][0]["location"]["description"];
  }

  // set elevation from JSON
  void setElevation() {
    elevation = jsonData["dwml"]["data"][0]["location"]["height"]["value"];
    // some forecasts omit the _height-units set default units to feet
    elevationUnits = jsonData["dwml"]["data"][0]["location"]["height"]["_height-units"] ?? "feet";
  }

  // set latitude and longitude from JSON
  void setLatLong() {
    latitude = jsonData["dwml"]["data"][0]["location"]["point"]["_latitude"];
    longitude = jsonData["dwml"]["data"][0]["location"]["point"]["_longitude"];
  }

  // set extended forecast layout fields
  void setExtendedForecastLayoutFields() {
    // store the layout key n13
    extendedForecastLayoutKey =
    jsonData["dwml"]["data"][0]["time-layout"][0]["layout-key"];
    var startValidTimes = jsonData["dwml"]["data"][0]["time-layout"][0]["start-valid-time"];

    // store the period names and start-times
    for (var periodName in startValidTimes) {
      // add the periodName
      extendedForecastPeriodNames.add(periodName["_period-name"]);
      // add the start time
      extendedForecastStartTimes.add(periodName["value"]);
    }
  }

  // set the 7 day 12 hour layout_1 fields
  void setExtendedSevenDayLayoutFields_1() {
    extendedSevenDayLayoutKey_1 =
    jsonData["dwml"]["data"][0]["time-layout"][1]["layout-key"];
    var startValidTimes = jsonData["dwml"]["data"][0]["time-layout"][1]["start-valid-time"];

    // store the period names and start-times
    for (var periodName in startValidTimes) {
      // add the periodName
      extendedForecastPeriodNames_1.add(periodName["_period-name"]);
      // add the start time
      extendedForecastStartTimes_1.add(periodName["value"]);
    }
  }

  // set the 7 day 12 hour layout_2 fields
  void setExtendedSevenDayLayoutFields_2() {
    extendedSevenDayLayoutKey_2 =
    jsonData["dwml"]["data"][0]["time-layout"][2]["layout-key"];
    var startValidTimes = jsonData["dwml"]["data"][0]["time-layout"][2]["start-valid-time"];

    // store the period names and start-times
    for (var periodName in startValidTimes) {
      // add the periodName
      extendedForecastPeriodNames_2.add(periodName["_period-name"]);
      // add the start time
      extendedForecastStartTimes_2.add(periodName["value"]);
    }
  }

  // set max temps
  void setMaxTemps() {
    temperatureUnits = jsonData["dwml"]["data"][0]["parameters"]["temperature"][0]["_units"];
    var tempMaxTemps = jsonData["dwml"]["data"][0]["parameters"]["temperature"][0]["value"];
    for (var maxTemp in tempMaxTemps) {
      // add the temperatures to list as integer values
      maximumTemperatures.add(int.parse(maxTemp));
    }
  }

  // set min temps
  void setMinTemps() {
    var tempMinTemps = jsonData["dwml"]["data"][0]["parameters"]["temperature"][1]["value"];
    for (var minTemp in tempMinTemps) {
      // add the temperatures to list as integer values
      minimumTemperatures.add(int.parse(minTemp));
    }
  }

  // set precipitation probability
  void setPrecipitationProbability() {
    var tempPrecipitationProbabilities = jsonData["dwml"]["data"][0]["parameters"]["probability-of-precipitation"]["value"];
    for (var precipProbability in tempPrecipitationProbabilities) {
      if (precipProbability is String) {
        // add the temperatures to list as integer values
        precipitationProbability.add(precipProbability);
        // precipitation value is null == 0% chance of precipitation
      } else if (precipProbability["_xsi:nil"] == "true") {
        precipitationProbability.add("0");
      }
    }
  }

  // set weather summaries
  void setWeatherSummaries () {
    var tempWeatherSummaries = jsonData["dwml"]["data"][0]["parameters"]["weather"]["weather-conditions"];
    for(var summary in tempWeatherSummaries) {
      weatherConditionsSummary.add(summary["_weather-summary"]);
    }
  }

  // set weather icons
  void setWeatherIcons () {
    var tempWeatherIcons = jsonData["dwml"]["data"][0]["parameters"]["conditions-icon"]["icon-link"];
    for(var icon in tempWeatherIcons) {
      weatherConditionsIcons.add(icon);
    }
  }

  // set hazards if there are any
  void setHazards () {
    // TODO -- handle situations with multiple hazards?
    // check first if there are any hazards
    if (jsonData["dwml"]["data"][0]["parameters"].containsKey("hazards")) {
      hasHazard = true;

      var tempHazards = jsonData["dwml"]["data"][0]["parameters"]["hazards"];
      // get and store the headlines and urls
      for(var hazard in tempHazards) {
        hazardHeadlines.add(hazard["hazard-conditions"]["hazard"]["_headline"]);
        hazardTextURLs.add(hazard["hazard-conditions"]["hazard"]["hazardTextURL"]);
      }
    }
  }

  // set worded forecast
  void setWordedForecast () {
    var tempWordedForecasts = jsonData["dwml"]["data"][0]["parameters"]["wordedForecast"]["text"];

    for (var tempText in tempWordedForecasts) {
      wordedForecasts.add(tempText);
    }
  }


  /*--------------------------------------------------------------------
  * #                                                                  #
  * #                 Setters  - Current Conditions                    #
  * #                                                                  #
  * --------------------------------------------------------------------*/
  // set areaDescription from JSON
  void setCurrentAreaDescription () {
    // if theres no "area-description" field in xml its probably just "description"
    currentAreaDescription = jsonData["dwml"]["data"][1]["location"]["area-description"] ?? jsonData["dwml"]["data"][1]["location"]["description"];
  }

  // set elevation from JSON
  void setCurrentElevation() {
    currentElevation = jsonData["dwml"]["data"][1]["location"]["height"]["value"];
    // some forecasts omit the _height-units set default units to feet
    currentElevationUnits = jsonData["dwml"]["data"][1]["location"]["height"]["_height-units"] ?? "feet";
  }

  void setCurrentConditionsLayoutFields () {
    currentConditionsLayoutKey = jsonData["dwml"]["data"][1]["time-layout"]["layout-key"];
    currentConditionsPeriodNames = jsonData["dwml"]["data"][1]["time-layout"]["start-valid-time"]["_period-name"];
    currentConditionsStartTimes = jsonData["dwml"]["data"][1]["time-layout"]["start-valid-time"]["value"];
  }

  // set current lat and long
  void setCurrentLatLong () {
    currentLatitude = jsonData["dwml"]["data"][1]["location"]["point"]["_latitude"];
    currentLongitude = jsonData["dwml"]["data"][1]["location"]["point"]["_longitude"];
  }

  // Set current temp and units
  void setCurrentTemperature () {
    var tempTemperatures = jsonData["dwml"]["data"][1]["parameters"]["temperature"];
    for(var field in tempTemperatures) {
      if(field["_type"] == "apparent") {
        currentTemperatureUnits = field["_units"];
        currentTemperature = int.parse(field["value"]);
      } else if (field["_type"] == "dew point") {
        currentDewPointUnits = field["_units"];
        currentDewPoint = int.parse(field["value"]);
      }
    }
  }

  // set current relative humidity
  void setCurrentRelativeHumidity () {
    currentRelativeHumidity = int.parse(jsonData["dwml"]["data"][1]["parameters"]["humidity"]["value"]);
  }

  // set weatherSummary if there is any
  void setCurrentWeatherSummary () {
    var weatherSummary = jsonData["dwml"]["data"][1]["parameters"]["weather"]["weather-conditions"][0]["_weather-summary"];
    if (weatherSummary == "NA") {
      hasCurrentWeatherSummary = false;
      currentWeatherSummary = null;
    } else {
      hasCurrentWeatherSummary = true;
      currentWeatherSummary =jsonData["dwml"]["data"][1]["parameters"]["weather"]["weather-conditions"][0]["value"];
    }
  }

  // set current visibility data if there is any
  void setCurrentVisibility () {
    currentVisibilityDistance = jsonData["dwml"]["data"][1]["parameters"]["weather"]["weather-conditions"][1]["value"]["visibility"]["value"];
    currentVisibilityUnits = jsonData["dwml"]["data"][1]["parameters"]["weather"]["weather-conditions"][1]["value"]["visibility"]["_units"];
    // no visibility data
    if (currentVisibilityDistance == 'NA') {
      currentVisibilityDistance = null;
      hasCurrentVisibility = false;
    } else if (currentVisibilityDistance != null) {
      hasCurrentVisibility = true;
    }
  }

  // get any icon associated with the current conditions
  void setCurrentConditionsIcon () {
    currentConditionsIcon = jsonData["dwml"]["data"][1]["parameters"]["conditions-icon"]["icon-link"];
    if(currentConditionsIcon == "NULL") {
      currentConditionsIcon = null;
    }
  }

  // set wind variables
  void setWind() {
    currentWindDirection = jsonData["dwml"]["data"][1]["parameters"]["direction"]["value"];
    currentWindDirectionUnits = jsonData["dwml"]["data"][1]["parameters"]["direction"]["_units"];

    var tempWinds = jsonData["dwml"]["data"][1]["parameters"]["wind-speed"];
    for(var wind in tempWinds) {
      // set wind gusts variables
      if(wind["_type"] == "gust") {
        currentWindGustsSpeed = wind["value"];
        currentWindGustUnits = wind["_units"];

        if(currentWindGustsSpeed == "NA") {
          currentWindGustsSpeed = null;
        }
        // set sustained winds variables
      } else if(wind["_type"] == "sustained") {
        currentWindSustainedSpeed = wind["value"];
        currentWindSustainedUnits = wind["_units"];
        if(currentWindSustainedSpeed == "NA") {
          currentWindSustainedSpeed = null;
        }
      }
    }
  }

}