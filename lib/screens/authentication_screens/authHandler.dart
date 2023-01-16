// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:snow_daze/screens/authentication_screens/register.dart';
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
