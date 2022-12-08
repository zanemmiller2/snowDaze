// Flutter Imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Firebase imports
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Package Imports
import 'package:sqflite/sqflite.dart';

// Screen Imports
import 'package:snow_daze/screens/login_page.dart';
import 'package:snow_daze/screens/temp_home.dart';

Future<void> main() async {

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
    return MultiProvider(
      providers: [
        Provider
      ]

    );
  }
}


