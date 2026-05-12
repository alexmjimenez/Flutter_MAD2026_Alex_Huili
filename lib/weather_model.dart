import 'package:json_annotation/json_annotation.dart';

part 'weather_model.g.dart';

@JsonSerializable()
class WeatherResponse {
  final MainData main;
  final List<WeatherData> weather;
  final String name;

  WeatherResponse({required this.main, required this.weather, required this.name});

  factory WeatherResponse.fromJson(Map<String, dynamic> json) => _$WeatherResponseFromJson(json);
  Map<String, dynamic> toJson() => _$WeatherResponseToJson(this);
}

@JsonSerializable()
class MainData {
  final double temp;

  MainData({required this.temp});

  factory MainData.fromJson(Map<String, dynamic> json) => _$MainDataFromJson(json);
  Map<String, dynamic> toJson() => _$MainDataToJson(this);
}

@JsonSerializable()
class WeatherData {
  final String description;
  final String icon;

  WeatherData({required this.description, required this.icon});

  factory WeatherData.fromJson(Map<String, dynamic> json) => _$WeatherDataFromJson(json);
  Map<String, dynamic> toJson() => _$WeatherDataToJson(this);
}