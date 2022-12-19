
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:snow_daze/screens/splash_page.dart';

import '../../models/FirebaseUser.dart';
import 'auth_handler.dart';

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