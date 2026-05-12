import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import 'weather_model.dart';
import 'weather_api_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
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
      final dio = Dio();
      final apiService = WeatherApiService(dio);

      const apiKey = "3e6cb458858bbbc6f173401b67ceca53";

      const lat = 40.3898;
      const lon = -3.6278;

      final response = await apiService.getCurrentWeather(
          lat, lon, apiKey, "metric", "es"
      );

      setState(() {
        _weatherData = response;
        _isLoading = false;
      });

    } catch (e) {
      logger.e("Error al obtener el tiempo: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Map & Weather"),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _weatherData == null
            ? const Text("Error al cargar el tiempo. Revisa tu conexión.")
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
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
    );
  }
}
