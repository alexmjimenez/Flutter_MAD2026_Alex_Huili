// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeatherResponse _$WeatherResponseFromJson(Map<String, dynamic> json) =>
    WeatherResponse(
      main: MainData.fromJson(json['main'] as Map<String, dynamic>),
      weather: (json['weather'] as List<dynamic>)
          .map((e) => WeatherData.fromJson(e as Map<String, dynamic>))
          .toList(),
      name: json['name'] as String,
    );

Map<String, dynamic> _$WeatherResponseToJson(WeatherResponse instance) =>
    <String, dynamic>{
      'main': instance.main,
      'weather': instance.weather,
      'name': instance.name,
    };

MainData _$MainDataFromJson(Map<String, dynamic> json) =>
    MainData(temp: (json['temp'] as num).toDouble());

Map<String, dynamic> _$MainDataToJson(MainData instance) => <String, dynamic>{
  'temp': instance.temp,
};

WeatherData _$WeatherDataFromJson(Map<String, dynamic> json) => WeatherData(
  description: json['description'] as String,
  icon: json['icon'] as String,
);

Map<String, dynamic> _$WeatherDataToJson(WeatherData instance) =>
    <String, dynamic>{
      'description': instance.description,
      'icon': instance.icon,
    };
