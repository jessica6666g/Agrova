import 'package:flutter/material.dart';
import '../models/market_model.dart';
import '../services/market_service.dart';

class MarketPriceTrends extends StatefulWidget {
  const MarketPriceTrends({Key? key}) : super(key: key);

  @override
  _MarketPriceTrendsState createState() => _MarketPriceTrendsState();
}

class _MarketPriceTrendsState extends State<MarketPriceTrends> {
  final MarketService _marketService = MarketService();
  late Future<Market> _marketData;
  String _selectedTimeFrame = 'This week';
  final List<String> _timeFrames = [
    'Today',
    'This week',
    'This month',
    '3 months',
  ];

  @override
  void initState() {
    super.initState();
    _marketData = _marketService.getMarketData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Market>(
      future: _marketData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('No market data available'));
        }

        // ignore: unused_local_variable
        final market = snapshot.data!;

        return Container(
          color: const Color(0xFFD1F5E4),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.trending_up, color: Color(0xFF00A651)),
                      const SizedBox(width: 8),
                      const Text(
                        'Price Trend Analysis',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedTimeFrame,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            items:
                                _timeFrames.map((String item) {
                                  return DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(item),
                                  );
                                }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedTimeFrame = newValue;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Chart Container
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Price Trends Visualization',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF00A651),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 150,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildBarChart(70, 150),
                            const SizedBox(width: 30),
                            _buildBarChart(130, 150),
                            const SizedBox(width: 30),
                            _buildBarChart(90, 150),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00A651),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text(
                          'Overall prices increased by 3.2% this month',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Last updated: Today, 10:30 AM',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ),

                // Vegetable List (inside ListView.builder with shrinkWrap)
                ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildVegetableItem(
                      'Tomatoes',
                      'assets/vegetables/tomatoes.png',
                      8.50,
                      8.90,
                      true,
                    ),
                    _buildVegetableItem(
                      'Potatoes',
                      'assets/vegetables/potatoes.png',
                      6.40,
                      6.20,
                      false,
                    ),
                    _buildVegetableItem(
                      'Onions',
                      'assets/vegetables/onions.png',
                      2.30,
                      2.90,
                      true,
                    ),
                    _buildVegetableItem(
                      'Carrots',
                      'assets/vegetables/carrots.png',
                      4.99,
                      4.99,
                      null,
                    ),
                    _buildVegetableItem(
                      'Cabbage',
                      'assets/vegetables/cabbage.png',
                      3.98,
                      3.48,
                      false,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBarChart(double height, double maxHeight) {
    return Container(
      width: 30,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF7DDEB1),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _buildVegetableItem(
    String name,
    String imagePath,
    double oldPrice,
    double newPrice,
    bool? isIncrease,
  ) {
    // isIncrease: true = price increased, false = price decreased, null = no change
    Color arrowColor =
        isIncrease == true
            ? Colors.red
            : isIncrease == false
            ? Colors.green
            : Colors.grey;

    IconData arrowIcon =
        isIncrease == true
            ? Icons.arrow_upward
            : isIncrease == false
            ? Icons.arrow_downward
            : Icons.remove;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          children: [
            // Vegetable image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Vegetable info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(arrowIcon, color: arrowColor, size: 20),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'RM ${oldPrice.toStringAsFixed(2)} /kg → RM ${newPrice.toStringAsFixed(2)} /kg',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),

            // Bookmark icon
            const SizedBox(width: 8),
            Icon(Icons.bookmark_border, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
