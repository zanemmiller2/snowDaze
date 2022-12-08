
import 'package:flutter/material.dart';
import 'package:snow_daze/screens/authenticate/register.dart';

import 'login.dart';

class Handler extends StatefulWidget {
  const Handler({super.key});

  @override
  State<StatefulWidget> createState() {
    return _Handler();
  }
}

class _Handler extends State<Handler> {

  bool showSignin = true;

  void toggleView(){
    setState(() {
      showSignin = !showSignin;
    });
  }
  @override
  Widget build(BuildContext context) {
    if(showSignin)
    {
      return Login(toggleView : toggleView);
    }else
    {
      return Register(toggleView : toggleView);
    }
  }
}