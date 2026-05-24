import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:geolocator/geolocator.dart';

import 'weather_model.dart';
import 'weather_api_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final logger = Logger();
  WeatherResponse? _weatherData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception("GPS disabled");

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw Exception("Permission denied");
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      final dio = Dio();
      final apiService = WeatherApiService(dio);
      const apiKey = "3e6cb458858bbbc6f173401b67ceca53";

      final response = await apiService.getCurrentWeather(
          position.latitude, position.longitude, apiKey, "metric", "es"
      );

      setState(() {
        _weatherData = response;
        _isLoading = false;
      });

    } catch (e) {
      logger.e("Error getting weather: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weather"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _weatherData == null
            ? const Text("Error loading weather")
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _weatherData!.name,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "${_weatherData!.main.temp.round()} °C",
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
            const SizedBox(height: 10),
            Text(
              _weatherData!.weather[0].description.toUpperCase(),
              style: const TextStyle(fontSize: 20, letterSpacing: 1.5),
            ),
            const SizedBox(height: 20),
            Image.network(
              "https://openweathermap.org/img/wn/${_weatherData!.weather[0].icon}@4x.png",
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            ),
          ],
        ),
      ),
    );
  }
}