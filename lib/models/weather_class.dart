import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

void main() async {
  var latitude = "36.7311";
  var longitude = "-91.8531";
  WeatherForecast weather = WeatherForecast(latitude, longitude);

  await weather.fetchXML();

  /* Meta Data */
  weather.setCreationDate();
  print("Creation Date: ${weather.creationDate}");

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
  print(
      "Dew Points (${weather.dewPointUnits}): ${weather.dewPointTemperatures}");
  print(
      "Wind Chill (${weather.windChillUnits}): ${weather.windChillTemperatures}");
  print(
      "Hourly Temps (${weather.hourlyTemperatureUnits}): ${weather.hourlyTemperatures}");

  weather.setWindSpeeds();
  print("Gusts (${weather.gustsWindSpeedUnits}): ${weather.gustsWindSpeeds}");
  print(
      "Sustained Winds (${weather.sustainedWindSpeedUnits}): ${weather.sustainedWindSpeeds}");
  print(
      "Wind Directions (${weather.windDirectionUnits}): ${weather.windDirections}");

  weather.setCloudAmounts();
  print("Cloud Amounts (${weather.cloudAmountUnits}): ${weather.cloudAmounts}");

  weather.setPrecipitationProbability();
  print(
      "Precipitation Probabilities (${weather.precipitationProbabilityUnits}): ${weather.precipitationProbability}");

  weather.setHumidity();
  print(
      "Relative Humidity (${weather.relativeHumidityUnits}): ${weather.relativeHumidity}");

  weather.setWeather();
  print("Hourly QPFS (${weather.hourlyQpfUnits}): ${weather.hourlyQpf}");
  print("Weather Type: ${weather.weatherConditionsType}");
  print("Weather Coverage: ${weather.weatherConditionsCoverage}");
}

class WeatherForecast {
  XmlDocument? xmlData;
  String? nwsSourceURL;

  /* Meta Data */
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

  /* Parameters */
  List<double> dewPointTemperatures = [];
  String dewPointUnits = "Fahrenheit";
  List<double> windChillTemperatures = [];
  String windChillUnits = "Fahrenheit";
  List<double> hourlyTemperatures = [];
  String hourlyTemperatureUnits = "Fahrenheit";
  List<double> sustainedWindSpeeds = [];
  String sustainedWindSpeedUnits = 'mph';
  List<double> gustsWindSpeeds = [];
  String gustsWindSpeedUnits = 'mph';
  List<double> windDirections = [];
  String? windDirectionUnits;
  List<double> cloudAmounts = [];
  String? cloudAmountUnits;
  List<double> precipitationProbability = [];
  String? precipitationProbabilityUnits;
  List<double> relativeHumidity = [];
  String? relativeHumidityUnits;
  List<double> hourlyQpf = [];
  String? hourlyQpfUnits;
  List<String> weatherConditionsType = [];
  List<String> weatherConditionsCoverage = [];

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
    sourceCredit = xmlData?.rootElement
        .getElement("head")
        ?.getElement("source")
        ?.getElement("credit")
        ?.text;
  }

  // extract and store the creation date
  void setCreationDate() {
    creationDate = xmlData?.rootElement
        .getElement('head')
        ?.getElement('product')
        ?.getElement('creation-date')
        ?.text;
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
      startTimes.add(element);
    });

    // get and store end times
    xmlData
        ?.findAllElements("end-valid-time")
        .map((node) => node.text)
        .forEach((element) {
      endTimes.add(element);
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
            dewPointTemperatures.add(double.parse("0"));
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
            windChillTemperatures.add(double.parse("0"));
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
            hourlyTemperatures.add(double.parse("0"));
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
            gustsWindSpeeds.add(double.parse("0"));
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
            sustainedWindSpeeds.add(double.parse("0"));
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
            windDirections.add(double.parse("0"));
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
            cloudAmounts.add(double.parse("0"));
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
            precipitationProbability.add(double.parse("0"));
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
            relativeHumidity.add(double.parse("0"));
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
            hourlyQpf.add(double.parse("0"));
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
        weatherConditionsType.add("None");
        weatherConditionsCoverage.add("None");

        // add weather condition type and coverage to respective lists
      } else {
        // get all the values for the current hour
        var tempConditionValues =
            tempCondition.findAllElements('value').toList();

        // weather condition event has additive weather type. for example "rain AND thunderstorms"
        if (tempConditionValues.length > 1) {
          String tempConditionString = '';

          // loop through each event and build the weather condition string
          for (int i = 0; i < tempConditionValues.length; i++) {
            // add the leading "and" conditions
            if (i < tempConditionValues.length - 1) {
              tempConditionString =
                  '$tempConditionString${tempConditionValues[i].getAttribute('weather-type')} and';

              // Add last condition and coverage type. Coverage seems to only be stated in last additive event
            } else if (i == tempConditionValues.length - 1) {
              tempConditionString =
                  '$tempConditionString ${tempConditionValues[i].getAttribute('weather-type')}';
              weatherConditionsType.add(tempConditionString);
              weatherConditionsCoverage.add(
                  tempConditionValues[i].getAttribute('coverage') ?? 'None');
            }
          }

          // weather condition even has no additive value -- add single type and coverage
        } else {
          weatherConditionsType.add(
              tempConditionValues[0].getAttribute('weather-type') as String);
          weatherConditionsCoverage
              .add(tempConditionValues[0].getAttribute('coverage') as String);
        }
      }
    }
  }
}
