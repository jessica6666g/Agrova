import 'package:agrova/screens/events.dart';
import 'package:agrova/screens/law.dart';
import 'package:agrova/screens/farm_management_page.dart';
import 'package:agrova/screens/profile_page.dart';
import 'package:agrova/screens/technology.dart';
import 'package:agrova/screens/weather_forecast.dart';
import 'package:agrova/screens/market_page.dart';
import 'package:flutter/material.dart';
import 'package:agrova/services/auth_service.dart';
import 'package:agrova/screens/all_news_page.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

// Weather API service
class WeatherApiService {
  final String apiKey;
  WeatherApiService(this.apiKey);

  Future<Map<String, dynamic>?> getWeatherForCity(String city) async {
    final url =
        'http://api.weatherapi.com/v1/current.json?key=$apiKey&q=${Uri.encodeComponent(city)}&aqi=no';
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      return json.decode(res.body);
    }
    return null;
  }
}

class NewsApiService {
  static const String apiKey = '4270652047e646ac942a91145be9128d';

  Future<List<dynamic>> getAgricultureNews() async {
    try {
      // Get current date and a date from 30 days ago
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));

      // Format dates to YYYY-MM-DD
      final fromDate =
          '${thirtyDaysAgo.year}-${_twoDigits(thirtyDaysAgo.month)}-${_twoDigits(thirtyDaysAgo.day)}';
      final toDate =
          '${now.year}-${_twoDigits(now.month)}-${_twoDigits(now.day)}';

      // Build the URL with date parameters
      final url =
          'https://newsapi.org/v2/everything'
          '?q=agriculture+farming'
          '&from=$fromDate'
          '&to=$toDate'
          '&sortBy=publishedAt'
          '&language=en'
          '&apiKey=$apiKey';

      debugPrint('Fetching news from: $url');

      final response = await http.get(Uri.parse(url));
      debugPrint('News API response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final articles = jsonData['articles'] ?? [];
        debugPrint('Found ${articles.length} articles');

        // Sort articles by publishedAt in descending order (newest first)
        if (articles.isNotEmpty) {
          articles.sort((a, b) {
            final aDate =
                DateTime.tryParse(a['publishedAt'] ?? '') ?? DateTime(1900);
            final bDate =
                DateTime.tryParse(b['publishedAt'] ?? '') ?? DateTime(1900);
            return bDate.compareTo(aDate); // Descending order
          });
        }

        return articles;
      } else {
        debugPrint('Failed to load news: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching news: $e');
      return [];
    }
  }

  String _twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }
}

class HomePage extends StatefulWidget {
  final int? initialTab;

  const HomePage({super.key, this.initialTab});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 2;
  String _username = "User";
  final AuthService _authService = AuthService();
  final NewsApiService _newsApiService = NewsApiService();

  // Weather state
  Map<String, dynamic>? _weatherJson;
  bool _loadingWeather = true;
  String cityName = 'Kampar';
  final String weatherApiKey = 'e52accb5c96a4540b04103859252204';

  List<dynamic> _newsList = [];
  bool _loadingNews = true;

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _fetchWeather();
    _fetchNews();
  }

  Future<void> _loadUsername() async {
    try {
      final user = _authService.currentUser;
      if (user != null &&
          user.displayName != null &&
          user.displayName!.isNotEmpty) {
        setState(() {
          _username = user.displayName!;
        });
      } else {
        final email = await _authService.getUserEmail();
        if (email != null) {
          setState(() {
            _username = email.split('@')[0];
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading username: $e');
    }
  }

  Future<void> _fetchWeather() async {
    setState(() => _loadingWeather = true);
    try {
      final service = WeatherApiService(weatherApiKey);
      final weather = await service.getWeatherForCity(cityName);
      setState(() {
        _weatherJson = weather;
        _loadingWeather = false;
      });
    } catch (e) {
      setState(() => _loadingWeather = false);
      debugPrint('WeatherAPI error: $e');
    }
  }

  Future<void> _fetchNews() async {
    setState(() => _loadingNews = true);
    try {
      debugPrint('Starting news fetch');
      final newsList = await _newsApiService.getAgricultureNews();

      setState(() {
        _newsList = newsList;
        _loadingNews = false;
      });

      if (newsList.isEmpty) {
        debugPrint('News list is empty after fetch');
      } else {
        debugPrint('Successfully fetched ${newsList.length} news items');
      }
    } catch (e) {
      setState(() => _loadingNews = false);
      debugPrint('Error in _fetchNews: $e');
    }
  }

  Future<void> _refreshData() async {
    await Future.wait([_fetchWeather(), _fetchNews()]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFADF5E9),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildCategoriesSection(),
                const SizedBox(height: 16),
                _buildAgriNewsSection(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeader() {
    final temp = _weatherJson?['current']?['temp_c'];
    final humidity = _weatherJson?['current']?['humidity'];
    final cond = _weatherJson?['current']?['condition']?['text'];
    final chancesOfRain = _weatherJson?['current']?['precip_mm'] ?? 0.0;
    final rainChance =
        chancesOfRain > 0 ? '${(chancesOfRain * 25).round()}%' : '0%';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF00A651),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good ${_getTimeOfDay()}\n$_username',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              if (!_loadingWeather && _weatherJson != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => WeatherForecastScreen(
                          cityName: cityName,
                          apiKey: weatherApiKey,
                          currentWeather: _weatherJson,
                        ),
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child:
                  _loadingWeather
                      ? const SizedBox(
                        height: 60,
                        child: Center(child: CircularProgressIndicator()),
                      )
                      : Column(
                        children: [
                          // Main weather data row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Icon + City + Temp
                              Row(
                                children: [
                                  // Weather icon based on condition
                                  Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      color: _getWeatherColor(cond),
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        _getWeatherIcon(cond),
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _weatherJson?['location']?['name'] ??
                                            cityName,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            temp != null
                                                ? '${temp.toInt()}'
                                                : '-',
                                            style: const TextStyle(
                                              fontSize: 36,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Text(
                                            '°C',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              // Humidity and Rain chances
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'Chance of rain',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        rainChance,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Text(
                                        'Humidity',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        humidity != null ? '$humidity%' : '-',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // Add tap indicator
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.expand_more,
                                  size: 20,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Tap for detailed forecast',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
            ),
          ),
        ],
      ),
    );
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
    if (condition == null) return Colors.lightBlue.withValues(alpha: 0.3);

    condition = condition.toLowerCase();
    if (condition.contains('sun') || condition.contains('clear')) {
      return Colors.orange.withValues(alpha: 0.7);
    } else if (condition.contains('rain') || condition.contains('drizzle')) {
      return Colors.blueGrey.withValues(alpha: 0.7);
    } else if (condition.contains('cloud')) {
      return Colors.lightBlue.withValues(alpha: 0.5);
    } else if (condition.contains('snow') || condition.contains('sleet')) {
      return Colors.lightBlue.withValues(alpha: 0.3);
    } else if (condition.contains('fog') || condition.contains('mist')) {
      return Colors.grey.withValues(alpha: 0.5);
    } else if (condition.contains('thunder') || condition.contains('storm')) {
      return Colors.deepPurple.withValues(alpha: 0.7);
    } else {
      return Colors.lightBlue.withValues(alpha: 0.3);
    }
  }

  Widget _buildCategoriesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Events category
          Expanded(
            child: _buildEventCard(
              onTap: () {
                // Navigate to Events page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EventsPage()),
                );
              },
            ),
          ),

          const SizedBox(width: 16),

          // Technology and Laws categories stacked
          Expanded(
            child: Column(
              children: [
                _buildTechnologyCard(
                  onTap: () {
                    // Navigate to Technology page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TechnologyPage(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                _buildLawsCard(
                  onTap: () {
                    // Navigate to Laws page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LawsPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard({required VoidCallback onTap}) {
    return _buildCategoryCardBase(
      title: 'Events',
      color: Colors.green,
      onTap: onTap,
      height: 246,
      imageBuilder:
          () => Image.asset(
            'assets/images/event.png',
            fit: BoxFit.contain,
            scale: 6.5,
          ),
    );
  }

  Widget _buildTechnologyCard({required VoidCallback onTap}) {
    return _buildCategoryCardBase(
      title: 'Technology',
      color: Colors.green,
      rightAlign: true,
      onTap: onTap,
      height: 115,
      imageBuilder:
          () => Image.asset(
            'assets/images/technology.png',
            fit: BoxFit.contain,
            scale: 3.5,
          ),
    );
  }

  Widget _buildLawsCard({required VoidCallback onTap}) {
    return _buildCategoryCardBase(
      title: 'Laws',
      color: Colors.green,
      rightAlign: true,
      onTap: onTap,
      height: 115,
      imageBuilder:
          () => Image.asset(
            'assets/images/law.png',
            fit: BoxFit.contain,
            scale: 3.5,
          ),
    );
  }

  Widget _buildCategoryCardBase({
    required String title,
    required Color color,
    bool rightAlign = false,
    required VoidCallback onTap,
    required double height,
    required Widget Function() imageBuilder,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (rightAlign)
                  const Text(
                    '›',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: OverflowBox(
                  maxWidth: double.infinity,
                  maxHeight: double.infinity,
                  child: Center(child: imageBuilder()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Agri News section
  Widget _buildAgriNewsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Agriculture News',
                style: TextStyle(
                  color: Color(0xFF00A651),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  // Loading
                  if (_loadingNews)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF00A651),
                        ),
                      ),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Color(0xFF00A651)),
                      onPressed: _fetchNews,
                      tooltip: 'Refresh news',
                    ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          _loadingNews && _newsList.isEmpty
              ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              )
              : _newsList.isEmpty
              ? _buildEmptyNewsState()
              : Column(
                children: [
                  // Show only first 8 news
                  ...(_newsList.length > 8
                          ? _newsList.sublist(0, 8)
                          : _newsList)
                      .map((news) {
                        String sourceName = '';
                        if (news['source'] != null &&
                            news['source']['name'] != null) {
                          sourceName = news['source']['name'];
                        }

                        return Column(
                          children: [
                            _buildNewsItemFromAPI(
                              title: news['title'] ?? 'No title available',
                              description:
                                  news['description'] ??
                                  'No description available',
                              url: news['url'] ?? '',
                              publishedAt: news['publishedAt'] ?? '',
                              sourceName: sourceName,
                            ),
                            const Divider(height: 16),
                          ],
                        );
                      }),

                  // See More button
                  if (_newsList.length > 8)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => AllNewsPage(newsList: _newsList),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF00A651,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'See More News',
                                style: TextStyle(
                                  color: Color(0xFF00A651),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward,
                                color: Color(0xFF00A651),
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
        ],
      ),
    );
  }

  Future<void> _launchNewsUrl(String url) async {
    try {
      debugPrint('Attempting to launch URL: $url');

      // Handle empty URL
      if (url.isEmpty) {
        _showNewsDetailDialog('No URL available for this article');
        return;
      }

      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }

      await launchUrl(Uri.parse(url), mode: LaunchMode.platformDefault);
    } catch (e) {
      // Add a copy button to let users copy the URL manually
      _showNewsDetailDialogWithCopy(url, e.toString());
    }
  }

  void _showNewsDetailDialogWithCopy(String url, String errorMessage) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Could not open article'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Text('You can copy the URL and open it manually:'),
                const SizedBox(height: 8),
                Text(url, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: url));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('URL copied to clipboard')),
                  );
                  Navigator.of(context).pop();
                },
                child: const Text('COPY URL'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('CLOSE'),
              ),
            ],
          ),
    );
  }

  // Show dialog with article details when launch fails
  void _showNewsDetailDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Article Information'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(message),
                  const SizedBox(height: 12),
                  const Text(
                    'Device Info:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Flutter version: ${WidgetsBinding.instance.runtimeType}',
                  ),
                  Text('Platform: ${Theme.of(context).platform}'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _openInAppWebView(String url) {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              appBar: AppBar(
                title: const Text('Article'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: url));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('URL copied to clipboard'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
      ),
    );
  }

  // Empty state when no news is available
  Widget _buildEmptyNewsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30.0),
        child: Column(
          children: [
            Icon(Icons.article_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No agriculture news available',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _fetchNews,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsItemFromAPI({
    required String title,
    required String description,
    required String url,
    required String publishedAt,
    String sourceName = '',
  }) {
    // Get image URL from the news item
    String? imageUrl;
    for (final news in _newsList) {
      if (news['title'] == title) {
        imageUrl = news['urlToImage'];
        break;
      }
    }

    String timeAgo = '';

    if (publishedAt.isNotEmpty) {
      try {
        final date = DateTime.parse(publishedAt);
        final now = DateTime.now();
        final difference = now.difference(date);

        // Show time ago
        if (difference.inDays > 0) {
          timeAgo = '${difference.inDays}d ago';
        } else if (difference.inHours > 0) {
          timeAgo = '${difference.inHours}h ago';
        } else if (difference.inMinutes > 0) {
          timeAgo = '${difference.inMinutes}m ago';
        } else {
          timeAgo = 'Just now';
        }
        // ignore: empty_catches
      } catch (e) {}
    }

    return InkWell(
      onTap: () {
        if (url.isNotEmpty) {
          _launchNewsUrl(url).catchError((_) => _openInAppWebView(url));
        } else {
          _showNewsDetailDialog('$title\n\n$description');
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child:
                  imageUrl != null && imageUrl.isNotEmpty
                      ? Image.network(
                        imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.white70,
                              ),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },
                      )
                      : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.white70,
                          ),
                        ),
                      ),
            ),

            const SizedBox(width: 12),

            // News content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Description
                  Text(
                    description,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Time ago, source and date
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // Time ago with highlighted color
                      if (timeAgo.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF00A651,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            timeAgo,
                            style: const TextStyle(
                              color: Color(0xFF00A651),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                      if (timeAgo.isNotEmpty && sourceName.isNotEmpty)
                        const SizedBox(width: 6),

                      // Source
                      if (sourceName.isNotEmpty)
                        Expanded(
                          child: Text(
                            sourceName,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Bottom navigation bar
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        if (index == 0) {
          // Market tab (first item)
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MarketPage()),
          );
        } else if (index == 4) {
          // Profile tab
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ProfilePage(
                    username: _username,
                    location: _weatherJson?['location']?['name'] ?? 'Kampar',
                    joinDate:
                        "Joined since ${DateFormat('MMM').format(DateTime.now())} 2025",
                    email:
                        _authService.currentUser?.email ??
                        "your.email@gmail.com",
                  ),
            ),
          );
        } else {
          setState(() {
            _selectedIndex = index;
          });
          // Handle other tabs if needed
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FarmManagementPage(),
              ),
            );
          } else if (index == 2) {
            // Home tab
            // You can add navigation to Home page here if needed
          } else if (index == 3) {
            // Video tab
            // You can add navigation to Video page here if needed
          }
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Market'),
        BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Manage'),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.play_circle_outline),
          label: 'Video',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }

  // Time of day for greeting
  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Morning';
    } else if (hour < 17) {
      return 'Afternoon';
    } else {
      return 'Evening';
    }
  }
}
