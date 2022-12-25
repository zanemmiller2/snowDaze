// Flutter imports:
// Package imports:
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:snow_daze/screens/weather_screens/detailedAlertScreen.dart';
import 'package:snow_daze/utilities/timeConversions.dart';

// Project imports:
import '../../interactions/OpenWeatherClass.dart';
import '../../models/weather/currentWeather.dart';
import '../../utilities/locationDailySnowfall.dart';
import '../../widgets/snowFlakeProgressIndicator.dart';
import 'detailedDailyForecastScreen.dart';
import 'gridViewDetailScreen.dart';

class DetailedAllWeatherView extends StatefulWidget {
  final String latitude;
  final String longitude;
  final String title;

  const DetailedAllWeatherView(
      {super.key,
      required this.latitude,
      required this.longitude,
      required this.title});

  @override
  State<DetailedAllWeatherView> createState() => _DetailedAllWeatherViewState();
}

class _DetailedAllWeatherViewState extends State<DetailedAllWeatherView> {
  DocumentSnapshot? detailedLocationForecastSnapshot;
  late CurrentWeather detailedLocationForecastData;
  bool _gotData = false;
  static const daysOfWeekAbr = [
    '',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
  ];

  get title => widget.title;

  get latitude => widget.latitude;

  get longitude => widget.longitude;

  get detailedLocationForecastDataCurrent =>
      detailedLocationForecastData.current;

  @override
  void initState() {
    super.initState();
    // get the location data for the specified location
    fetchLocationData().whenComplete(() {
      setState(() {
        _gotData = true;
      });
    });
  }

  Future<void> fetchLocationData() async {
    /// fetchLocationData fetches current detailed weather data from API or DB

    OpenWeather openWeatherClass =
        OpenWeather(latitude: latitude, longitude: longitude);

    // If the data exists in the db and its been updated less than an hour ago use the data from the db
    if (await openWeatherClass.checkIfDocExistsForLocation()) {
      CurrentWeather detailedWeatherForecastFromDB =
          await openWeatherClass.fetchCurrentWeatherForecastFromFirestore();
      // data in db was updated less than an hour ago
      if (detailedWeatherForecastFromDB.lastUpdated >
          DateTime.now().millisecondsSinceEpoch ~/ 1000 - 360) {
        detailedLocationForecastData = detailedWeatherForecastFromDB;
        print('USING DATA FROM DB');
        // data was updated more than an hour ago ... use data from API call
      } else {
        detailedLocationForecastData =
            await openWeatherClass.fetchCurrentWeatherForecast(
                await openWeatherClass.getCurrentWeatherAPIUrl(
                    latitude: widget.latitude, longitude: widget.longitude));
        print('USING DATA FROM API');
      }

      // Data doesn't currently exist in the database ... use the data from the API Call
    } else {
      detailedLocationForecastData =
          await openWeatherClass.fetchCurrentWeatherForecast(
              await openWeatherClass.getCurrentWeatherAPIUrl(
                  latitude: widget.latitude, longitude: widget.longitude));
      print('USING DATA FROM API');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_gotData) {
      return const ProgressWithIcon();
    }
    return Scaffold(
        appBar: AppBar(title: Text('$title Detailed')),
        body: SingleChildScrollView(
          physics: const ScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Alerts widget
              Flexible(
                  flex: 1,
                  fit: FlexFit.loose,
                  child: alertsWidget(context)),
              // Current weather summary bar
              Flexible(
                  flex: 1,
                  fit: FlexFit.loose,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [currentWeatherSummaryWidget(context)],
                  )),
              // 24 hour forecast horizontal scroll widget
              hourlyWeatherWidget(context),
              // Daily summary vertical scroll List
              dailyWeatherWidgets(context),
              // Current detailed grids
              currentWeatherGridWidget(context),
            ],
          ),
        ));
  }

  /*------------------------------------
  *           ALERTS
  * ----------------------------------*/
  Widget alertsWidget(BuildContext context) {
    /// List tile view of all active alerts -
    /// returns the alert tiles if there are any alerts.
    /// Returns an empty widget if there are no alerts.

    // if there are alerts, return the alert widget list
    if (detailedLocationForecastData.alerts.isNotEmpty) {
      return formattingWidget(
        Column(
          children: [
            Container(
                padding: const EdgeInsets.only(left: 10.0),
                alignment: Alignment.centerLeft,
                child: const Text('Weather Alerts')),
            ListView.builder(
              shrinkWrap: true,
              itemCount: detailedLocationForecastData.alerts.length,
              itemBuilder: (context, index) {
                var effectEndTime = dateTimeToHumanReadable(
                    convertToLocationLocalTime(
                        detailedLocationForecastData.lat,
                        detailedLocationForecastData.lon,
                        detailedLocationForecastData.alerts[index]['end']));
                var effectStartTime = dateTimeToHumanReadable(convertToLocationLocalTime(detailedLocationForecastData.lat, detailedLocationForecastData.lon, detailedLocationForecastData.alerts[index]['start']));
                  return ListTile(
                      title: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Title
                          Flexible(
                              fit: FlexFit.loose,
                              child: Text(
                                '${detailedLocationForecastData.alerts[index]['event']}',
                                style: Theme.of(context).textTheme.headlineSmall,
                              )),
                          // In effect until ...
                          Flexible(
                            fit: FlexFit.loose,
                            child: Text(
                              'In effect from $effectStartTime\n until $effectEndTime',
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          // Sender
                          Flexible(
                              fit: FlexFit.loose,
                              child: Text(
                                '${detailedLocationForecastData.alerts[index]['sender_name']}',
                                style: Theme.of(context).textTheme.bodySmall,
                              )),
                        ],
                      ),
                      // onTap() => longer detail
                      onTap: () async {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DetailedAlertScreen(
                                    detailedLocationForecastDataAlerts:
                                        detailedLocationForecastData.alerts[index], effectStartTime: effectStartTime, effectEndTime: effectEndTime)));
                      });
                },
              ),
            ],
          ),
      );
      // no alerts -- return an empty widget
    } else {
      return const SizedBox.shrink();
    }
  }

  /*------------------------------------
  *        CURRENT SUMMARY
  * ----------------------------------*/
  Widget currentWeatherSummaryWidget(BuildContext context) {
    /// builds the current weather top widget bar
    return formattingWidget(
      Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            child: const Text('Current Weather Summary'),
          ),
          Row(
            children: [
              // current temp
              Flexible(
                fit: FlexFit.loose,
                child: Text(
                    'Current Temp\n${(detailedLocationForecastDataCurrent['temp'] / 1).floor()}\u{00B0}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                // feels like
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(
                    'Feels Like\n${(detailedLocationForecastDataCurrent['feels_like'] / 1).floor()}\u{00B0}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                // time
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(
                    'Date/Time\n'
                    '${dateTimeToHumanReadable(convertToLocationLocalTime(detailedLocationForecastData.lat, detailedLocationForecastData.lon, detailedLocationForecastDataCurrent['dt']))}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                // time
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(
                    'Humidity\n${detailedLocationForecastDataCurrent['humidity']}%',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                // wind
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(
                    'Wind\n${detailedLocationForecastDataCurrent['wind_speed']} mph\n'
                    '${detailedLocationForecastDataCurrent['wind_gust']} gusts',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Transform.rotate(
                    angle:
                        detailedLocationForecastDataCurrent['wind_deg'] * (pi / 180),
                    child: const Icon(Icons.north)),
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(
                    'Weather\n${detailedLocationForecastDataCurrent['weather'][0]['description']}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ],
        ),
    );
  }

  /*------------------------------------
  *           HOURLY
  * ----------------------------------*/
  Widget hourlyWeatherWidget(BuildContext context) {
    /// Builds an hourly horizontal scroll bar of hourly data for the next 24 hours.
    return formattingWidget(
      Column(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 10.0),
            alignment: Alignment.centerLeft,
            child: const Text('24 Hour Forecast'),
          ),
          SizedBox(
            height: 100.0,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const ScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: 24,
                itemBuilder: (BuildContext context, int index) => _buildIndividualHourComponents(context, index),
                separatorBuilder: (BuildContext context, int index) => const VerticalDivider(
                  width: 10,
                  thickness: 1,
                  indent: 10,
                  endIndent: 10,
                  color: Colors.grey,

                ),
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildIndividualHourComponents(BuildContext context, index) {
    /// builds the individual hour widget
    String hourTime;
    if(index == 0) {
      hourTime = 'Now';
    } else {
      hourTime = convertEpochTimeTo12Hour(detailedLocationForecastData.hourly[index]['dt']);
    }
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // time
          Expanded(
              child: Text(hourTime)
          ),
          // weather icon
          Expanded(
              child: getHourlyWeatherIcon(index) ?? Text('${detailedLocationForecastData.hourly[index]['weather'][0]['main']}')
          ),
          // temperature
          Expanded(
              child: Text('${(detailedLocationForecastData.hourly[index]['temp'] / 1).ceil()}\u{00B0}')
          )
        ],
      ),
    );
  }

  Widget? getHourlyWeatherIcon(index) {
    /// Gets the weather icon for the hourly weather widget based on forecasted weather behavior
    Widget? weatherIcon;
    if (detailedLocationForecastData.hourly[index]['weather'][0]['main'] ==
        'Snow') {
      weatherIcon = const Icon(Icons.ac_unit, color: Colors.blue);
    } else
    if (detailedLocationForecastData.hourly[index]['weather'][0]['main'] ==
        'Rain') {
      weatherIcon = const Icon(Icons.water_drop, color: Colors.blue);
    } else
    if (detailedLocationForecastData.hourly[index]['weather'][0]['main'] ==
        'Clouds') {
      weatherIcon = const Icon(Icons.cloud, color: Colors.blue);
    } else
    if (detailedLocationForecastData.hourly[index]['weather'][0]['main'] == 'Thunder') {
      weatherIcon = const Icon(Icons.thunderstorm, color: Colors.blue);
    } else if(detailedLocationForecastData.hourly[index]['weather'][0]['main'] == 'Clear') {
      if(convertEpochToDateTime(detailedLocationForecastData.hourly[index]['dt']).hour >= 19 || convertEpochToDateTime(detailedLocationForecastData.hourly[index]['dt']).hour <= 7) {
        weatherIcon = const Icon(Icons.nightlight, color: Colors.blue);
      } else {
        weatherIcon = const Icon(Icons.wb_sunny, color: Colors.blue);
      }
    } else {
      weatherIcon = null;
    }
    return weatherIcon;
  }

  /*------------------------------------
  *           DAILY WEATHER
  * ----------------------------------*/
  Widget dailyWeatherWidgets (BuildContext context) {
    return formattingWidget(
      Column(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 10.0),
            alignment: Alignment.centerLeft,
            child: const Text('8 Day Forecast'),
          ),
          const Divider(
            height: 10,
            thickness: 1,
            indent: 10,
            endIndent: 10,
              color: Colors.grey,
            ),
            ListView.separated(
                shrinkWrap: true,
                physics: const ScrollPhysics(),
                itemCount: detailedLocationForecastData.daily.length,
                itemBuilder: (context, index) =>
                    _buildListViewDailyWidget(
                        context, index, latitude, longitude),
              separatorBuilder: (BuildContext context, int index) => const Divider(
                height: 10,
                thickness: 1,
                indent: 10,
                endIndent: 10,
                color: Colors.grey,
              ),),
          ],
        ),
    );
  }

  Widget _buildListViewDailyWidget(
      BuildContext context, index, latitude, longitude) {
    /// builds the daily simple widget rows
    List precipitation =
        getDailyPrecipitation(detailedLocationForecastData, index);
    String weatherType = precipitation[0];
    String dailyQpf = precipitation[1];

    List dailyTemps = getDailyTemperatures(detailedLocationForecastData, index);
    String minTemp = '${(dailyTemps[0] / 1).ceil().toString()}\u{00B0}';
    String maxTemp = '${(dailyTemps[1] / 1).ceil().toString()}\u{00B0}';
    String mornTemp = '${(dailyTemps[2] / 1).ceil().toString()}\u{00B0}';
    String dayTemp = '${(dailyTemps[3] / 1).ceil().toString()}\u{00B0}';
    String eveTemp = '${(dailyTemps[4] / 1).ceil().toString()}\u{00B0}';
    String nightTemp = '${(dailyTemps[5] / 1).ceil().toString()}\u{00B0}';

    // use the larger of the two predictions between NWS and OpenWeather
    var dayStartTime =
        convertEpochToDateTime(detailedLocationForecastData.daily[index]['dt']);
    nwsLocationDailySnowfall(dayStartTime, latitude, longitude).then((value) {
      if (value > double.parse(dailyQpf)) {
        print('USING NWS SNOWFALL PREDICTIONS');
        dailyQpf = value.toString();
      } else {
        print('USING OPENWEATHER SNOWFALL PREDICTIONS');
      }
    });

    String getDayOfWeek(index) {
      if(index == 0){
        return 'Today';
      } else {
        return daysOfWeekAbr[convertToLocationLocalTime(latitude, longitude, detailedLocationForecastData.daily[index]['dt']).weekday];
      }
    }

    return ListTile(
        title: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Day and Date
            Expanded(
              child: Text(
                getDayOfWeek(index),
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            // Precipitation probability
            Flexible(
              child: Text(
                'Chance\n${(detailedLocationForecastData.daily[index]['pop'] * 100 / 1).ceil()}%',
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            // temperatures
            Flexible(
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                  'Temperatures\nMin: $minTemp\n Max: $maxTemp',
                  style: Theme.of(context).textTheme.subtitle1,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            // snowfall
            Flexible(
              child: Text(
                'Precipitation\n$weatherType $dailyQpf',
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
          ],
        ),
        onTap: () async {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DailyDetailedWeatherView(
                        title:
                            '$title ${daysOfWeekAbr[convertToLocationLocalTime(latitude, longitude, detailedLocationForecastData.daily[index]['dt']).weekday]}',
                        detailedLocationForecastData:
                            detailedLocationForecastData,
                      )));
        });
  }

  /*------------------------------------
  *           DETAIL GRID
  * ----------------------------------*/
  Widget currentWeatherGridWidget(BuildContext context) {
    /// builds the large widget grid with current details

    // Icon list for each grid (temperature, dew point, windchill, visibility,
    // air pressure, uv index, sunrise/sunset, humidity, wind direction,
    // and precipitation)
    List<Widget> detailGridItems = [
      const Icon(Icons.thermostat, size: 100.0, color: Colors.blue),
      // Temperature icon
      const Icon(Icons.thermostat, size: 100.0, color: Colors.blue),
      // Dew point icon
      const Icon(Icons.thermostat, size: 100.0, color: Colors.blue),
      // Wind chill icon
      const Icon(Icons.visibility, size: 100.0, color: Colors.blue),
      // Visibility icon    TODO find visibility icon
      const Icon(Icons.thermostat, size: 100.0, color: Colors.blue),
      // Air Pressure icon  TODO find air pressure icon
      const Icon(Icons.thermostat, size: 100.0, color: Colors.blue),
      // UV Index           TODO find UV index icon
      const Icon(Icons.thermostat, size: 100.0, color: Colors.blue),
      // Sunrise/Sunset     TODO find sunrise/sunset icon
      Image.asset('assets/images/humidity_icon.png'),
      // Humidity icon
      Transform.rotate(
          // Wind direction icon:
          // rotated to reflect actual wind direction in degrees true north
          angle: detailedLocationForecastDataCurrent['wind_deg'] * (pi / 180),
          child: const Icon(Icons.north, size: 100.0, color: Colors.blue)),
      getPrecipitationIcon()
      // Precipitation icon based on current precipitation conditions
    ];

    return GridView.builder(
        physics: const ScrollPhysics(),
        shrinkWrap: true,
        // make grid layout 2 widgets wide
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemCount: detailGridItems.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: InkResponse(
                child: Align(
                  alignment: Alignment.center,
                  child:
                      detailGridItems[index],
                ),
                onTap: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const GridDetailView()));
                }),
          );
        });
  }

  Widget getPrecipitationIcon() {
    /// Gets the precipitation icon for the detail grid widget based on forecasted precipitation behavior
    // TODO -- add more logic control statements to account for different precipitation possibilities

    if (detailedLocationForecastDataCurrent['weather'][0]['main'] == 'Snow') {
      return const Icon(Icons.ac_unit, size: 100.0, color: Colors.blue);
    } else if (detailedLocationForecastDataCurrent['weather'][0]['main'] ==
        'Rain') {
      return const Icon(Icons.water_drop, size: 100.0, color: Colors.blue);
    } else if (detailedLocationForecastDataCurrent['weather'][0]['main'] ==
        'Thunder') {
      return const Icon(Icons.thunderstorm, size: 100.0, color: Colors.blue);
    } else {
      return const Icon(
        Icons.water_drop,
        size: 100.0,
        color: Colors.blue,
      );
    }
  }

  /*------------------------------------
  *           FORMAT WIDGETS
  * ----------------------------------*/
  Widget formattingWidget(Widget widget) {
    /// adds consistent padding and borders to widgets on detailedForecastScreen page
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
            decoration:
                BoxDecoration(border: Border.all(color: Colors.blueAccent)),
            alignment: Alignment.center,
            child: widget));
  }
} // class _DetailedAllWeatherViewState extends State<DetailedAllWeatherView>

double convertMmToIn(qpf) {
  /// converts a double mm measurement to double inches
  return (qpf / 25.4).ceil().toDouble();
}

List<String> getDailyPrecipitation(detailedLocationForecastData, index) {
  /// gets daily precipitation totals in mm and returns total in inches

  // get the days rain total in mm and convert to inches
  String? precipitationRainQpf =
      convertMmToIn(detailedLocationForecastData?.daily[index]['rain'] ?? 0.0)
          .toString();
  // get the days rain total in mm and convert to inches
  String? precipitationSnowQpf =
      convertMmToIn(detailedLocationForecastData?.daily[index]['snow'] ?? 0.0)
          .toString();

  String? dailyQpf = '0.0';
  String? weatherType;
  // snow and rain count as snow only in mountains
  if (double.parse(precipitationRainQpf) > 0.0 &&
      double.parse(precipitationSnowQpf) > 0.0) {
    double tempSnow =
        double.parse(precipitationSnowQpf) + double.parse(precipitationRainQpf);
    dailyQpf = tempSnow.toString();
    weatherType = 'Snow';
  }
  // rain only
  else if (double.parse(precipitationRainQpf) > 0.0 &&
      double.parse(precipitationSnowQpf) <= 0.0) {
    dailyQpf = precipitationRainQpf;
    weatherType = 'Rain';
    // Snow only
  } else if (double.parse(precipitationRainQpf) <= 0.0 &&
      double.parse(precipitationSnowQpf) > 0.0) {
    dailyQpf = precipitationSnowQpf;
    weatherType = 'Snow';
    // no snow and no rain
  } else {
    dailyQpf = '0.0';
    weatherType = 'No rain or snow';
  }

  return [weatherType, dailyQpf];
}

List<num> getDailyTemperatures(detailedLocationForecastData, index) =>

    /// get the daily min, max, morning, day, evening, and night temperatures and returns them as a list
    [
      detailedLocationForecastData.daily[index]['temp']['min'],
      detailedLocationForecastData.daily[index]['temp']['max'],
      detailedLocationForecastData.daily[index]['temp']['morn'],
      detailedLocationForecastData.daily[index]['temp']['day'],
      detailedLocationForecastData.daily[index]['temp']['eve'],
      detailedLocationForecastData.daily[index]['temp']['night']
    ];

List<num> getDailyWindChillTemps(detailedLocationForecastData, index) =>

    /// get the daily morning, day, evening, and night wind chill temperatures and returns them as a list
    [
      detailedLocationForecastData.daily[index]['feels_like']['morn'],
      detailedLocationForecastData.daily[index]['feels_like']['day'],
      detailedLocationForecastData.daily[index]['feels_like']['eve'],
      detailedLocationForecastData.daily[index]['feels_like']['night']
    ];
