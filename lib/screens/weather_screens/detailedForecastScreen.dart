// Dart imports:
import 'dart:convert';
import 'dart:core';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
// Flutter imports:
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
// Project imports:
import 'package:snow_daze/auth/secrets.dart';
import 'package:snow_daze/interactions/worldWeatherOnlineAPI.dart';
import 'package:snow_daze/screens/weather_screens/detailedAlertScreen.dart';
import 'package:snow_daze/utilities/unitConverters.dart';
import 'package:tweet_ui/tweet_ui.dart';
import 'package:twitter_api_v2/twitter_api_v2.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../interactions/openWeatherClass.dart';
import '../../models/weather/currentWeather.dart';
import '../../models/weather/currentWeatherWWO.dart';
import '../../utilities/dailyPrecipitationTotals.dart';
import '../../utilities/getDailyTemperatures.dart';
import '../../utilities/getPrevious3DaysSnowFall.dart';
import '../../widgets/snowFlakeProgressIndicator.dart';
import 'detailedDailyForecastScreen.dart';

class DetailedForecastScreen extends StatefulWidget {
  final String latitude;
  final String longitude;
  final String resortName;
  final String resortTwitterUserName;
  final String resortState;
  final dynamic resortRoadConditions;
  final String resortForecastArea;
  final String resortForecastDiscussionLink;
  final String resortWebsite;
  final Map resortTrailMaps;
  final String liftTerrainStatus;

  const DetailedForecastScreen({
    super.key,
    required this.resortTwitterUserName,
    required this.latitude,
    required this.longitude,
    required this.resortName,
    required this.resortState,
    required this.resortRoadConditions,
    required this.resortForecastArea,
    required this.resortForecastDiscussionLink,
    required this.resortTrailMaps,
    required this.resortWebsite,
    required this.liftTerrainStatus,
  });

  @override
  State<DetailedForecastScreen> createState() => _DetailedForecastScreenState();
}

class _DetailedForecastScreenState extends State<DetailedForecastScreen> {
  DocumentSnapshot? detailedLocationForecastSnapshot;
  late ForecastWeatherWWO detailedLocationForecastDataWWO;
  late CurrentWeather detailedLocationForecastData;
  List tweetsList = [];
  List mapNames = [];
  List mapLinks = [];
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
    // get the list of tweets from account
    fetchTweets().whenComplete(() => {
          // get the list of trail map links from db
          fetchTrailMapUrls().whenComplete(() => {
                // get the location data for the specified location
                fetchLocationData().whenComplete(() {
                  setState(() {
                    _gotData = true;
                  });
                })
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
        appBar: AppBar(title: Text('$resortName Detailed'),
          backgroundColor: Color(0xff7686A6),),
        body: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image:
                      AssetImage('assets/images/winterSunsetBackground2.jpg'),
                  fit: BoxFit.cover)),
          child: SingleChildScrollView(
              physics: const ScrollPhysics(),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                resortDetails(),
                // TRAFFIC
                trafficConditionsWidget(),
                // ALERTS
                Flexible(
                    flex: 1, fit: FlexFit.loose, child: alertsWidget(context)),
                // NWS FORECAST DISCUSSION
                forecastDiscussionWidget(context),
                // CURRENT WEATHER
                Flexible(
                    flex: 1,
                    fit: FlexFit.loose,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [currentWeatherSummaryWidget(context)],
                    )),
                // DAILY WEATHER
                dailyWeatherWidgets(context),
                // TWITTER
                twitterTimeLineWidget()
              ])),
        ));
  }

  /*------------------------------------
  *          ASYNC FETCHERS
  * ----------------------------------*/

  Future<void> fetchLocationData() async {
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
            await worldWeatherClass.fetchCurrentWeatherForecastFromWWOAPI(
                await worldWeatherClass.getCurrentWeatherAPIUrl());
      }

      // Data doesn't currently exist in the database ... use the data from the API Call
    } else {
      detailedLocationForecastDataWWO =
          await worldWeatherClass.fetchCurrentWeatherForecastFromWWOAPI(
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
        userFields: [UserField.profileImageUrl, UserField.name]);
    String userID = userResponse.data.id;

    // Get all tweets from the beginning of today
    var timeNow = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        DateTime.now().hour,
        DateTime.now().minute,
        DateTime.now().second);
    var timeBeginningDay =
        DateTime(timeNow.year, timeNow.month, timeNow.day, 0, 0).toUtc();
    timeNow = timeNow.toUtc();
    try {
      var tweetsResponse = await _twitter.tweets.lookupTweets(
          userId: userID,
          startTime: timeBeginningDay,
          endTime: timeNow,
          expansions: TweetExpansion.values,
          tweetFields: [
            TweetField.createdAt,
            TweetField.source,
            TweetField.entities
          ],
          mediaFields: MediaField.values,
          userFields: [
            UserField.profileImageUrl,
            UserField.createdAt,
            UserField.entities,
            UserField.url
          ],
          placeFields: PlaceField.values);
      for (var element in tweetsResponse.data) {
        tweetsList.add((jsonEncode(element)));
      }
    } catch (e) {
      var tweetsResponse = await _twitter.tweets.lookupTweets(
        userId: userID,
        maxResults: 10,
        tweetFields: [
          TweetField.createdAt,
          TweetField.source,
          TweetField.entities
        ],
        userFields: [
          UserField.profileImageUrl,
          UserField.createdAt,
          UserField.entities,
          UserField.url
        ],
      );
      for (var element in tweetsResponse.data) {
        tweetsList.add((jsonEncode(element)));
      }
    }
  }

  Future<void> fetchTrailMapUrls() async {
    await resortTrailMaps.forEach((k, v) async {
      mapNames.add(k);
      mapLinks
          .add(await FirebaseStorage.instance.refFromURL(v).getDownloadURL());
    });
  }

  /*------------------------------------
  *         RESORT DETAILS
  * ----------------------------------*/

  Widget resortDetails() {
    return formattingWidget(Column(
      children: [
        Container(
            padding: const EdgeInsets.only(left: 10.0),
            alignment: Alignment.centerLeft,
            child: const Text(
              'Resort Details',
              textAlign: TextAlign.left,
              style: TextStyle(
                  color: Color(0xFF454259), fontWeight: FontWeight.bold),
            )),
        horizontalDivider(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            child: const Text(
              'Resort Website',
              style: TextStyle(color: Colors.blueAccent, fontSize: 25),
            ),
            onTap: () => launchUrl(
              Uri.parse(resortWebsite),
              mode: LaunchMode.externalApplication,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            child: const Text(
              'Lift and Terrain Status',
              style: TextStyle(color: Colors.blueAccent, fontSize: 25),
            ),
            onTap: () => launchUrl(
              Uri.parse(liftTerrainStatus),
              mode: LaunchMode.externalApplication,
            ),
          ),
        ),
        ListView.builder(
            padding: const EdgeInsets.all(0.0),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: resortTrailMaps.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Container(
                  alignment: Alignment.center,
                  child: InkWell(
                    child: Text(
                      '${mapNames[index]} Winter Trail Map',
                      style: const TextStyle(
                          color: Colors.blueAccent, fontSize: 25),
                    ),
                    onTap: () => launchUrl(Uri.parse(mapLinks[index]),
                        mode: LaunchMode.externalApplication),
                  ),
                ),
              );
            }),
      ],
    ));
  }

  /*------------------------------------
  *          TRAFFIC CONDITIONS
  * ----------------------------------*/

  Widget trafficConditionsWidget() {
    /// Renders the traffic widget with links for each resort
    String title;
    if (resortState == 'CA') {
      title = 'CalTrans Road Conditions';
    } else if (resortState == 'WA') {
      title = 'WASDOT Road Conditions';
    } else if (resortState == 'NV') {
      title = 'Nevada Road Conditions';
    } else {
      title = 'Colorado Road Conditions';
    }

    if (resortState == 'CA' || resortState == 'NV' || resortState == 'CO') {
      return formattingWidget(Column(children: [
        Container(
            padding: const EdgeInsets.only(left: 10.0),
            alignment: Alignment.centerLeft,
            child: const Text(
              'Road Conditions',
              style: TextStyle(
                  color: Color(0xFF454259), fontWeight: FontWeight.bold),
            )),
        horizontalDivider(),
        InkWell(
          child: Text(
            title,
            style: const TextStyle(color: Colors.blueAccent, fontSize: 25),
          ),
          onTap: () => launchUrl(Uri.parse(resortRoadConditions)),
        ),
      ]));
    } else if (resortState == 'WA') {
      return formattingWidget(Column(children: [
        Container(
            padding: const EdgeInsets.only(left: 10.0),
            alignment: Alignment.centerLeft,
            child: Text(title)),
        horizontalDivider(),
        InkWell(
          child: const Text(
            'Traffic Alerts',
            style: TextStyle(color: Colors.blueAccent, fontSize: 25),
          ),
          onTap: () =>
              launchUrl(Uri.parse(resortRoadConditions['roadAlertsLink'])),
        ),
        InkWell(
          child: const Text(
            'Traffic Cameras',
            style: TextStyle(color: Colors.blueAccent, fontSize: 25),
          ),
          onTap: () =>
              launchUrl(Uri.parse(resortRoadConditions['roadCamerasLink'])),
        ),
        InkWell(
          child: const Text(
            'Mountain Pass Report',
            style: TextStyle(color: Colors.blueAccent, fontSize: 25),
          ),
          onTap: () => launchUrl(
              Uri.parse(resortRoadConditions['mountainPassReportLink'])),
        ),
        InkWell(
          child: const Text(
            'Truck Restrictions',
            style: TextStyle(color: Colors.blueAccent, fontSize: 25),
          ),
          onTap: () => launchUrl(
              Uri.parse(resortRoadConditions['truckRestictionsLink'])),
        ),
      ]));
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
                child: const Text(
                  'Weather Alerts',
                  style: TextStyle(
                      color: Color(0xFF454259), fontWeight: FontWeight.bold),
                )),
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
                        detailedLocationForecastDataWWO.alerts[index]
                            ['start']));
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
                            )
                        ),
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
  *       FORECAST DISCUSSION
  * ----------------------------------*/
  Widget forecastDiscussionWidget(context) {
    return formattingWidget(Column(children: [
      Container(
          padding: const EdgeInsets.only(left: 10.0),
          alignment: Alignment.centerLeft,
          child: Text(
            'NWS Area Forecast Discussion - $resortForecastArea',
            style: const TextStyle(
                color: Color(0xFF454259), fontWeight: FontWeight.bold),
          )),
      horizontalDivider(),
      InkWell(
        child: const Text(
          'NWS Forecast Discussion',
          style: TextStyle(color: Colors.blueAccent, fontSize: 25),
        ),
        onTap: () => launchUrl(Uri.parse(forecastDiscussionLink)),
      ),
    ]));
  }

  /*------------------------------------
  *        CURRENT SUMMARY
  * ----------------------------------*/
  Widget currentWeatherSummaryWidget(BuildContext context) {
    String previous3DaySnowFallIn =
        getPrevious3DaysSnowFall(previousWeatherWWO);

    /// builds the current weather top widget bar
    return InkWell(
      child: formattingWidget(
        Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                'Weather Summary - ${dateTimeToHumanReadable(convertToLocationLocalTime(detailedLocationForecastData.lat, detailedLocationForecastData.lon, detailedLocationForecastDataCurrent['dt']))}',
                style: const TextStyle(
                    color: Color(0xFF454259), fontWeight: FontWeight.bold),
              ),
            ),
            horizontalDivider(),
            Column(
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // current temp
                      Flexible(
                        fit: FlexFit.loose,
                        child: Text(
                          'Temp: ${(detailedLocationForecastDataCurrent['temp'] / 1).floor()}\u{00B0}',
                          style: const TextStyle(
                            color: Color(0xFF454259),
                            fontWeight: FontWeight.bold,),
                        ),
                      ),
                      // feels like
                      Flexible(
                        fit: FlexFit.loose,
                        child: Text(
                          'Feels Like: ${(detailedLocationForecastDataCurrent['feels_like'] / 1).floor()}\u{00B0}',
                          style: const TextStyle(
                            color: Color(0xFF454259),
                            fontWeight: FontWeight.bold,),
                        ),
                      ),
                    ]),
                const SizedBox(height: 15.0,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // humidity
                    Flexible(
                      fit: FlexFit.loose,
                      child: Text(
                        'Humidity: ${detailedLocationForecastDataCurrent['humidity']}%',
                        style: const TextStyle(
                          color: Color(0xFF454259),
                          fontWeight: FontWeight.bold,),
                      ),
                    ),
                    // wind
                    Flexible(
                      fit: FlexFit.loose,
                      child: Text(
                        'Wind: ${detailedLocationForecastDataCurrent['wind_speed']} mph ${getWindDirectionFromDeg(detailedLocationForecastDataCurrent['wind_deg'])}',
                        style: const TextStyle(
                          color: Color(0xFF454259),
                          fontWeight: FontWeight.bold,),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15.0,),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(
                        fit: FlexFit.loose,
                        child: Text(
                          'Weather: ${detailedLocationForecastDataCurrent['weather'][0]['description']}',
                          style: const TextStyle(
                            color: Color(0xFF454259),
                            fontWeight: FontWeight.bold,),
                        ),
                      ),
                      // Last 3 Days Snowfall
                      Flexible(
                        fit: FlexFit.loose,
                        child: Text(
                          'Prev. 72hr Snowfall: $previous3DaySnowFallIn in',
                          style: const TextStyle(
                            color: Color(0xFF454259),
                            fontWeight: FontWeight.bold,),
                        ),
                      ),
                    ])
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
            child: const Text(
              '6 Day Forecast',
              style: TextStyle(
                  color: Color(0xFF454259), fontWeight: FontWeight.bold),
            ),
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
                style: const TextStyle(
                  color: Color(0xFF454259),
                  fontWeight: FontWeight.bold,),
              ),
            ),
            // Precipitation probability
            Flexible(
              fit: FlexFit.tight,
              child: Text(
                'Snow Chance\n${detailedLocationForecastDataWWO.dailyWeather[index]['chanceofsnow']}%',
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            // temperatures
            Flexible(
              fit: FlexFit.tight,
              child: Text(
                  'Min: $avgMin \nMax: $avgMax',
                  style: Theme.of(context).textTheme.subtitle1,
                  textAlign: TextAlign.left,
                ),
              ),
            // snowfall
            Flexible(
              fit: FlexFit.tight,
              child: Text(
                '$weatherType $dailyQpf in',
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

  Widget twitterTimeLineWidget() {
    return ListView.builder(
        padding: const EdgeInsets.all(10.0),
        primary: false,
        shrinkWrap: true,
        itemCount: tweetsList.length,
        itemBuilder: (context, index) {
          var tempTweet = jsonDecode(tweetsList[index]);
          var tempTime =
              DateTime.parse(tempTweet['created_at']).toLocal().toString();
          tempTweet['created_at'] = tempTime;
          return EmbeddedTweetView.fromTweetV2(
            TweetV2Response(
              data: tempTweet,
            ),
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

  get previousWeatherWWO =>
      detailedLocationForecastDataWWO.previous3DaysWeather['data']['weather'];

  get resortForecastArea => widget.resortForecastArea;

  get forecastDiscussionLink => widget.resortForecastDiscussionLink;

  get resortWebsite => widget.resortWebsite;

  get resortTrailMaps => widget.resortTrailMaps;

  get liftTerrainStatus => widget.liftTerrainStatus;

  /*------------------------------------
  *           FORMAT WIDGETS
  * ----------------------------------*/
  Widget formattingWidget(Widget widget) {
    /// adds consistent padding and borders to widgets on detailedForecastScreen page
    return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Card(
          elevation: 10.0,
          shadowColor: const Color(0xFF7686A6),
          color: const Color(0xBFFFB7AD),
          child: Container(
              decoration: BoxDecoration(
                  border: Border.all(
                color: const Color(0xFF7686A6),
              )),
              alignment: Alignment.center,
              child: widget),
        ));
  }

  Widget horizontalDivider() {
    /// returns a formatted Divider() widget
    return const Divider(
      height: 10,
      thickness: 1,
      indent: 10,
      endIndent: 10,
      color: Color(0xFF2F2C40),
    );
  }
} // class _DetailedAllWeatherViewState extends State<DetailedAllWeatherView>
