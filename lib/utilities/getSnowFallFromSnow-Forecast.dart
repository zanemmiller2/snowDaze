import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

Future<List> getSnowForecastSnowFall() async {
  List snowFallTotals = [];
  var response = await http.get(Uri.parse('https://www.snow-forecast.com/resorts/Stevens-Pass/12day/mid'));
  var document  = parse(response.body);
  var foreCastTableSnow = document.getElementsByClassName('forecast-table-snow forecast-table__row')[1].children;

  for (var child in foreCastTableSnow)
       {
    if (child.children[0].children[0].text == '-') {
      snowFallTotals.add(0.0);
    } else {
      snowFallTotals.add(
          (num.parse(child.children[0].children[0].text) * .393701)
              .floorToDouble());
    }
  }
  return snowFallTotals;
}

