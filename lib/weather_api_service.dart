import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'weather_model.dart';

part 'weather_api_service.g.dart';

@RestApi(baseUrl: "https://api.openweathermap.org/")
abstract class WeatherApiService {
  factory WeatherApiService(Dio dio, {String baseUrl}) = _WeatherApiService;

  @GET("data/2.5/weather")
  Future<WeatherResponse> getCurrentWeather(
      @Query("lat") double lat,
      @Query("lon") double lon,
      @Query("appid") String apiKey,
      @Query("units") String units,
      @Query("lang") String lang,
      );
}