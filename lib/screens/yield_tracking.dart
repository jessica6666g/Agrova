import 'package:flutter/material.dart';

class YieldTrackingPage extends StatefulWidget {
  final List<Map<String, dynamic>> lands;
  final Function(List<Map<String, dynamic>>) onLandsUpdated;

  const YieldTrackingPage({
    super.key,
    required this.lands,
    required this.onLandsUpdated,
  });

  @override
  State<YieldTrackingPage> createState() => _YieldTrackingPageState();
}

class _YieldTrackingPageState extends State<YieldTrackingPage> {
  List<String> _selectedPlants = [];
  final List<Map<String, dynamic>> _availablePlants = [
    {'name': 'Tomato', 'icon': '🍅'},
    {'name': 'Corn', 'icon': '🌽'},
    {'name': 'Carrot', 'icon': '🥕'},
    {'name': 'Potato', 'icon': '🥔'},
    {'name': 'Broccoli', 'icon': '🥦'},
    {'name': 'Eggplant', 'icon': '🍆'},
  ];

  @override
  void initState() {
    super.initState();
    // Set initial selected land if available
    if (widget.lands.isNotEmpty) {
      final land = widget.lands[0];

      // Set initial plants if the land has them saved
      if (land.containsKey('plants') && land['plants'] is List) {
        _selectedPlants = List<String>.from(land['plants']);
      }
    }
  }

  void _togglePlant(String plantName) {
    setState(() {
      if (_selectedPlants.contains(plantName)) {
        _selectedPlants.remove(plantName);
      } else {
        _selectedPlants.add(plantName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plants selection section
          const Text(
            'Plants:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _availablePlants.map((plant) {
                  final bool isSelected = _selectedPlants.contains(
                    plant['name'],
                  );
                  return InkWell(
                    onTap: () => _togglePlant(plant['name']),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? const Color(0xFF00A651).withValues(alpha: 0.1)
                                : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              isSelected
                                  ? const Color(0xFF00A651)
                                  : Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            plant['icon'],
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            plant['name'],
                            style: TextStyle(
                              color:
                                  isSelected
                                      ? const Color(0xFF00A651)
                                      : Colors.black,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          ),

          // Show selected plants as icons
          if (_selectedPlants.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 4,
              children:
                  _selectedPlants.map((plantName) {
                    // Find the icon for this plant
                    final plant = _availablePlants.firstWhere(
                      (p) => p['name'] == plantName,
                      orElse: () => {'name': plantName, 'icon': '❓'},
                    );

                    return Tooltip(
                      message: plantName,
                      child: Container(
                        margin: const EdgeInsets.only(right: 4),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          plant['icon'],
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
