// Flutter imports:
import 'package:flutter/material.dart';

class ProgressWithIcon extends StatelessWidget {
  const ProgressWithIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: Stack(
        alignment: Alignment.center,
        children: const [
          Image(
            image: AssetImage('assets/images/snowflake-png.png'),
          ),
          // you can replace
          LinearProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            minHeight: 7.0,
          ),
        ],
      ),
    );
  }
}
