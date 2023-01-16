


List<num> getDailyTemperatures(detailedLocationForecastData, index) {
  num baseMin = double.parse(
      detailedLocationForecastData[index]['bottom'][0]['mintempF']);
  var baseMax = double.parse(
      detailedLocationForecastData[index]['bottom'][0]['maxtempF']);
  var midMin =
  double.parse(detailedLocationForecastData[index]['mid'][0]['mintempF']);
  var midMax =
  double.parse(detailedLocationForecastData[index]['mid'][0]['maxtempF']);
  var topMin =
  double.parse(detailedLocationForecastData[index]['top'][0]['mintempF']);
  var topMax =
  double.parse(detailedLocationForecastData[index]['top'][0]['maxtempF']);

  num avgMin = (baseMin + midMin + topMin) / 3;
  num avgMax = (baseMax + midMax + topMax) / 3;

  return [avgMin, avgMax];
}