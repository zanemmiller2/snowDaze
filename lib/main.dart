// Flutter Imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Firebase imports
import 'package:firebase_core/firebase_core.dart';
import 'package:snow_daze/screens/authenticate/authWrapper.dart';
import 'package:snow_daze/services/authService.dart';
// import 'firebase_options.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// Third Party Package Imports
// import 'package:sqflite/sqflite.dart';
import 'package:provider/provider.dart';

// Screen Imports
// import 'package:snow_daze/screens/splash_page.dart';

import 'models/FirebaseUser.dart';

// Custom Utility Imports

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp
  ]);

  // initialize Firebase using the DefaultFirebaseOptions object
  // exported by the configuration file
  await Firebase.initializeApp();

  runApp(const SnowDazeApp());
}

class SnowDazeApp extends StatelessWidget {
  const SnowDazeApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return StreamProvider<FirebaseUser?>.value(
      value: AuthService().user,
      initialData: null,
      child: MaterialApp(
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.black,
          buttonTheme: ButtonThemeData(
            buttonColor: Colors.black,
            textTheme: ButtonTextTheme.primary,
            colorScheme:
            Theme.of(context).colorScheme.copyWith(secondary: Colors.white),
          ),
          fontFamily: 'Georgia',
          textTheme: const TextTheme(
            headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
            headline6: TextStyle(fontSize: 20.0, fontStyle: FontStyle.italic),
            bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
          ),
          // colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.cyan[600]),
        ),
        home: const Wrapper(),
      ),);

  }
}

