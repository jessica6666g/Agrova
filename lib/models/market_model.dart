
class Market {
  final List<Vegetable> vegetables;
  final DateTime lastUpdated;
  final List<MarketLocation> locations;
  final List<MarketEvent> events;

  Market({
    required this.vegetables,
    required this.lastUpdated,
    required this.locations,
    required this.events,
  });
}

class Vegetable {
  final String name;
  final double price;
  final double priceChange;
  final List<PriceHistory> priceHistory;
  final bool isBookmarked;

  Vegetable({
    required this.name,
    required this.price,
    required this.priceChange,
    required this.priceHistory,
    this.isBookmarked = false,
  });
}

class PriceHistory {
  final DateTime date;
  final double price;

  PriceHistory({
    required this.date,
    required this.price,
  });
}

class MarketLocation {
  final String name;
  final String address;
  final String hours;
  final double distance;
  final double rating;
  final String? promotion;

  MarketLocation({
    required this.name,
    required this.address,
    required this.hours,
    required this.distance,
    required this.rating,
    this.promotion,
  });
}

class MarketEvent {
  final String name;
  final String time;
  final DateTime date;
  final String? location;

  MarketEvent({
    required this.name,
    required this.time,
    required this.date,
    this.location,
  });
}