// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:snow_daze/screens/splash_page.dart';
import '../../models/users/firebaseUser.dart';
import 'authHandler.dart';

class Wrapper extends StatelessWidget{
  const Wrapper({super.key});


  @override
  Widget build(BuildContext context) {

    final user =  Provider.of<FirebaseUser?>(context);

    if(user == null)
    {
      return const Handler();
    }else
    {
      return const MyHomePage(title: "snowDaze");
    }

  }
} 
