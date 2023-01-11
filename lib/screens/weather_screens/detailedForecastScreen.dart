// Flutter imports:

// Dart imports:
import 'dart:convert';
import 'dart:core';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tweet_ui/tweet_ui.dart';
import 'package:twitter_api_v2/twitter_api_v2.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:snow_daze/auth/secrets.dart';
import 'package:snow_daze/interactions/worldWeatherOnlineAPI.dart';
import 'package:snow_daze/screens/weather_screens/detailedAlertScreen.dart';
import 'package:snow_daze/utilities/unitConverters.dart';
import '../../interactions/openWeatherClass.dart';
import '../../models/weather/currentWeather.dart';
import '../../models/weather/currentWeatherWWO.dart';
import '../../widgets/snowFlakeProgressIndicator.dart';
import 'detailedDailyForecastScreen.dart';

class DetailedForecastScreen extends StatefulWidget {
  final String latitude;
  final String longitude;
  final String resortName;
  final String resortTwitterUserName;
  final String resortState;
  var resortRoadConditions;

  DetailedForecastScreen(
      {
        super.key,
        required this.resortTwitterUserName,
        required this.latitude,
        required this.longitude,
        required this.resortName,
        required this.resortState,
        required this.resortRoadConditions
      });

  @override
  State<DetailedForecastScreen> createState() => _DetailedForecastScreenState();
}

class _DetailedForecastScreenState extends State<DetailedForecastScreen> {

  DocumentSnapshot? detailedLocationForecastSnapshot;
  late ForecastWeatherWWO detailedLocationForecastDataWWO;
  late CurrentWeather detailedLocationForecastData;
  List tweetsList = [];
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
  // Initialize twitter handler
  final _twitter = TwitterApi(
    bearerToken: twitterBearerToken,
    retryConfig: RetryConfig(
      maxAttempts: 5,
      onExecute: (event) => print(
        'Retry after ${event.intervalInSeconds} seconds... '
            '[${event.retryCount} times]',
      ),
    ),
    timeout: const Duration(seconds: 10),
  );





  @override
  void initState() {
    super.initState();
    fetchTweets().whenComplete(() => {
      // get the location data for the specified location
      fetchLocationData().whenComplete(() {
        setState(() {
          _gotData = true;
        });
      })
    });
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
                  trafficConditionsWidget(),
                  // ALERTS
                  Flexible(
                      flex: 1, fit: FlexFit.loose,
                      child: alertsWidget(context)
                  ),
                  // CURRENT WEATHER
                  Flexible(
                      flex: 1,
                      fit: FlexFit.loose,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          currentWeatherSummaryWidget(context)
                        ],
                      )
                  ),
                  // DAILY WEATHER
                  dailyWeatherWidgets(context),
                  // TWITTER
                  twitterTimeLineWidget()
                ]
            )
        )
    );
  }

  /*------------------------------------
  *          ASYNC FETCHERS
  * ----------------------------------*/

  Future<void> fetchLocationData() async {
    //TODO CONVERT TO USING WORLD WEATHER ONLINE

    WorldWeatherClass worldWeatherClass = WorldWeatherClass(
        latitude: latitude, longitude: longitude, resortName: resortName);
    // If the data exists in the db and its been updated less than an hour ago use the data from the db
    bool exists = await worldWeatherClass.checkIfDocExistsForLocation();
    if (exists) {
      ForecastWeatherWWO detailedWeatherForecastFromDBWWO =
          await worldWeatherClass.fetchCurrentWeatherForecastFromFirestore();
      // data in db was updated less than an hour ago
      if (detailedWeatherForecastFromDBWWO.lastUpdated >
          DateTime.now().millisecondsSinceEpoch ~/ 1000 - 360) {
        detailedLocationForecastDataWWO = detailedWeatherForecastFromDBWWO;
        // data was updated more than an hour ago ... use data from API call
      } else {
        detailedLocationForecastDataWWO =
            await worldWeatherClass.fetchCurrentWeatherForecast(
                await worldWeatherClass.getCurrentWeatherAPIUrl());
      }

      // Data doesn't currently exist in the database ... use the data from the API Call
    } else {
      detailedLocationForecastDataWWO =
          await worldWeatherClass.fetchCurrentWeatherForecast(
              await worldWeatherClass.getCurrentWeatherAPIUrl());
    }

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
        // data was updated more than an hour ago ... use data from API call
      } else {
        detailedLocationForecastData =
            await openWeatherClass.fetchCurrentWeatherForecast(
                await openWeatherClass.getCurrentWeatherAPIUrl(
                    latitude: widget.latitude, longitude: widget.longitude));
      }

      // Data doesn't currently exist in the database ... use the data from the API Call
    } else {
      detailedLocationForecastData =
          await openWeatherClass.fetchCurrentWeatherForecast(
              await openWeatherClass.getCurrentWeatherAPIUrl(
                  latitude: widget.latitude, longitude: widget.longitude));
    }
  }

  Future<void> fetchTweets() async {
    // Get the userID from twitter UserName
    var userResponse = await _twitter.users.lookupByName(
        username: resortTwitterUserName,
        userFields: [UserField.profileImageUrl, UserField.name]
    );
    String userID = userResponse.data.id;

    // Get all tweets from the beginning of today
    var timeNow = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, DateTime.now().hour, DateTime.now().minute, DateTime.now().second);
    var timeBeginningDay = DateTime(timeNow.year, timeNow.month, timeNow.day, 0, 0).toUtc();
    timeNow = timeNow.toUtc();
    try {
      var tweetsResponse = await _twitter.tweets.lookupTweets(
          userId: userID,
          startTime: timeBeginningDay,
          endTime: timeNow,
          expansions: TweetExpansion.values,
          tweetFields: [TweetField.createdAt, TweetField.source, TweetField.entities],
          mediaFields: MediaField.values,
          userFields: [UserField.profileImageUrl, UserField.createdAt, UserField.entities, UserField.url],
          placeFields: PlaceField.values
      );
      for(var element in tweetsResponse.data) {
        tweetsList.add((jsonEncode(element)));
      }
    } catch(e) {
      var tweetsResponse = await _twitter.tweets.lookupTweets(
          userId: userID,
          maxResults: 10,
        tweetFields: [TweetField.createdAt, TweetField.source, TweetField.entities],
        userFields: [UserField.profileImageUrl, UserField.createdAt, UserField.entities, UserField.url],
      );
      for(var element in tweetsResponse.data) {
        tweetsList.add((jsonEncode(element)));
      }
    }
  }


  /*------------------------------------
  *          TRAFFIC CONDITIONS
  * ----------------------------------*/

  Widget trafficConditionsWidget () {
    /// Renders the traffic widget with links for each resort
    String title;
    if(resortState == 'CA') {
      title = 'CalTrans Road Conditions';
    } else if (resortState == 'WA') {
      title = 'WASDOT Road Conditions';
    } else if (resortState == 'NV'){
      title = 'Nevada Road Conditions';
    } else {
      title = 'Colorado Road Conditions';
    }

    if(resortState == 'CA' || resortState == 'NV' || resortState =='CO') {
      return formattingWidget(
          Column(
              children: [
                Container(
                    padding: const EdgeInsets.only(left: 10.0),
                    alignment: Alignment.centerLeft,
                    child: Text(title)
                ),
                horizontalDivider(),
                InkWell(
                  child: Text('$resortState Road Conditions Link',
                    style: const TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 25
                    ),
                  ),
                  onTap: () => launchUrl(Uri.parse(resortRoadConditions)),
                )
              ]
          )
      );
    } else if (resortState == 'WA') {
      return formattingWidget(
          Column(
              children: [
                Container(
                    padding: const EdgeInsets.only(left: 10.0),
                    alignment: Alignment.centerLeft,
                    child: Text(title)
                ),
                horizontalDivider(),
                InkWell(
                  child: const Text('Traffic Alerts',
                    style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 25
                  ),),
                  onTap: () => launchUrl(Uri.parse(resortRoadConditions['roadAlertsLink'])),
                ),
                InkWell(
                  child: const Text('Traffic Cameras',
                    style: TextStyle(
                      color: Colors.blueAccent,
                        fontSize: 25
                    ),
                  ),
                  onTap: () => launchUrl(Uri.parse(resortRoadConditions['roadCamerasLink'])),
                ),
                InkWell(
                  child: const Text('Mountain Pass Report',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 25
                    ),
                  ),
                  onTap: () => launchUrl(Uri.parse(resortRoadConditions['mountainPassReportLink'])),
                ),
                InkWell(
                  child: const Text('Truck Restrictions',
                    style: TextStyle(
                      color: Colors.blueAccent,
                        fontSize: 25
                    ),
                  ),
                  onTap: () => launchUrl(Uri.parse(resortRoadConditions['truckRestictionsLink'])),
                ),
              ]
          )
      );

    } else {
      return const SizedBox.shrink();
    }
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
                          dateTimeToHumanReadable(convertToLocationLocalTime(detailedLocationForecastData.lat, detailedLocationForecastData.lon, detailedLocationForecastDataCurrent['dt'])),
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
                      child: Text(
                        'Humidity: ${detailedLocationForecastDataCurrent['humidity']}%',
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
    );
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
    List precipitation = getDailyPrecipitation(
        detailedLocationForecastDataWWO.dailyWeather, index);
    String weatherType = precipitation[0];
    String dailyQpf = precipitation[1];

    List dailyTemps = getDailyTemperatures(
        detailedLocationForecastDataWWO.dailyWeather, index);
    String avgMin = '${(dailyTemps[0] / 1).ceil().toString()}\u{00B0}';
    String avgMax = '${(dailyTemps[1] / 1).ceil().toString()}\u{00B0}';

    String getDayOfWeek(index) {
      if (index == 0) {
        return 'Today';
      } else {
        return daysOfWeekAbr[convertYYYMMDDToDateTime(
                detailedLocationForecastDataWWO.dailyWeather[index]['date'])
            .weekday];
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
  *           TWITTER
  * ----------------------------------*/

  Widget twitterTimeLineWidget () {
    return ListView.builder(
        padding: const EdgeInsets.all(10.0),
        primary: false,
        shrinkWrap: true,
        itemCount: tweetsList.length,
        itemBuilder: (context, index) {
          var tempTweet = jsonDecode(tweetsList[index]);
          var tempTime = DateTime.parse(tempTweet['created_at']).toLocal().toString();
          tempTweet['created_at'] = tempTime;
          return EmbeddedTweetView.fromTweetV2(
            TweetV2Response(
              data: tempTweet,
            ),
            showRepliesCount: true,
          );
        });
  }


  /*------------------------------------
  *           GETTERS
  * ----------------------------------*/
  get resortName => widget.resortName;

  get latitude => widget.latitude;

  get longitude => widget.longitude;

  get detailedLocationForecastDataCurrent =>
      detailedLocationForecastData.current;

  get resortTwitterUserName => widget.resortTwitterUserName;

  get resortState => widget.resortState;
  get resortRoadConditions => widget.resortRoadConditions;

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
  String? precipitationRainQpf = convertMmToIn(double.parse(
          detailedLocationForecastData[index]['precipMM'] ?? '0.0'))
      .toString();
  // get the days rain total in mm and convert to inches
  String? precipitationSnowQpf = convertCmToIn(double.parse(
          detailedLocationForecastData[index]['totalSnowfall_cm'] ?? '0.0'))
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
  num baseMin = double.parse(
      detailedLocationForecastData[index]['bottom'][0]['mintempF']);
  var baseMax = double.parse(
      detailedLocationForecastData[index]['bottom'][0]['maxtempF']);
  var midMin =
      double.parse(detailedLocationForecastData[index]['mid'][0]['mintempF']);
  var midMax =
      double.parse(detailedLocationForecastData[index]['mid'][0]['maxtempF']);
  var topMin =
      double.parse(detailedLocationForecastData[index]['top'][0]['mintempF']);
  var topMax =
      double.parse(detailedLocationForecastData[index]['top'][0]['maxtempF']);

  num avgMin = (baseMin + midMin + topMin) / 3;
  num avgMax = (baseMax + midMax + topMax) / 3;

  return [avgMin, avgMax];
}
