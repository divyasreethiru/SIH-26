// lib/services/weather_service.dart
// Simple WeatherService that uses http to call OpenWeatherMap (or similar).
// It fetches current weather by city name and parses temperature and condition.

import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherInfo {
  final String cityName;
  final double temperature;
  final String condition;

  WeatherInfo({
    required this.cityName,
    required this.temperature,
    required this.condition,
  });
}

class WeatherService {
  // TODO: Replace this placeholder with your real OpenWeatherMap API key.
  // You can also load it from a secure place in the future.
  static const String openWeatherApiKeyPlaceholder = 'YOUR_OPENWEATHER_API_KEY_HERE';

  final String apiKey;

  WeatherService({required this.apiKey});

  // Fetch current weather for a given city.
  Future<WeatherInfo> fetchCurrentWeather(String cityName) async {
    // This URL uses the OpenWeatherMap current weather endpoint by city name.
    // It requests metric units so temperature is in Celsius. [web:19]
    final uri = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final weatherList = data['weather'] as List<dynamic>;
      final mainData = data['main'] as Map<String, dynamic>;

      final condition = weatherList.isNotEmpty
          ? (weatherList[0]['main'] as String)
          : 'Unknown';
      final temperature = (mainData['temp'] as num).toDouble();

      return WeatherInfo(
        cityName: data['name'] ?? cityName,
        temperature: temperature,
        condition: condition,
      );
    } else {
      throw Exception('Failed to load weather data (${response.statusCode})');
    }
  }
}
