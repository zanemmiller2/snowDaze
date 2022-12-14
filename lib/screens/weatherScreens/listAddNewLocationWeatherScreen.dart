import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:snow_daze/screens/weatherScreens/detailedAddNewLocationWeatherScreen.dart';

class AddNewLocation extends StatelessWidget {
  const AddNewLocation({super.key});

  Widget _buildAvailableLocationsListItem(BuildContext context, DocumentSnapshot document) {
    return ListTile(
      title: Row(
        children: [
          Expanded(
            child: Text(
              document["resortName"],
              style: Theme
                  .of(context)
                  .textTheme
                  .subtitle1,
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xffddddff),
            ),
            padding: const EdgeInsets.all(10.0),
            child: Text(
              document["latitude"].toString(),
              style: Theme
                  .of(context)
                  .textTheme
                  .subtitle1,
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xffddddff),
            ),
            padding: const EdgeInsets.all(10.0),
            child: Text(
              document["longitude"].toString(),
              style: Theme
                  .of(context)
                  .textTheme
                  .subtitle1,
            ),
          ),
        ],
      ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    AddNewDetailedWeatherView(
                        latitude: document["latitude"].toString(),
                        longitude: document["longitude"].toString(), title: document["resortName"],)
            ),
          );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("search all resorts page"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('resorts').snapshots(),
        builder: (context, snapshot) {
          if(!snapshot.hasData){
            return const Text("Loading...");
          }
          return ListView.builder(
              itemExtent: 80.0,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) => _buildAvailableLocationsListItem(context, snapshot.data!.docs[index]));
        },
      ),
    );
  }

}