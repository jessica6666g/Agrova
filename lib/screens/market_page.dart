import 'package:agrova/screens/home_page.dart';
import 'package:flutter/material.dart';
import '../models/market_model.dart';
import '../services/market_service.dart';
import 'market_location.dart';
import 'market_price_trends.dart';

class MarketPage extends StatefulWidget {
  const MarketPage({Key? key}) : super(key: key);

  @override
  _MarketPageState createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage>
    with SingleTickerProviderStateMixin {
  final int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final MarketService _marketService = MarketService();
  late Future<Market> _marketData;
  List<Vegetable> _filteredVegetables = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _marketData = _marketService.getMarketData();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Market Prices',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF00A651),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _marketData = _marketService.getMarketData();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          (_tabController.index != 2)
              ? Container(
                  color: const Color(0xFF00A651),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Column(
                    children: [
                      // Search field for vegetables
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 8.0),
                            const Icon(Icons.search, color: Colors.grey),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: const InputDecoration(
                                  hintText: 'Search vegetable...',
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(color: Colors.grey),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _marketData.then((market) {
                                      _filteredVegetables = market.vegetables
                                          .where((veg) => veg.name
                                              .toLowerCase()
                                              .contains(value.toLowerCase()))
                                          .toList();
                                    });
                                  });
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.filter_list,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                // Filter functionality
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      // Location button
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MarketLocations(),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.white),
                            SizedBox(width: 4.0),
                            Expanded(
                              child: Text(
                                'Cameron Highland Market',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  color: const Color(0xFF00A651),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 8.0),
                        const Icon(Icons.search, color: Colors.grey),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: TextField(
                            // controller: _marketSearchController,
                            decoration: const InputDecoration(
                              hintText: 'Search market...',
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.filter_list,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            // Optional: add market filter logic
                          },
                        ),
                      ],
                    ),
                  ),
                ),
          // Tab bar
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF00A651),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF00A651),
              tabs: const [
                Tab(text: 'Current Prices'),
                Tab(text: 'Price Trends'),
                Tab(text: 'Market'),
              ],
            ),
          ),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCurrentPricesTab(),
                const MarketPriceTrends(),
                const MarketLocations(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildCurrentPricesTab() {
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

        final market = snapshot.data!;
        final vegetables =
            _searchController.text.isEmpty
                ? market.vegetables
                : _filteredVegetables;

        return Column(
          children: [
            // Last updated text
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Last updated: ${_formatDateTime(market.lastUpdated)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ),

            // Vegetable grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: vegetables.length,
                itemBuilder: (context, index) {
                  final vegetable = vegetables[index];
                  return _buildVegetableCard(vegetable);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildVegetableCard(Vegetable vegetable) {
    final isIncrease = vegetable.priceChange >= 0;
    final changeText =
        isIncrease
            ? '+RM${vegetable.priceChange.toStringAsFixed(2)}/KG'
            : '-RM${vegetable.priceChange.abs().toStringAsFixed(2)}/KG';
    final changeIcon =
        isIncrease
            ? const Icon(Icons.arrow_upward, color: Colors.red, size: 16)
            : const Icon(Icons.arrow_downward, color: Colors.green, size: 16);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.0),
                    child: Image.asset(
                      'assets/vegetables/${vegetable.name.toLowerCase().replaceAll(' ', '_')}.png',
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
                const SizedBox(width: 8.0),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          vegetable.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      changeIcon,
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'RM${vegetable.price.toStringAsFixed(2)}/KG',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4.0),
                Text(
                  changeText,
                  style: TextStyle(
                    color: isIncrease ? Colors.red : Colors.green,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${dateTime.minute.toString().padLeft(2, '0')} $period ${dateTime.month}/${dateTime.day}/${dateTime.year}';
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == _selectedIndex) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(initialTab: index),
            ),
          );
        },
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF00A651),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Market',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Manage',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_outline),
            label: 'Video',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
