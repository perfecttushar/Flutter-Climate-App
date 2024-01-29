import 'dart:convert';
import 'package:climate/models/weatherModel.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;

class WeatherService {
  static const BASE_URL = 'https://api.openweathermap.org/data/2.5/weather';
  final String apiKey;

  WeatherService(this.apiKey);

  Future<Weather> getWeather(String cityName) async {
    final response = await http
        .get(Uri.parse('$BASE_URL?q=$cityName&appid=$apiKey&units=metric'));

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<List<Weather>> getFourDayForecastWithWeekday(String cityName) async {
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&appid=$apiKey&units=metric'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> list = data['list'];

      List<Weather> fourDayForecast = [];

      // Find the index for tomorrow
      final DateTime now = DateTime.now();
      final int tomorrowIndex = list.indexWhere((dailyData) {
        final DateTime date =
            DateTime.fromMillisecondsSinceEpoch(dailyData['dt'] * 1000);
        return date.day == now.day + 1;
      });

      for (int i = tomorrowIndex; i < tomorrowIndex + 4 * 8; i += 8) {
        final Map<String, dynamic> dailyData = list[i];
        final DateTime date =
            DateTime.fromMillisecondsSinceEpoch(dailyData['dt'] * 1000);
        final String weekday = DateFormat('EEEE').format(date);

        final Weather weather = Weather.fromJson({
          'name': cityName,
          'main': {'temp': dailyData['main']['temp']},
          'weather': [
            {'main': dailyData['weather'][0]['main']}
          ],
        });
        weather.weekday = weekday;
        fourDayForecast.add(weather);
      }

      return fourDayForecast;
    } else {
      throw Exception('Failed to load 4-day forecast data');
    }
  }

  Future<String> getCurrentCity() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    String? city = placemarks[0].locality;

    return city ?? "";
  }
}
