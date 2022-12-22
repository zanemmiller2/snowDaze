

// Package imports:
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:xml/xml.dart';

// Project imports:
import '../lib/services/debugLogFunction.dart';

class WeatherForecast {

  XmlDocument? xmlData;
  String? nwsSourceURL;

  /* Metadata */
  String? sourceCredit;
  List<String> timeLayoutKeys = [];
  List<String> startTimes = [];
  List<String> endTimes = [];
  String? creationDate;

  /* Location Data */
  double? latitude;
  double? longitude;
  String? areaDescription;
  double? elevation;
  String? elevationUnits;

  /* Parameters*/
  //temperatures
  List<dynamic> dewPointTemperatures = [];
  String dewPointUnits = "Fahrenheit";
  List<dynamic> windChillTemperatures = [];
  String windChillUnits = "Fahrenheit";
  List<dynamic> hourlyTemperatures = [];
  String hourlyTemperatureUnits = "Fahrenheit";
  // winds
  List<dynamic> sustainedWindSpeeds = [];
  String sustainedWindSpeedUnits = 'mph';
  List<dynamic> gustsWindSpeeds = [];
  String gustsWindSpeedUnits = 'mph';
  List<dynamic> windDirections = [];
  String? windDirectionUnits;
  // clouds
  List<dynamic> cloudAmounts = [];
  String? cloudAmountUnits;
  // precipitation
  List<dynamic> precipitationProbability = [];
  String? precipitationProbabilityUnits;
  List<dynamic> hourlyQpf = [];
  String? hourlyQpfUnits;
  // humidity
  List<dynamic> relativeHumidity = [];
  String? relativeHumidityUnits;
  // weather conditions
  List<List<String?>> weatherConditionsType = [];
  List<List<String?>> weatherConditionsCoverage = [];

  /* Class Constructor */
  WeatherForecast(String latitude, String longitude) {
    // sets weather forecast source url
    nwsSourceURL =
        "https://forecast.weather.gov/MapClick.php?lat=$latitude&lon=$longitude&FcstType=digitalDWML";
  }


  Future<void> initialize () async {
    await fetchXML();
    setCreationDate();
    setSourceCredit();
    setLayoutKeys();
    setStartEndTimes();
    setStartEndTimes();
    setLatLong();
    setAreaDescription();
    setElevation();
    setTemperatures();
    setWindSpeeds();
    setHumidity();
    setCloudAmounts();
    setPrecipitationProbability();
    setWeather();
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
      if (kDebugMode) {
        log("REASON PHRASE ${response.request}");
      }
      if (response.statusCode == 200) {
        requestSuccess = true;
        xmlData = XmlDocument.parse(response.body);
      }
    } catch (e) {
      if (requestSuccess == false) {
        if (kDebugMode) {
          log("####################  ERROR: $e");
        }
        retryFutureRequest(fetchXML(), 1000);
      }
    }
  }

  // helper to resend http request if fails
  retryFutureRequest(future, delay) {
    Future.delayed(Duration(milliseconds: delay), () {
      future();
    });
  }

  // Converts UTC time to local 12hr time format "MMMd h:mm a)
  String convertToLocalTime (String? time) => DateFormat.MMMd().add_jm().format(DateTime.parse(time!).toLocal());


  /*--------------------------------------------------------------------
  * #                                                                  #
  * #                         Setters  - MetaData                      #
  * #                                                                  #
  * --------------------------------------------------------------------*/

  // extract and store the source credit
  void setSourceCredit() {
    sourceCredit = xmlData?.rootElement
        .getElement("head")
        ?.getElement("source")
        ?.getElement("credit")
        ?.text;
  }

  // extract and store the creation date
  void setCreationDate() {
    creationDate = convertToLocalTime(xmlData?.rootElement
        .getElement('head')
        ?.getElement('product')
        ?.getElement('creation-date')
        ?.text);
  }

  // extract layout keys from xml
  void setLayoutKeys() {
    xmlData
        ?.findAllElements("layout-key")
        .map((node) => node.text)
        .forEach((element) {
      timeLayoutKeys.add(element);
    });
  }

  // extract start and end times from xml
  void setStartEndTimes() {
    // get and store start times
    xmlData
        ?.findAllElements("start-valid-time")
        .map((node) => node.text)
        .forEach((element) {
      startTimes.add(convertToLocalTime(element));
    });

    // get and store end times
    xmlData
        ?.findAllElements("end-valid-time")
        .map((node) => node.text)
        .forEach((element) {
      endTimes.add(convertToLocalTime(element));
    });
  }

  // extract and store latitude and longitude
  void setLatLong() {
    latitude = double.parse(xmlData?.rootElement
        .getElement("data")
        ?.getElement("location")
        ?.getElement("point")
        ?.getAttribute("latitude") as String);
    longitude = double.parse(xmlData?.rootElement
        .getElement("data")
        ?.getElement("location")
        ?.getElement("point")
        ?.getAttribute("longitude") as String);
  }

  // extract and store the area-description or 'description' if area-description is null
  void setAreaDescription() {
    areaDescription = xmlData?.rootElement
            .getElement("data")
            ?.getElement("location")
            ?.getElement("area-description")
            ?.text ??
        xmlData?.rootElement
            .getElement("data")
            ?.getElement("location")
            ?.getElement("description")
            ?.text;
  }

  // extract and store elevation and elevation units
  void setElevation() {
    elevation = double.parse(xmlData?.rootElement
        .getElement("data")
        ?.getElement("location")
        ?.getElement("height")
        ?.text as String);
    elevationUnits = xmlData?.rootElement
        .getElement("data")
        ?.getElement("location")
        ?.getElement("height")
        ?.getAttribute("height-units") ?? "feet";
  }

  /*--------------------------------------------------------------------
  * #                                                                  #
  * #                       Setters  - Parameters                      #
  * #                                                                  #
  * --------------------------------------------------------------------*/

  // extract and store the list of dewPoint,windChill, and hourly temperatures
  void setTemperatures() {
    // get all elements named temperature (dew point, wind chill, hourly)
    var tempTemps = xmlData?.findAllElements('temperature');
    for (var temp in tempTemps!) {
      // extract dew point temperatures
      if (temp.getAttribute('type') == 'dew point') {
        // get a list of dew point values
        var tempDews =
            temp.findAllElements('value').map((node) => node.text).toList();
        // check if any of the values are "null" if so: write as 0
        for (var tempDewValue in tempDews) {
          if (tempDewValue.isEmpty) {
            // convert null dew point values
            dewPointTemperatures.add("NA");
          } else {
            dewPointTemperatures.add(double.parse(tempDewValue));
          }
        }

        // extract wind chill temperatures
      } else if (temp.getAttribute('type') == 'wind chill') {
        var tempWindChills =
            temp.findAllElements('value').map((node) => node.text).toList();
        // check if any of the values are "null" if so: write as 0
        for (var tempWindChillValue in tempWindChills) {
          // convert null wind chill values
          if (tempWindChillValue.isEmpty) {
            windChillTemperatures.add("NA");
          } else {
            windChillTemperatures.add(double.parse(tempWindChillValue));
          }
        }

        // Extract hourly temperatures
      } else if (temp.getAttribute('type') == 'hourly') {
        var tempHourlyTemps =
            temp.findAllElements('value').map((node) => node.text).toList();
        // check if any of the values are "null" if so: write as 0
        for (var tempHourlyTemp in tempHourlyTemps) {
          // convert null hourly temperature values
          if (tempHourlyTemp.isEmpty) {
            hourlyTemperatures.add("NA");
          } else {
            hourlyTemperatures.add(double.parse(tempHourlyTemp));
          }
        }
      }
    }
  }

  // extract and store the list of gusts and sustained wind speeds and wind directions
  void setWindSpeeds() {
    // get all elements named "wind-speed" (gusts, sustained)
    var tempWinds = xmlData?.findAllElements('wind-speed');

    for (var wind in tempWinds!) {
      // extract the gust wind speed values
      if (wind.getAttribute('type') == 'gust') {
        var tempGusts =
            wind.findAllElements('value').map((node) => node.text).toList();
        // check if any of the values are "null" if so: write as 0 mph
        for (var tempGust in tempGusts) {
          // convert null gusts values
          if (tempGust.isEmpty) {
            gustsWindSpeeds.add("NA");
          } else {
            gustsWindSpeeds.add(double.parse(tempGust));
          }
        }

        // extract the sustained wind speed values
      } else if (wind.getAttribute('type') == 'sustained') {
        var tempSustainedWinds =
            wind.findAllElements('value').map((node) => node.text).toList();
        // check if any of the values are "null" if so: write as 0 mph
        for (var tempSustainedWind in tempSustainedWinds) {
          if (tempSustainedWind.isEmpty) {
            // convert null sustained values
            sustainedWindSpeeds.add("NA");
          } else {
            sustainedWindSpeeds.add(double.parse(tempSustainedWind));
          }
        }
      }
    }

    // extract windDirection units
    windDirectionUnits = xmlData?.rootElement
        .getElement('data')
        ?.getElement('parameters')
        ?.getElement('direction')
        ?.getAttribute('units') as String;

    // extract all elements named 'direction' (wind, ??)
    var tempDirections = xmlData?.findAllElements('direction');

    for (var direction in tempDirections!) {
      // extract the wind direction values
      if (direction.getAttribute('type') == 'wind') {
        var tempWindDirections = direction
            .findAllElements('value')
            .map((node) => node.text)
            .toList();
        // add each to windDirections list
        for (var tempWindDirection in tempWindDirections) {
          if (tempWindDirection.isEmpty) {
            // convert null wind directions to 0
            windDirections.add("NA");
          } else {
            windDirections.add(double.parse(tempWindDirection));
          }
        }
      }
    }
  }

  // extract and store the cloud-amount values and units
  void setCloudAmounts() {
    // get the cloud-amount units
    cloudAmountUnits = xmlData?.rootElement
        .getElement('data')
        ?.getElement('parameters')
        ?.getElement('cloud-amount')
        ?.getAttribute('units') as String;
    // find all elements named 'cloud-amount'
    var tempCloudAmounts = xmlData?.findAllElements('cloud-amount');
    for (var cloudAmount in tempCloudAmounts!) {
      // extract the total cloud-amount values
      if (cloudAmount.getAttribute('type') == 'total') {
        var tempCloudAmount =
            cloudAmount.findAllElements('value').map((node) => node.text);
        // use 0.0 instead of null
        for (var tempAmount in tempCloudAmount) {
          if (tempAmount.isEmpty) {
            cloudAmounts.add("NA");
          } else {
            cloudAmounts.add(double.parse(tempAmount));
          }
        }
      }
    }
  }

  // extract and store probability of precipitation
  void setPrecipitationProbability() {
    // get precipitation probability units
    precipitationProbabilityUnits = xmlData?.rootElement
        .getElement('data')
        ?.getElement('parameters')
        ?.getElement('probability-of-precipitation')
        ?.getAttribute('units');
    // find all elements named 'cloud-amount'
    var tempPrecipProbab =
        xmlData?.findAllElements('probability-of-precipitation');
    for (var precipProbability in tempPrecipProbab!) {
      // extract the total precipitation probability values
      if (precipProbability.getAttribute('type') == 'floating') {
        var tempProbabilityAmount =
            precipProbability.findAllElements('value').map((node) => node.text);
        // use 0.0 instead of null
        for (var tempAmount in tempProbabilityAmount) {
          if (tempAmount.isEmpty) {
            precipitationProbability.add("NA");
          } else {
            precipitationProbability.add(double.parse(tempAmount));
          }
        }
      }
    }
  }

  // extract and store probability of precipitation
  void setHumidity() {
    // get humidity units
    relativeHumidityUnits = xmlData?.rootElement
        .getElement('data')
        ?.getElement('parameters')
        ?.getElement('humidity')
        ?.getAttribute('units');
    // find all elements named 'humidity'
    var tempHumidities = xmlData?.findAllElements('humidity');
    for (var humidityType in tempHumidities!) {
      // extract the relative humidity values
      if (humidityType.getAttribute('type') == 'relative') {
        var tempHumidityAmount =
            humidityType.findAllElements('value').map((node) => node.text);
        // use 0.0 instead of null
        for (var tempAmount in tempHumidityAmount) {
          if (tempAmount.isEmpty) {
            relativeHumidity.add("NA");
          } else {
            relativeHumidity.add(double.parse(tempAmount));
          }
        }
      }
    }
  }

  // extract weather, coverage and precipitation amount
  void setWeather() {
    // extract the hourlyQpfUnits
    hourlyQpfUnits = xmlData?.rootElement
        .getElement('data')
        ?.getElement('parameters')
        ?.getElement('hourly-qpf')
        ?.getAttribute('units') as String;

    // extract the hourly qpf values
    var tempHourlyQpfs = xmlData?.findAllElements('hourly-qpf');
    for (var tempHourlyQpfType in tempHourlyQpfs!) {
      if (tempHourlyQpfType.getAttribute('type') == 'floating') {
        var tempHourlyQpfAmount =
            tempHourlyQpfType.findAllElements('value').map((node) => node.text);
        // use 0.0 instead of null
        for (var tempAmount in tempHourlyQpfAmount) {
          if (tempAmount.isEmpty) {
            hourlyQpf.add("NA");
          } else {
            hourlyQpf.add(double.parse(tempAmount));
          }
        }
      }
    }

    // extract weather conditions and coverages
    var tempWeathers = xmlData?.findAllElements('weather-conditions');
    for (var tempCondition in tempWeathers!) {
      // null conditions
      if (tempCondition.getAttribute('xsi:nil') == 'true') {
        weatherConditionsType.add(["None"]);
        weatherConditionsCoverage.add(["None"]);

        // add weather condition type and coverage to respective lists
      } else {
        // get all the values for the current hour
        var tempConditionValues =
            tempCondition.findAllElements('value').toList();

        // weather condition event has additive weather type. for example "rain AND thunderstorms"
        if (tempConditionValues.length > 1) {
          List<String> tempConditionStringList = [];
          List<String> tempCoverageStringList = [];

          // loop through each event and build the weather condition string
          for (int i = 0; i < tempConditionValues.length; i++) {
            // add the leading "and" conditions
            tempConditionStringList.add(
                tempConditionValues[i].getAttribute('weather-type') ?? 'None');
            tempCoverageStringList.add(
                tempConditionValues[i].getAttribute('coverage') ?? 'None');
            if (i == tempConditionValues.length - 1) {
              weatherConditionsType.add(tempConditionStringList);
              weatherConditionsCoverage.add(tempCoverageStringList);
            }
          }

          // weather condition even has no additive value -- add single type and coverage
        } else {
          weatherConditionsType.add(
              [tempConditionValues[0].getAttribute('weather-type') ?? "None"]);
          weatherConditionsCoverage
              .add([tempConditionValues[0].getAttribute('coverage') ?? "None"]);
        }
      }
    }
  }
}

void main() async {

  var latitude = "36.7311";
  var longitude = "-91.8531";
  WeatherForecast weather = WeatherForecast(latitude, longitude);
  await weather.initialize();   // sets the class attributes for the weather_forecast

  /* Meta Data */
  if (kDebugMode) {

    log("Creation Date: ${weather.creationDate}");
    log("Source Credit: ${weather.sourceCredit}");

    log("Time Layout Keys: ${weather.timeLayoutKeys}");
    log("Start Times: ${weather.startTimes}");
    log("End Times: ${weather.endTimes}");
    /* Location Data */
    log("Latitude: ${weather.latitude}, Longitude: ${weather.longitude}");
    log("Area Description: ${weather.areaDescription}");
    log("Elevation: ${weather.elevation} ${weather.elevationUnits}");
    log(
        "Dew Points (${weather.dewPointUnits}): ${weather
            .dewPointTemperatures}");
    log(
        "Wind Chill (${weather.windChillUnits}): ${weather
            .windChillTemperatures}");
    log(
        "Hourly Temps (${weather.hourlyTemperatureUnits}): ${weather
            .hourlyTemperatures}");

    log("Gusts (${weather.gustsWindSpeedUnits}): ${weather.gustsWindSpeeds}");
    log(
        "Sustained Winds (${weather.sustainedWindSpeedUnits}): ${weather
            .sustainedWindSpeeds}");
    log(
        "Wind Directions (${weather.windDirectionUnits}): ${weather
            .windDirections}");
    log(
        "Cloud Amounts (${weather.cloudAmountUnits}): ${weather.cloudAmounts}");
    log(
        "Precipitation Probabilities (${weather
            .precipitationProbabilityUnits}): ${weather
            .precipitationProbability}");
    log(
        "Relative Humidity (${weather.relativeHumidityUnits}): ${weather
            .relativeHumidity}");
    log("Hourly QPFS (${weather.hourlyQpfUnits}): ${weather.hourlyQpf}");
    log("Weather Type: ${weather.weatherConditionsType}");
    log("Weather Coverage: ${weather.weatherConditionsCoverage}");
  }
}
