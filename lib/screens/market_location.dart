import 'package:flutter/material.dart';

class MarketLocations extends StatefulWidget {
  const MarketLocations({Key? key}) : super(key: key);

  @override
  _MarketLocationsState createState() => _MarketLocationsState();
}

class _MarketLocationsState extends State<MarketLocations> with TickerProviderStateMixin {
  
  @override
  void initState() {
    super.initState();
  }
  

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Column(
      children: [

        // Main content section
        Expanded(
          child: Container(
            color: const Color(0xFFD1F5E4), // Light mint background
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Nearby Markets section
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFF00A651)),
                    const SizedBox(width: 8),
                    const Text(
                      'Nearby Markets',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Market cards
                _buildMarketCard(
                  'ÆEON Mall Ipoh Station 18',
                  '10:00 - 22:30',
                  2.5,
                  4.6,
                  'Weekend Treats',
                ),
                _buildMarketCard(
                  'Lotus\'s Ipoh Garden',
                  '08:00 - 22:00',
                  5.1,
                  4.6,
                  'LotussLebihMurah',
                ),
                _buildMarketCard(
                  'Econsave Angsana Ipoh Mall',
                  '9:30 - 22:00',
                  2.5,
                  4.6,
                  'Salam Ramandan',
                ),

                const SizedBox(height: 24),

                // Market Events Calendar header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Color(0xFF00A651)),
                        const SizedBox(width: 8),
                        const Text(
                          'Market Events Calendar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'View All',
                        style: TextStyle(
                          color: Color(0xFF00A651),
                        ),
                      ),
                    ),
                  ],
                ),

                // Events list
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Upcoming Events',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildEventItem('Weekend Farmers Market', 'Sat, 9:00-14:00'),
                      const SizedBox(height: 12),
                      _buildEventItem('Organic Produce Fair', 'Mar 15, 10:00'),
                      const SizedBox(height: 12),
                      _buildEventItem('Spring Produce Sale', 'Mar 20-25'),
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


  Widget _buildMarketCard(
    String name,
    String hours,
    double distance,
    double rating,
    String promotion,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Market name and distance
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: Colors.grey, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '$distance km',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          
          // Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              Text(
                ' $rating',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Hours
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.grey, size: 18),
              const SizedBox(width: 4),
              Text(
                'Hours: $hours',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Promotion tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              promotion,
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Direction and Price List
          Row(
            children: [
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.directions, color: Color(0xFF00A651)),
                label: const Text(
                  'Directions',
                  style: TextStyle(color: Color(0xFF00A651)),
                ),
              ),
              const SizedBox(width: 16),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.bar_chart, color: Color(0xFF00A651)),
                label: const Text(
                  'Price List',
                  style: TextStyle(color: Color(0xFF00A651)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventItem(String name, String time) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        Text(
          time,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}