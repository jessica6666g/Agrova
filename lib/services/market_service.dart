import '../models/market_model.dart';

class MarketService {
  Future<Market> getMarketData() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Create sample data
    final now = DateTime.now();
    
    // Sample vegetables with price history
    final List<Vegetable> vegetables = [
      Vegetable(
        name: 'Tomatoes',
        price: 8.90,
        priceChange: 0.40,
        priceHistory: _generatePriceHistory(8.50, 15),
      ),
      Vegetable(
        name: 'Potatoes',
        price: 6.20,
        priceChange: -0.20,
        priceHistory: _generatePriceHistory(6.40, 15),
      ),
      Vegetable(
        name: 'Onions',
        price: 2.90,
        priceChange: 0.60,
        priceHistory: _generatePriceHistory(2.30, 15),
      ),
      Vegetable(
        name: 'Carrots',
        price: 4.99,
        priceChange: 0.00,
        priceHistory: _generatePriceHistory(4.99, 15),
      ),
      Vegetable(
        name: 'Cabbage',
        price: 3.48,
        priceChange: -0.50,
        priceHistory: _generatePriceHistory(3.98, 15),
      ),
      Vegetable(
        name: 'Bell Peppers',
        price: 12.90,
        priceChange: 1.20,
        priceHistory: _generatePriceHistory(11.70, 15),
      ),
      Vegetable(
        name: 'Broccoli',
        price: 9.40,
        priceChange: -0.30,
        priceHistory: _generatePriceHistory(9.70, 15),
      ),
      Vegetable(
        name: 'Cucumber',
        price: 4.20,
        priceChange: 0.10,
        priceHistory: _generatePriceHistory(4.10, 15),
      ),
    ];

    // Sample market locations
    final List<MarketLocation> locations = [
      MarketLocation(
        name: 'ÆEON Mall Ipoh Station 18',
        address: 'Station 18, Ipoh',
        hours: '10:00 - 22:30',
        distance: 2.5,
        rating: 4.6,
        promotion: 'Weekend Treats',
      ),
      MarketLocation(
        name: 'Lotus\'s Ipoh Garden',
        address: 'Ipoh Garden, Ipoh',
        hours: '08:00 - 22:00',
        distance: 5.1,
        rating: 4.6,
        promotion: 'LotussLebihMurah',
      ),
      MarketLocation(
        name: 'Econsave Angsana Ipoh Mall',
        address: 'Angsana Mall, Ipoh',
        hours: '9:30 - 22:00',
        distance: 2.5,
        rating: 4.6,
        promotion: 'Salam Ramandan',
      ),
    ];

    // Sample market events
    final List<MarketEvent> events = [
      MarketEvent(
        name: 'Weekend Farmers Market',
        time: '9:00-14:00',
        date: DateTime(now.year, now.month, now.day + (6 - now.weekday)),
        location: 'Central City Park',
      ),
      MarketEvent(
        name: 'Organic Produce Fair',
        time: '10:00',
        date: DateTime(now.year, 3, 15),
        location: 'Community Center',
      ),
      MarketEvent(
        name: 'Spring Produce Sale',
        time: 'All Day',
        date: DateTime(now.year, 3, 20),
        location: 'Various Locations',
      ),
    ];

    return Market(
      vegetables: vegetables,
      lastUpdated: now,
      locations: locations,
      events: events,
    );
  }

  List<PriceHistory> _generatePriceHistory(double startPrice, int days) {
    final now = DateTime.now();
    final List<PriceHistory> history = [];
    
    double currentPrice = startPrice;
    for (int i = days; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      
      // Small random price fluctuation
      final change = (i == 0) ? 0.0 : (0.5 - (i % 3 == 0 ? 0.3 : 0.2)) * (i % 2 == 0 ? 1 : -1);
      currentPrice += change;
      if (currentPrice < 0) currentPrice = 0.1; // Prevent negative prices
      
      history.add(PriceHistory(
        date: date,
        price: double.parse(currentPrice.toStringAsFixed(2)),
      ));
    }
    
    return history;
  }
}