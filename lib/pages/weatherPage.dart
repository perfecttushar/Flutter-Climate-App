import 'package:climate/models/weatherModel.dart';
import 'package:climate/services/weatherServices.dart';
import 'package:climate/theme/themeprovider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _weatherService = WeatherService('65fdd0da99ca19d31761339a2e91c61c');
  Weather? _weather;
  List<Weather>? _fourDayForecast;

  _fetchWeather() async {
    String cityName = await _weatherService.getCurrentCity();

    try {
      final weather = await _weatherService.getWeather(cityName);
      final fourDayForecast =
          await _weatherService.getFourDayForecastWithWeekday(cityName);

      setState(() {
        _weather = weather;
        _fourDayForecast = fourDayForecast;
      });
    } catch (e) {
      print(e);
    }
  }

  String getGreeting() {
    DateTime now = DateTime.now();
    int hour = now.hour;

    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'Good Evening';
    } else {
      return 'Good Evening';
    }
  }

  String getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return 'assets/search.json';

    switch (mainCondition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
        return 'assets/clouds.json';
      case 'haze':
      case 'dust':
      case 'fog':
        return 'assets/haze.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/rain.json';
      case 'thunderstorm':
        return 'assets/thunder.json';
      case 'clear':
        return 'assets/sunny.json';
      default:
        return 'assets/sunny.json';
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    //
    //
    //

    String greeting = getGreeting();
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('EEEE, dd MMM').format(now);

    //
    // Body
    //

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //
              // greetings & location
              //

              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$greeting,",
                        style: GoogleFonts.poppins(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.w500),
                      ),
                      Text(
                        _weather?.cityName ?? "Loading city..",
                        style: GoogleFonts.poppins(
                            fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () =>
                        Provider.of<ThemeProvider>(context, listen: false)
                            .toggleTheme(),
                    icon: const Icon(Icons.brightness_6_outlined),
                  )
                ],
              ),

              //
              // lottie and temperature
              //

              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_weather?.temperature.round()}°',
                    style: GoogleFonts.rubik(
                        fontSize: 110, fontWeight: FontWeight.w300),
                  ),
                  Lottie.asset(getWeatherAnimation(_weather?.mainCondition),
                      height: 140),
                ],
              ),

              //
              // status
              //

              const SizedBox(height: 20),
              Column(
                children: [
                  Row(
                    children: [
                      Text(
                        "Outdoor It's ",
                        style: GoogleFonts.poppins(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.w500),
                      ),
                      Text(
                        _weather?.mainCondition ?? "Fetching",
                        style: GoogleFonts.poppins(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),

              //
              // day & date
              //

              Text(
                "& It's $formattedDate",
                style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.w500),
              ),

              //
              //
              //

              const SizedBox(height: 20),
              Divider(
                thickness: 2,
                color: Theme.of(context).colorScheme.primary,
              ),

              //
              // 4 day forecast
              //
              const SizedBox(height: 15),
              if (_fourDayForecast == null)
                Center(
                  child: Column(
                    children: [
                      SizedBox(height: 50),
                      Lottie.asset('assets/line.json'),
                    ],
                  ),
                )
              else if (_fourDayForecast!.isEmpty)
                Center(
                  child: Text(
                    'Location Denied or Check Connection',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                    ),
                  ),
                )
              else
                for (Weather dailyWeather in _fourDayForecast!)
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      title: Text(
                        '${dailyWeather.weekday ?? "Unknown"}',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                      ),
                      trailing: SizedBox(
                        height: 50,
                        width: 120,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '${dailyWeather.temperature.round()}°',
                              style: GoogleFonts.rubik(
                                  fontSize: 22, fontWeight: FontWeight.w400),
                            ),
                            Lottie.asset(
                                getWeatherAnimation(dailyWeather.mainCondition),
                                height: 50),
                          ],
                        ),
                      ),
                      subtitle: Row(
                        children: [
                          Text(
                            'Likely to be ',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          Text(
                            '${dailyWeather.mainCondition}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
