// get previous weather data

// get forecast weather data

void main() {
  DateTime currentTime = DateTime.now();
  DateTime previousDayOpen = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day - 1, 9);
  DateTime previousDayCutoff = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day - 1, 13);
  DateTime previousDayClose = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day - 1, 16);
  DateTime currentDayOpen = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day, 9);
  DateTime currentDayCutoff = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day, 13);
  DateTime currentDayClose = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day, 16);
  DateTime nextDayOpen = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day + 1, 9);
  DateTime nextDayCutoff = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day + 1, 13);
  DateTime nextDayClose = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day + 1, 16);

  DateTime nextNextDayOpen = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day + 2, 9);
  DateTime nextNextDayCutoff = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day + 2, 13);
  DateTime nextNextDayClose = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day + 2, 16);

  double snowFallPowderThreshold = 10; // inches

  // current time is between 1pm yesterday and 8am today
  if (currentTime.isBefore(currentDayCutoff)) {
    // if snowfall between yesterday close and today open > 0.6in/hr inches
    //    -- powder day today

    // OR

    // if snowfall between yesterday close and today open is between 0.4 and 0.6 in/hr
    // and previous 3 day average > 4 in/day
    //    -- powder day today

    // OR
    // if snowfall between now and today open(9am) + today cutoff (1pm) > 10 inches
    //    -- powder day today

    // OR

    // if snowfall between cutoff yesterday and open today > 12 inches
    //    -- powder day today

    // if snowfall between today open and today close > 10 inches
    //    -- tomorrow pow day

    // OR

    // if snowfall between today open and tomorrow open > 15 inches
    //    -- tomorrow pow day

    // OR

    // if snowfall between today cutoff and tomorrow open > 12 inches
    //    -- tomorrow pow day

    // OR

    // if snowfall between today close and tomorrow open > 10 inches
    //    -- tomorrow pow day

  }

  // current time is between 1pm today and 9 am tomorrow
  if (currentTime.isAfter(currentDayCutoff)) {
    // today pow day doesnt matter -- null

    // if snowfall between now and tomorrow open > 12 inches
    //    -- tomorrow pow day

    // OR

    // if snowfall between today close and tomorrow open > 10 inches
    //    -- tomorrow pow day

    // if snowfall between now and tomorrow close > 17 inches
    //  -- pow day day after next

    // OR

    // if snowfall between tomorrow open and tomorrow close > 15 inches
    //  -- pow day day after next

    // OR

    // If snowfall between tomorrow cutoff and next next day open > 12 inches
    //    -- pow day day after next

    // OR

    // If snowfall between tomorrow close and next next day open > 10 inches
    //    -- pow day day after next

    // OR
    // if snowfall between tomorrow close and next next day cutoff > 12 inches
    //    -- pow day day after next
  }
}

void getPreviousWeatherData(DateTime startTime, DateTime endTime) {
  return;
}

void getForecastedWeatherData(DateTime startTime, DateTime endTime) {
  return;
}

void getPowderStatusToday() {
  return;
}

void getPowderStatusTomorrow() {
  return;
}

void getPowderStatusDayAfterTomorrow() {
  return;
}

