import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherForecastScreen extends StatefulWidget {
  final String cityName;
  final String apiKey;
  final Map<String, dynamic>? currentWeather;

  const WeatherForecastScreen({
    super.key,
    required this.cityName,
    required this.apiKey,
    this.currentWeather,
  });

  @override
  State<WeatherForecastScreen> createState() => _WeatherForecastScreenState();
}

class _WeatherForecastScreenState extends State<WeatherForecastScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _forecastData;
  List<dynamic> _hourlyForecast = [];
  List<dynamic> _dailyForecast = [];

  @override
  void initState() {
    super.initState();
    _fetchWeatherForecast();
  }

  Future<void> _fetchWeatherForecast() async {
    setState(() => _isLoading = true);

    try {
      // Fetch 3-day forecast with hourly data
      final url =
          'https://api.weatherapi.com/v1/forecast.json'
          '?key=${widget.apiKey}'
          '&q=${Uri.encodeComponent(widget.cityName)}'
          '&days=7'
          '&aqi=no'
          '&alerts=no';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          _forecastData = data;

          // Extract hourly forecast for today
          if (data['forecast'] != null &&
              data['forecast']['forecastday'] != null &&
              data['forecast']['forecastday'].isNotEmpty) {
            // Get today's hourly forecast
            final today = data['forecast']['forecastday'][0];
            if (today['hour'] != null) {
              // Filter to show only future hours from current time
              final now = DateTime.now();
              _hourlyForecast =
                  today['hour'].where((hour) {
                    final hourTime = DateTime.parse(hour['time']);
                    return hourTime.isAfter(now);
                  }).toList();

              // Add some hours from tomorrow if we don't have enough
              if (_hourlyForecast.length < 12 &&
                  data['forecast']['forecastday'].length > 1) {
                final tomorrow = data['forecast']['forecastday'][1];
                if (tomorrow['hour'] != null) {
                  final tomorrowHours =
                      tomorrow['hour']
                          .take(12 - _hourlyForecast.length)
                          .toList();
                  _hourlyForecast.addAll(tomorrowHours);
                }
              }
            }

            // Get daily forecast for next 7 days
            _dailyForecast = data['forecast']['forecastday'];
          }

          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Failed to load forecast data');
      }
    } catch (e) {
      debugPrint('Error fetching forecast: $e');
      setState(() => _isLoading = false);
      _showErrorSnackBar('Error loading forecast data');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFADF5E9),
      appBar: AppBar(
        title: const Text(
          'Weather in Kampar',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF00A651),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildForecastContent(),
    );
  }

  Widget _buildForecastContent() {
    // Get current weather data from passed in data or forecast data
    final current =
        widget.currentWeather?['current'] ?? _forecastData?['current'];

    if (current == null) {
      return const Center(child: Text('No weather data available'));
    }

    return RefreshIndicator(
      onRefresh: _fetchWeatherForecast,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Today's weather card
            _buildCurrentWeatherCard(current),

            // Hourly forecast
            _buildHourlyForecast(),

            // Daily forecast
            _buildDailyForecast(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentWeatherCard(Map<String, dynamic> current) {
    final temp = current['temp_c']?.toInt();
    final condition = current['condition']?['text'];
    final feelsLike = current['feelslike_c']?.toInt();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(DateTime.now()),
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text(
                        '$temp°C',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getWeatherColor(condition),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getWeatherIcon(condition),
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    condition ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Feels like: $feelsLike°C',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyForecast() {
    if (_hourlyForecast.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12, left: 4),
            child: Text(
              'Hourly Forecast',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          Container(
            height: 130,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount:
                  _hourlyForecast.length > 12 ? 12 : _hourlyForecast.length,
              itemBuilder: (context, index) {
                final hour = _hourlyForecast[index];
                return _buildHourlyItem(hour);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyItem(Map<String, dynamic> hour) {
    final time = DateTime.parse(hour['time']);
    final isFirstHour = _hourlyForecast.indexOf(hour) == 0;
    // Convert to integer
    final temp = hour['temp_c']?.toInt();
    final condition = hour['condition']?['text'];

    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isFirstHour ? 'Now' : _formatHour(time),
            style: TextStyle(
              fontSize: 14,
              fontWeight: isFirstHour ? FontWeight.bold : FontWeight.normal,
              color: isFirstHour ? const Color(0xFF00A651) : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getWeatherColor(condition).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getWeatherIcon(condition),
              color: _getWeatherColor(condition),
              size: 22,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            temp != null ? '$temp°C' : '-°C',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyForecast() {
    if (_dailyForecast.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12, left: 4, top: 8),
            child: Text(
              '7-Day Forecast',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _dailyForecast.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final day = _dailyForecast[index];
                return _buildDailyItem(day, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyItem(Map<String, dynamic> day, int index) {
    final date = DateTime.parse(day['date']);
    // Convert to integers
    final maxTemp =
        day['day']?['maxtemp_c'] != null
            ? day['day']['maxtemp_c'].toInt()
            : null;
    final minTemp =
        day['day']?['mintemp_c'] != null
            ? day['day']['mintemp_c'].toInt()
            : null;
    final condition = day['day']?['condition']?['text'];
    final chanceOfRain = day['day']?['daily_chance_of_rain'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Day
          SizedBox(
            width: 100,
            child: Text(
              index == 0
                  ? 'Today'
                  : index == 1
                  ? 'Tomorrow'
                  : _formatWeekday(date),
              style: TextStyle(
                fontSize: 15,
                fontWeight: index == 0 ? FontWeight.bold : FontWeight.normal,
                color: index == 0 ? const Color(0xFF00A651) : Colors.black87,
              ),
            ),
          ),

          // Rain chance
          Row(
            children: [
              Icon(Icons.water_drop, size: 14, color: Colors.blue.shade300),
              const SizedBox(width: 4),
              Text(
                '$chanceOfRain%',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),

          // Weather icon
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _getWeatherColor(condition).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getWeatherIcon(condition),
              color: _getWeatherColor(condition),
              size: 18,
            ),
          ),

          // Temperature range
          Row(
            children: [
              Text(
                minTemp != null ? '$minTemp°C' : '-°C',
                style: TextStyle(fontSize: 15, color: Colors.grey[600]),
              ),
              Container(
                width: 50,
                height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade300, Colors.orange.shade300],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                maxTemp != null ? '$maxTemp°C' : '-°C',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatHour(DateTime time) {
    final hour = time.hour;
    if (hour == 0) return '12 AM';
    if (hour < 12) return '$hour AM';
    if (hour == 12) return '12 PM';
    return '${hour - 12} PM';
  }

  String _formatWeekday(DateTime date) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[date.weekday - 1];
  }

  IconData _getWeatherIcon(String? condition) {
    if (condition == null) return Icons.cloud;

    condition = condition.toLowerCase();
    if (condition.contains('sun') || condition.contains('clear')) {
      return Icons.wb_sunny;
    } else if (condition.contains('rain') || condition.contains('drizzle')) {
      return Icons.grain;
    } else if (condition.contains('cloud')) {
      return Icons.cloud;
    } else if (condition.contains('snow') || condition.contains('sleet')) {
      return Icons.ac_unit;
    } else if (condition.contains('fog') || condition.contains('mist')) {
      return Icons.cloud_queue;
    } else if (condition.contains('thunder') || condition.contains('storm')) {
      return Icons.flash_on;
    } else {
      return Icons.cloud;
    }
  }

  Color _getWeatherColor(String? condition) {
    if (condition == null) return Colors.lightBlue;

    condition = condition.toLowerCase();
    if (condition.contains('sun') || condition.contains('clear')) {
      return Colors.orange;
    } else if (condition.contains('rain') || condition.contains('drizzle')) {
      return Colors.blueGrey;
    } else if (condition.contains('cloud')) {
      return Colors.lightBlue;
    } else if (condition.contains('snow') || condition.contains('sleet')) {
      return Colors.lightBlue.shade200;
    } else if (condition.contains('fog') || condition.contains('mist')) {
      return Colors.grey;
    } else if (condition.contains('thunder') || condition.contains('storm')) {
      return Colors.deepPurple;
    } else {
      return Colors.lightBlue;
    }
  }
}
