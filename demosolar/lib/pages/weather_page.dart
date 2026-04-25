// lib/pages/weather_page.dart
// Weather & Alerts page.
// This page uses WeatherService to fetch weather from an API and also reads
// batteryPercentage from Firebase to show alerts when raining and battery is low.

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import '../services/weather_service.dart';
import '../models/battery_model.dart';

class WeatherPage extends StatefulWidget {
  final WeatherService weatherService;

  const WeatherPage({
    super.key,
    required this.weatherService,
  });

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  // Reference to Firebase battery node to read batteryPercentage.
  // TODO: Change "battery" to your own path.
  final DatabaseReference _batteryRef =
  FirebaseDatabase.instance.ref('battery'); // Dummy path.

  // TODO: Change this to your real city name (e.g., "Mumbai").
  static const String defaultCityName = 'YourCity';

  int _batteryPercentage = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: _batteryRef.onValue,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          final batteryModel = BatteryModel.fromMap(data);
          _batteryPercentage = batteryModel.batteryPercentage;
        }

        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder<WeatherInfo>(
              // Call the weather service to fetch current weather for the city.
              future: widget.weatherService.fetchCurrentWeather(defaultCityName),
              builder: (context, weatherSnapshot) {
                if (weatherSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (weatherSnapshot.hasError) {
                  return Center(
                    child:
                    Text('Error loading weather: ${weatherSnapshot.error}'),
                  );
                }

                if (!weatherSnapshot.hasData) {
                  return const Center(
                    child: Text('No weather data available.'),
                  );
                }

                final weather = weatherSnapshot.data!;
                final isRaining =
                weather.condition.toLowerCase().contains('rain');
                final isBatteryLow = _batteryPercentage < 25;

                List<Widget> alertWidgets = [];

                if (isRaining) {
                  alertWidgets.add(
                    const Text(
                      'It is raining, use the battery wisely.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }

                if (isBatteryLow) {
                  alertWidgets.add(
                    const SizedBox(height: 8),
                  );
                  alertWidgets.add(
                    const Text(
                      'Battery low. Consider reducing load.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Weather & Alerts',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'City: ${weather.cityName}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Temperature: ${weather.temperature.toStringAsFixed(1)} °C',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Condition: ${weather.condition}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Battery Percentage: $_batteryPercentage%',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      if (alertWidgets.isNotEmpty) ...alertWidgets,
                      const SizedBox(height: 24),
                      const Text(
                        'Tips for Better Usage:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• Schedule heavy loads when battery is above 50%.',
                        style: TextStyle(fontSize: 16),
                      ),
                      const Text(
                        '• Regularly clean your panels for best efficiency.',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
