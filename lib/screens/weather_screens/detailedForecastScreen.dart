// Flutter imports:
// Package imports:
import 'dart:convert';
import 'dart:core';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:snow_daze/interactions/worldWeatherOnlineAPI.dart';
import 'package:snow_daze/screens/weather_screens/detailedAlertScreen.dart';
import 'package:snow_daze/utilities/unitConverters.dart';
import 'package:twitter_api_v2/twitter_api_v2.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Project imports:
import '../../auth/secrets.dart';
import '../../models/weather/currentWeather.dart';
import '../../interactions/openWeatherClass.dart';
import '../../models/weather/currentWeatherWWO.dart';
import '../../widgets/snowFlakeProgressIndicator.dart';
import 'detailedCurrentWeatherScreen.dart';
import 'detailedDailyForecastScreen.dart';
import 'gridViewDetailHourlyScreen.dart';
import 'package:twitter_api_v2/twitter_api_v2.dart';
import 'package:tweet_ui/tweet_ui.dart';

class DetailedForecastScreen extends StatefulWidget {
  final String latitude;
  final String longitude;
  final String resortName;
  final String twitterStreamHTML;

  const DetailedForecastScreen(
      {super.key,
        required this.twitterStreamHTML,
        required this.latitude,
        required this.longitude,
        required this.resortName}
      );

  @override
  State<DetailedForecastScreen> createState() => _DetailedForecastScreenState();
}

class _DetailedForecastScreenState extends State<DetailedForecastScreen> {
  late final WebViewController controller;
  DocumentSnapshot? detailedLocationForecastSnapshot;
  late ForecastWeatherWWO detailedLocationForecastDataWWO;
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

  late TwitterApi _twitter;

  get resortName => widget.resortName;

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
    //TODO CONVERT TO USING WORLD WEATHER ONLINE

    WorldWeatherClass worldWeatherClass = WorldWeatherClass(latitude: latitude, longitude: longitude, resortName: resortName);
    // If the data exists in the db and its been updated less than an hour ago use the data from the db
    bool exists = await worldWeatherClass.checkIfDocExistsForLocation();
    if (exists) {
      ForecastWeatherWWO detailedWeatherForecastFromDBWWO = await worldWeatherClass.fetchCurrentWeatherForecastFromFirestore();
      // data in db was updated less than an hour ago
      if (detailedWeatherForecastFromDBWWO.lastUpdated >
          DateTime.now().millisecondsSinceEpoch ~/ 1000 - 360) {
        detailedLocationForecastDataWWO = detailedWeatherForecastFromDBWWO;
        print('USING DATA FROM DB WWO');
        // data was updated more than an hour ago ... use data from API call
      } else {
        detailedLocationForecastDataWWO =
        await worldWeatherClass.fetchCurrentWeatherForecast(
            await worldWeatherClass.getCurrentWeatherAPIUrl());
        print('USING DATA FROM API WWO');
      }

      // Data doesn't currently exist in the database ... use the data from the API Call
    } else {
      detailedLocationForecastDataWWO =
      await worldWeatherClass.fetchCurrentWeatherForecast(
          await worldWeatherClass.getCurrentWeatherAPIUrl());
      print('USING DATA FROM API WWO');
    }

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

    /// Main Widget Driver
    if (!_gotData) {
      return const ProgressWithIcon();
    }
    return Scaffold(
        appBar: AppBar(title: Text('$resortName Detailed')),
        body: SingleChildScrollView(
          physics: const ScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Alerts widget
              Flexible(
                  flex: 1, fit: FlexFit.loose, child: alertsWidget(context)),
              // Current weather summary bar
              Flexible(
                  flex: 1,
                  fit: FlexFit.loose,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [currentWeatherSummaryWidget(context)],
                  )),
              // // 24 hour forecast horizontal scroll widget
              // hourlyWeatherWidget(context),
              // Daily summary vertical scroll List
              dailyWeatherWidgets(context),
              // // Hourly detailed grids
              // formattingWidget(
              //     Column(
              //       children: [
              //         Container(
              //             padding: const EdgeInsets.only(left: 10.0),
              //             alignment: Alignment.centerLeft,
              //             child: const Text('24 Hour Individual Detail')
              //         ),
              //         horizontalDivider(),
              //         currentWeatherGridWidget(context)
              //       ],
              //     )
              // ),
            FutureBuilder(
                future: _twitter.users.lookupByName(username: 'northstarmtn'),
                builder: (context, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final UserData me = snapshot.data.data;

                  return FutureBuilder(
                      future: _twitter.tweets.lookupTweets(
                        userId: me.id,
                        expansions: [
                          TweetExpansion.authorId,
                        ],
                        userFields: [
                          UserField.profileImageUrl,
                        ],
                      ),
                      builder: (context, AsyncSnapshot snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final TwitterResponse<List<TweetData>, TweetMeta> response = snapshot.data;
                        print(response.data.length);

                        return ListView.builder(
                          shrinkWrap: true,
                            itemCount: response.data.length,
                            itemBuilder: (context, index){
                              return EmbeddedTweetView.fromTweetV2(
                                TweetV2Response.fromJson(response.data[index].toJson()),
                              );
                            }
                        );



                      }
                  );
                }),
    ])
                  )
                  );
  }

  /*------------------------------------
  *           ALERTS
  * ----------------------------------*/
  Widget alertsWidget(BuildContext context) {
    /// List tile view of all active alerts -
    /// returns the alert tiles if there are any alerts.
    /// Returns an empty widget if there are no alerts.

    // if there are alerts, return the alert widget list
    if (detailedLocationForecastDataWWO.alerts.isNotEmpty) {
      return formattingWidget(
        Column(
          children: [
            Container(
                padding: const EdgeInsets.only(left: 10.0),
                alignment: Alignment.centerLeft,
                child: const Text('Weather Alerts')),
            ListView.builder(
              shrinkWrap: true,
              itemCount: detailedLocationForecastDataWWO.alerts.length,
              itemBuilder: (context, index) {
                var effectEndTime = dateTimeToHumanReadable(
                    convertToLocationLocalTime(
                        detailedLocationForecastDataWWO.latitude,
                        detailedLocationForecastDataWWO.longitude,
                        detailedLocationForecastDataWWO.alerts[index]['end']));
                var effectStartTime = dateTimeToHumanReadable(
                    convertToLocationLocalTime(
                        detailedLocationForecastDataWWO.latitude,
                        detailedLocationForecastDataWWO.longitude,
                        detailedLocationForecastDataWWO.alerts[index]['end']));
                return ListTile(
                    title: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        horizontalDivider(),
                        // Title
                        Flexible(
                            fit: FlexFit.loose,
                            child: Text(
                              '${detailedLocationForecastDataWWO.alerts[index]['event']}',
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
                              '${detailedLocationForecastDataWWO.alerts[index]['sender_name']}',
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
                                  detailedLocationForecastDataWWO
                                          .alerts[index],
                                  effectStartTime: effectStartTime,
                                  effectEndTime: effectEndTime)));
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
    return InkWell(
      child: formattingWidget(
        Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: const Text('Current Weather Summary'),
            ),
            horizontalDivider(),
            Column(
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // time
                      Flexible(
                        fit: FlexFit.loose,
                        child: Text(
                          '${dateTimeToHumanReadable(convertToLocationLocalTime(detailedLocationForecastData.lat, detailedLocationForecastData.lon, detailedLocationForecastDataCurrent['dt']))}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      // current temp
                      Flexible(
                        fit: FlexFit.loose,
                        child: Text(
                          'Current Temp: ${(detailedLocationForecastDataCurrent['temp'] / 1).floor()}\u{00B0}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      // feels like
                      Flexible(
                        fit: FlexFit.loose,
                        child: Text(
                          'Feels Like: ${(detailedLocationForecastDataCurrent['feels_like'] / 1).floor()}\u{00B0}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ]),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // humidity
                    Flexible(
                      fit: FlexFit.loose,
                      child: Text('Humidity: ${detailedLocationForecastDataCurrent['humidity']}%',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    // wind
                    Flexible(
                      fit: FlexFit.loose,
                      child: Text(
                        'Wind: ${detailedLocationForecastDataCurrent['wind_speed']} mph ${getWindDirectionFromDeg(detailedLocationForecastDataCurrent['wind_deg'])}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Text(
                        'Weather: ${detailedLocationForecastDataCurrent['weather'][0]['description']}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
      onTap: () async {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CurrentDetailedWeatherView(
                    resortName: resortName,
                    detailedLocationForecastDataCurrent:
                        detailedLocationForecastDataCurrent)));
      },
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
          horizontalDivider(),
          SizedBox(
            height: 100.0,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const ScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: 24,
              itemBuilder: (BuildContext context, int index) =>
                  _buildIndividualHourComponents(context, index),
              separatorBuilder: (BuildContext context, int index) =>
                  const VerticalDivider(
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
    if (index == 0) {
      hourTime = 'Now';
    } else {
      hourTime = convertEpochTimeTo12Hour(
          detailedLocationForecastData.hourly[index]['dt']);
    }
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // time
          Expanded(child: Text(hourTime)),
          // weather icon
          Expanded(
              child: getHourlyWeatherIcon(index) ??
                  Text(
                      '${detailedLocationForecastData.hourly[index]['weather'][0]['icon']}')),
          // temperature
          Expanded(
              child: Text(
                  '${(detailedLocationForecastData.hourly[index]['temp'] / 1).ceil()}\u{00B0}'))
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
    } else if (detailedLocationForecastData.hourly[index]['weather'][0]
            ['main'] ==
        'Rain') {
      weatherIcon = const Icon(Icons.water_drop, color: Colors.blue);
    } else if (detailedLocationForecastData.hourly[index]['weather'][0]
            ['main'] ==
        'Clouds') {
      weatherIcon = const Icon(Icons.cloud, color: Colors.blue);
    } else if (detailedLocationForecastData.hourly[index]['weather'][0]
            ['main'] ==
        'Thunder') {
      weatherIcon = const Icon(Icons.thunderstorm, color: Colors.blue);
    } else if (detailedLocationForecastData.hourly[index]['weather'][0]
            ['main'] ==
        'Clear') {
      if (convertEpochToDateTime(
                      detailedLocationForecastData.hourly[index]['dt'])
                  .hour >=
              19 ||
          convertEpochToDateTime(
                      detailedLocationForecastData.hourly[index]['dt'])
                  .hour <=
              7) {
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
  Widget dailyWeatherWidgets(BuildContext context) {
    return formattingWidget(
      Column(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 10.0),
            alignment: Alignment.centerLeft,
            child: const Text('6 Day Forecast'),
          ),
          horizontalDivider(),
          ListView.separated(
              shrinkWrap: true,
              physics: const ScrollPhysics(),
              itemCount: detailedLocationForecastDataWWO.dailyWeather.length,
              itemBuilder: (context, index) => _buildListViewDailyWidget(
                  context, index, latitude, longitude),
              separatorBuilder: (BuildContext context, int index) =>
                  horizontalDivider())
        ],
      ),
    );
  }

  Widget _buildListViewDailyWidget(
      BuildContext context, index, latitude, longitude) {
    /// builds the daily simple widget rows
    List precipitation =
        getDailyPrecipitation(detailedLocationForecastDataWWO.dailyWeather, index);
    String weatherType = precipitation[0];
    String dailyQpf = precipitation[1];

    List dailyTemps = getDailyTemperatures(detailedLocationForecastDataWWO.dailyWeather, index);
    String avgMin = '${(dailyTemps[0] / 1).ceil().toString()}\u{00B0}';
    String avgMax = '${(dailyTemps[1] / 1).ceil().toString()}\u{00B0}';

    String getDayOfWeek(index) {
      if (index == 0) {
        return 'Today';
      } else {
        return daysOfWeekAbr[convertYYYMMDDToDateTime(detailedLocationForecastDataWWO.dailyWeather[index]['date']).weekday];
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
                'Chance of Snow\n${detailedLocationForecastDataWWO.dailyWeather[index]['chanceofsnow']}%',
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            // temperatures
            Flexible(
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                  'Temperature\n Min: $avgMin \nMax: $avgMax',
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
                        resortName:
                            '$resortName ${daysOfWeekAbr[convertYYYMMDDToDateTime(detailedLocationForecastDataWWO.dailyWeather[index]['date']).weekday]}',
                        dailyDetailedLocationForecastDataWWO:
                        detailedLocationForecastDataWWO.dailyWeather[index],
                        index: index,
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
    List<Map<String, dynamic>> detailGridItems = [
      // Temperature icon
      {
        'title': 'temp',
        'actualTitle': 'Temperature',
        'icon': Image.asset('assets/images/thermometer_icon.png')
      },
      // Dew point icon
      {
        'title': 'dew_point',
        'actualTitle': 'Dew Point',
        'icon': Image.asset('assets/images/dewPoint_icon.png')
      },
      // Wind chill icon
      {
        'title': 'feels_like',
        'actualTitle': 'Wind Chill',
        'icon': Image.asset('assets/images/windchill_icon.png')
      },
      // Visibility icon
      {
        'title': 'visibility',
        'actualTitle': 'Visibility',
        'icon': Image.asset('assets/images/visibility_icon.png')
      },
      // Air Pressure icon
      {
        'title': 'pressure',
        'actualTitle': 'Air Pressure',
        'icon': getGridAirPressureIcon()
      },
      // UV Index
      {
        'title': 'uvi',
        'actualTitle': 'UV Index',
        'icon': Image.asset('assets/images/uvindex_icon.png')
      },
      // Sunrise/Sunset
      {
        'title': 'sun_rise',
        'actualTitle': 'Sunrise / Sunset',
        'icon': getGridSunRiseSunSetIcon()
      },
      // Humidity icon
      {
        'title': 'humidity',
        'actualTitle': 'Humidity',
        'icon': Image.asset('assets/images/humidity_icon.png')
      },
      // Wind direction icon:
      {
        'title': 'wind',
        'actualTitle': 'Wind',
        'icon': Transform.rotate(
            // rotated to reflect actual wind direction in degrees true north
            angle: detailedLocationForecastDataCurrent['wind_deg'] * (pi / 180),
            child: const Icon(Icons.north, size: 100.0, color: Colors.blue))
      },
      // Precipitation icon based on current precipitation conditions
      {
        'title': 'pop',
        'actualTitle': 'Probability of Precipitation',
        'icon': getGridPrecipitationIcon()
      }
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
                  child: detailGridItems[index]['icon'],
                ),
                onTap: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => GridDetailView(
                                resortName: resortName,
                                category: detailGridItems[index]['title'],
                                actualTitle: detailGridItems[index]
                                    ['actualTitle'],
                                detailedLocationForecastData:
                                    detailedLocationForecastData,
                              )));
                }),
          );
        });
  }

  Widget getGridPrecipitationIcon() {
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

  Widget getGridSunRiseSunSetIcon() {
    /// sets the sunrise/sunset icon based on current time of day in relation to sunrise/sunset time
    if (detailedLocationForecastDataCurrent['dt'] >
            detailedLocationForecastDataCurrent['sunrise'] &&
        detailedLocationForecastDataCurrent['dt'] <
            detailedLocationForecastDataCurrent['sunset']) {
      return Image.asset('assets/images/sunset_icon.png');
    } else {
      return Image.asset('assets/images/sunrise_icon.png');
    }
  }

  Widget getGridAirPressureIcon() {
    /// sets the air pressure icon based on future airpressure relative to current air pressure (rising or falling)
    int currentAirPressure = detailedLocationForecastDataCurrent['pressure'];
    for (var hour in detailedLocationForecastData.hourly) {
      // Air pressure rising over the next hours
      if (hour['pressure'] > currentAirPressure) {
        return Image.asset('assets/images/airpressure_up_icon.png');
        // Air pressure falling over the next hours
      } else if (hour['pressure'] < currentAirPressure) {
        return Image.asset('assets/images/airpressure_down_icon.png');
      }
    }
    // air pressure consisitent over the next
    return Image.asset('assets/images/airpressure_up_icon.png');
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

  Widget horizontalDivider() {
    /// returns a formatted Divider() widget
    return const Divider(
      height: 10,
      thickness: 1,
      indent: 10,
      endIndent: 10,
      color: Colors.grey,
    );
  }
} // class _DetailedAllWeatherViewState extends State<DetailedAllWeatherView>

List<String> getDailyPrecipitation(detailedLocationForecastData, index) {
  /// gets daily precipitation totals in mm and returns total in inches

  // get the days rain total in mm and convert to inches
  String? precipitationRainQpf =
      convertMmToIn(double.parse(detailedLocationForecastData[index]['precipMM'] ?? '0.0'))
          .toString();
  // get the days rain total in mm and convert to inches
  String? precipitationSnowQpf =
      convertCmToIn(double.parse(detailedLocationForecastData[index]['totalSnowfall_cm'] ?? '0.0'))
          .toString();

  String? dailyQpf = '0.0';
  String? weatherType;
  // snow and rain count as snow only in mountains
  if (double.parse(precipitationRainQpf) > 0.0 &&
      double.parse(precipitationSnowQpf) > 0.0) {
    dailyQpf = precipitationSnowQpf.toString();
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

List<num> getDailyTemperatures(detailedLocationForecastData, index) {
  num baseMin = double.parse(detailedLocationForecastData[index]['bottom'][0]['mintempF']);
  var baseMax = double.parse(detailedLocationForecastData[index]['bottom'][0]['maxtempF']);
  var midMin = double.parse(detailedLocationForecastData[index]['mid'][0]['mintempF']);
  var midMax = double.parse(detailedLocationForecastData[index]['mid'][0]['maxtempF']);
  var topMin = double.parse(detailedLocationForecastData[index]['top'][0]['mintempF']);
  var topMax = double.parse(detailedLocationForecastData[index]['top'][0]['maxtempF']);

  num avgMin = (baseMin + midMin + topMin) / 3;
  num avgMax = (baseMax + midMax + topMax) / 3;

  return [avgMin, avgMax];
}

List<num> getDailyWindChillTemps(detailedLocationForecastData, index) =>

    /// get the daily morning, day, evening, and night wind chill temperatures and returns them as a list
    [
      detailedLocationForecastData.daily[index]['feels_like']['morn'],
      detailedLocationForecastData.daily[index]['feels_like']['day'],
      detailedLocationForecastData.daily[index]['feels_like']['eve'],
      detailedLocationForecastData.daily[index]['feels_like']['night']
    ];
