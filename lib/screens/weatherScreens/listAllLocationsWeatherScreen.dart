import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:snow_daze/screens/weatherScreens/detailedAllLocationsWeatherScreen.dart';

class AllLocations extends StatefulWidget {
  const AllLocations({super.key});

  @override
  State<AllLocations> createState() => _AllLocationsState();
}

class _AllLocationsState extends State<AllLocations> {
  late StreamController<ResortLocation> resortLocationStreamController;
  List<ResortLocation> resortLocationList = [];

  @override
  void initState() {
    super.initState();

    resortLocationStreamController = StreamController.broadcast();
    resortLocationStreamController.stream
        .listen((location) => setState(() => resortLocationList.add(location)));
    loadResortLocations(resortLocationStreamController);
  }

  loadResortLocations(StreamController sc) async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('resorts').get();
    for (var doc in querySnapshot.docs) {
      ResortLocation.fromSnapshot(doc.data() as Map);
    }
  }

  @override
  void dispose() {
    super.dispose();
    resortLocationStreamController.close();
  }

  Widget _buildAvailableLocationsListItem(BuildContext context, index) {
    return ListTile(
        title: Row(
          children: [
            Expanded(
              child: Text(
                resortLocationList[index].resortName ?? 'none',
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xffddddff),
              ),
              padding: const EdgeInsets.all(10.0),
              child: Text(
                resortLocationList[index].latitude ?? '',
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xffddddff),
              ),
              padding: const EdgeInsets.all(10.0),
              child: Text(
                resortLocationList[index].longitude ?? '',
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    DetailedAllWeatherView(
                      latitude: resortLocationList[index].longitude ?? 'none',
                      longitude: resortLocationList[index].latitude ?? '',
                      title: resortLocationList[index].resortName ?? '',
                    )),
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("search all resorts page"),
        ),
        body: ListView.builder(
            itemExtent: 80.0,
            itemCount: resortLocationList.length,
            itemBuilder: (context, index) =>
                _buildAvailableLocationsListItem(context, index)));
  }
}

class ResortLocation {
  String? resortName;
  String? latitude;
  String? longitude;

  ResortLocation.fromSnapshot(Map map)
      : resortName = map['resortName'],
        latitude = map['latitude'],
        longitude = map['longitude'];
}