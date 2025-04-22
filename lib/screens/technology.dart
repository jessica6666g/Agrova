// screens/technology_page.dart
import 'package:agrova/models/agri_tech_model.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Add to pubspec.yaml

class TechnologyPage extends StatefulWidget {
  const TechnologyPage({super.key});

  @override
  State<TechnologyPage> createState() => _TechnologyPageState();
}

class _TechnologyPageState extends State<TechnologyPage> {
  bool _isLoading = false;
  final List<AgriTechnology> _technologies = _getMockTechnologies();
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Precision Farming',
    'Smart Irrigation',
    'Crop Monitoring',
    'Automation',
    'Data Analytics',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFADF5E9),
      appBar: AppBar(
        title: const Text(
          'Agricultural Technology',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF00A651),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildTechnologyList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF00A651) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      isSelected
                          ? const Color(0xFF00A651)
                          : Colors.grey.shade300,
                ),
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTechnologyList() {
    // Filter technologies based on selected category
    final filteredTechnologies =
        _selectedCategory == 'All'
            ? _technologies
            : _technologies
                .where((tech) => tech.category == _selectedCategory)
                .toList();

    return filteredTechnologies.isEmpty
        ? _buildEmptyState()
        : RefreshIndicator(
          onRefresh: _refreshTechnologies,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredTechnologies.length,
            itemBuilder: (context, index) {
              final technology = filteredTechnologies[index];
              return _buildTechnologyCard(technology);
            },
          ),
        );
  }

  Widget _buildTechnologyCard(AgriTechnology technology) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Technology image or placeholder
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF00A651).withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              image:
                  technology.imageUrl.isNotEmpty
                      ? DecorationImage(
                        image: AssetImage(technology.imageUrl),
                        fit: BoxFit.cover,
                      )
                      : null,
            ),
            child:
                technology.imageUrl.isEmpty
                    ? Center(
                      child: Icon(
                        Icons.devices,
                        size: 60,
                        color: const Color(0xFF00A651).withValues(alpha: 0.5),
                      ),
                    )
                    : null,
          ),

          // Category badge
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF00A651).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                technology.category,
                style: const TextStyle(
                  color: Color(0xFF00A651),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),

          // Technology name
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              technology.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          // Technology description
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              technology.description,
              style: const TextStyle(fontSize: 14, height: 1.4),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Technology details button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    _showTechnologyDetails(technology);
                  },
                  child: const Row(
                    children: [
                      Text(
                        'Learn More',
                        style: TextStyle(
                          color: Color(0xFF00A651),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: Color(0xFF00A651),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showTechnologyDetails(AgriTechnology technology) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder:
                (_, controller) => Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: ListView(
                    controller: controller,
                    padding: const EdgeInsets.all(24),
                    children: [
                      // Close button
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),

                      // Technology image
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00A651).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          image:
                              technology.imageUrl.isNotEmpty
                                  ? DecorationImage(
                                    image: AssetImage(technology.imageUrl),
                                    fit: BoxFit.cover,
                                  )
                                  : null,
                        ),
                        child:
                            technology.imageUrl.isEmpty
                                ? Center(
                                  child: Icon(
                                    Icons.devices,
                                    size: 80,
                                    color: const Color(
                                      0xFF00A651,
                                    ).withValues(alpha: 0.5),
                                  ),
                                )
                                : null,
                      ),

                      const SizedBox(height: 24),

                      // Technology name and category
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              technology.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF00A651,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              technology.category,
                              style: const TextStyle(
                                color: Color(0xFF00A651),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Technology description
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        technology.description,
                        style: const TextStyle(fontSize: 15, height: 1.5),
                      ),

                      const SizedBox(height: 24),

                      // Benefits
                      const Text(
                        'Key Benefits',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...technology.benefits.map(
                        (benefit) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFF00A651),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  benefit,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Learn more button
                      if (technology.sourceUrl.isNotEmpty)
                        ElevatedButton(
                          onPressed: () {
                            _launchUrl(technology.sourceUrl);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00A651),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Read More Online',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
          ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      // Show an error if URL cannot be launched
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open $urlString')));
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.devices_other, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Technologies Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'There are no agricultural technologies in this category. Try selecting a different category.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshTechnologies() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });
  }

  // Mock data generation
  static List<AgriTechnology> _getMockTechnologies() {
    return [
      AgriTechnology(
        id: '1',
        name: 'Precision Seeding with GPS Guidance',
        description:
            'GPS-guided precision seeding technology allows farmers to plant seeds with extreme accuracy, optimizing spacing, depth, and distribution. This technology reduces seed waste, improves germination rates, and creates ideal growing conditions for maximum yield potential.',
        category: 'Precision Farming',
        benefits: [
          'Reduces seed waste by up to 15%',
          'Improves crop emergence uniformity',
          'Optimizes plant spacing for better resource utilization',
          'Increases yield potential by creating ideal growing conditions',
          'Integrates with farm management software for data-driven decisions',
        ],
      ),
      AgriTechnology(
        id: '2',
        name: 'Smart Irrigation Controllers',
        description:
            'Smart irrigation systems use soil moisture sensors, weather forecasts, and evapotranspiration data to automatically adjust watering schedules. These controllers ensure crops receive precisely the right amount of water when needed, reducing waste while promoting healthy growth.',
        category: 'Smart Irrigation',
        benefits: [
          'Reduces water usage by 30-50% compared to traditional methods',
          'Prevents over-watering and under-watering issues',
          'Decreases energy costs associated with pumping water',
          'Minimizes nutrient leaching from excessive irrigation',
          'Remote monitoring and control via smartphone apps',
        ],
      ),
      AgriTechnology(
        id: '3',
        name: 'Drone-Based Crop Monitoring',
        description:
            'Agricultural drones equipped with multispectral and thermal cameras provide detailed aerial imagery of crops. Farmers can identify pest infestations, diseases, nutrient deficiencies, and irrigation issues before they become visible to the naked eye, allowing for early intervention.',
        category: 'Crop Monitoring',
        benefits: [
          'Early detection of crop stress, disease, and pest issues',
          'Creates detailed NDVI maps showing plant health across fields',
          'Reduces scouting time and labor costs',
          'Enables targeted application of inputs only where needed',
          'Provides time-series data to track crop development throughout the season',
        ],
      ),
      AgriTechnology(
        id: '4',
        name: 'Automated Harvesting Robots',
        description:
            'Robotic harvesting systems use computer vision and AI to identify ripe produce and gently harvest it. These robots can work around the clock, addressing labor shortages while minimizing damage to crops and reducing harvest losses.',
        category: 'Automation',
        benefits: [
          'Addresses agricultural labor shortages',
          'Reduces harvest losses through gentle handling',
          'Operates 24/7 regardless of weather or lighting conditions',
          'Increases harvesting speed and efficiency',
          'Collects valuable harvest data for yield analysis',
        ],
      ),
      AgriTechnology(
        id: '5',
        name: 'Predictive Crop Analytics Platform',
        description:
            'AI-powered analytics platforms combine historical farm data, real-time field conditions, and weather forecasts to predict crop yields and potential issues. These tools help farmers make proactive decisions about planting, fertilization, pest control, and harvesting timing.',
        category: 'Data Analytics',
        benefits: [
          'Predicts potential yield weeks before harvest',
          'Identifies optimal timing for field operations',
          'Provides early warning for disease and pest pressure',
          'Optimizes resource allocation based on yield potential',
          'Improves farm profitability through data-driven decision making',
        ],
      ),
    ];
  }
}
