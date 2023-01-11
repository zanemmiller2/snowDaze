// Flutter imports:
import 'package:flutter/material.dart';

class DetailedAlertScreen extends StatelessWidget {
  final Map detailedLocationForecastDataAlerts;
  final String effectEndTime;
  final String effectStartTime;
  const DetailedAlertScreen({super.key, required this.detailedLocationForecastDataAlerts, required this.effectStartTime, required this.effectEndTime});

  @override
  Widget build(BuildContext context) {
    return Scaffold (
      appBar: AppBar(
        title: const Text('Severe Weather Alert'),
      ),
      body: SingleChildScrollView (
        padding: const EdgeInsets.all(10.0),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Flexible(
                fit: FlexFit.loose,
                child: Text(
                  '${detailedLocationForecastDataAlerts['event']}',
                  style: Theme.of(context).textTheme.headlineSmall,
                )),
            // In effect until ...
            Flexible(
              fit: FlexFit.loose,
              child: Text(
                'In effect from $effectStartTime\n until $effectEndTime',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            // Sender
            Flexible(
                fit: FlexFit.loose,
                child: Text(
                  '${detailedLocationForecastDataAlerts['sender_name']}',
                  style: Theme.of(context).textTheme.bodySmall,
                )),
            SizedBox(height: 25.0),
            Text(detailedLocationForecastDataAlerts['description'].replaceAll('\n', ''))
        ]),
      )
    );
  }
}
