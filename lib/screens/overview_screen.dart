import 'package:agrova/screens/login_page.dart';
import 'package:flutter/material.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 5;

  // Feature data for each page
  final List<Map<String, String>> _featureData = [
    {
      'title': 'Information\nHub',
      'description':
          'Stay ahead with real-time agricultural news, laws, technology updates and farming guides.',
      'imagePath': 'assets/images/information_hub.png',
    },
    {
      'title': 'Smart\nCalculator',
      'description':
          'Optimize your farm planning with precise fertilizer, cost and land mapping calculations.',
      'imagePath': 'assets/images/smart_calculator.png',
    },
    {
      'title': 'Market\nIntelligence',
      'description':
          'Keep track of live market prices and trending agricultural commodities.',
      'imagePath': 'assets/images/market_intelligence.png',
    },
    {
      'title': 'Entertainment\nHub',
      'description':
          'Connect and share through live streaming and short videos of farming activities.',
      'imagePath': 'assets/images/entertainment_hub.png',
    },
    {
      'title': 'Weather\nInsights',
      'description':
          'Plan your farming activities with accurate weather forecasts and agricultural meteorology.',
      'imagePath': 'assets/images/weather_insight.png',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFADF5E9),
      body: SafeArea(
        child: Column(
          children: [
            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _totalPages,
                physics: const AlwaysScrollableScrollPhysics(),
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  final data = _featureData[index];
                  return _buildFeatureCard(
                    title: data['title']!,
                    description: data['description']!,
                    imagePath: data['imagePath']!,
                    isLastPage: index == _totalPages - 1,
                  );
                },
              ),
            ),

            // Page indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildPageIndicator(),
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.only(
                bottom: 16.0,
                left: 24.0,
                right: 24.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous button
                  _currentPage > 0
                      ? IconButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.green,
                        ),
                      )
                      : const SizedBox(width: 48),

                  // Get Started button (shown only on the last page)
                  if (_currentPage == _totalPages - 1)
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Get Started",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Next button (not shown on last page)
                  _currentPage < _totalPages - 1
                      ? IconButton(
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        icon: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.green,
                        ),
                      )
                      : const SizedBox(width: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String description,
    required String imagePath,
    bool isLastPage = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 60),
          // Title Section
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 50,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  color: Color.fromARGB(255, 54, 194, 168),
                  blurRadius: 3,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Image Section with centered image
          Expanded(
            flex: 4,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    alignment: Alignment.center,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Description Text
          Expanded(
            flex: 2,
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                color: Color(0xFF2C6140),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageIndicator() {
    return List.generate(
      _totalPages,
      (i) => GestureDetector(
        onTap: () {
          _pageController.animateToPage(
            i,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
          );
        },
        child: Container(
          width: 8.0,
          height: 8.0,
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                _currentPage == i
                    ? Colors.green
                    : Colors.green.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}
