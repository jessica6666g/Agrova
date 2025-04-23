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
  String? _selectedLand;
  List<String> _selectedPlants = [];
  final List<Map<String, dynamic>> _availablePlants = [
    {'name': 'Tomato', 'icon': '🍅'},
    {'name': 'Corn', 'icon': '🌽'},
    {'name': 'Carrot', 'icon': '🥕'},
    {'name': 'Potato', 'icon': '🥔'},
    {'name': 'Broccoli', 'icon': '🥦'},
    {'name': 'Eggplant', 'icon': '🍆'},
  ];

  // Default dimensions for the field
  double _width = 4.0; // Default width in meters
  double _length = 3.0; // Default length in meters

  @override
  void initState() {
    super.initState();
    // Set initial selected land if available
    if (widget.lands.isNotEmpty) {
      final land = widget.lands[0];
      _selectedLand = "${land['name']} (${land['hectares']}ha)";

      // Set initial plants if the land has them saved
      if (land.containsKey('plants') && land['plants'] is List) {
        _selectedPlants = List<String>.from(land['plants']);
      }

      // Set dimensions if saved
      if (land.containsKey('yieldDimensions')) {
        _width = land['yieldDimensions']['width'] ?? 4.0;
        _length = land['yieldDimensions']['length'] ?? 3.0;
      } else {
        // Calculate default dimensions based on land size (hectares)
        // This is just a sample calculation - adjust as needed
        // 1 hectare = 10,000 m²
        if (land.containsKey('hectares')) {
          double hectares = land['hectares'] as double;
          // Create a small demonstration plot (not the entire hectare)
          _width = (hectares * 10) > 20 ? 20 : (hectares * 10);
          _length = (hectares * 8) > 16 ? 16 : (hectares * 8);
        }
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

  void _updateSelectedLand(String? landName) {
    if (landName == null) return;

    // Find the selected land data
    for (var land in widget.lands) {
      String landDisplayName = "${land['name']} (${land['hectares']}ha)";
      if (landDisplayName == landName) {
        setState(() {
          _selectedLand = landName;

          // Update plants if the land has them saved
          if (land.containsKey('plants') && land['plants'] is List) {
            _selectedPlants = List<String>.from(land['plants']);
          } else {
            _selectedPlants = [];
          }

          // Update dimensions if saved
          if (land.containsKey('yieldDimensions')) {
            _width = land['yieldDimensions']['width'] ?? 4.0;
            _length = land['yieldDimensions']['length'] ?? 3.0;
          } else {
            // Calculate default dimensions based on land size
            if (land.containsKey('hectares')) {
              double hectares = land['hectares'] as double;
              _width = (hectares * 10) > 20 ? 20 : (hectares * 10);
              _length = (hectares * 8) > 16 ? 16 : (hectares * 8);
            } else {
              _width = 4.0;
              _length = 3.0;
            }
          }
        });
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double area = _width * _length;

    final int minPlants = (area / 0.2 * 0.8).round();
    final int maxPlants = (area / 0.2).round();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Land selection dropdown
          const Text(
            'Select Land',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          _buildLandDropdown(),
          const SizedBox(height: 16),

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

          // Field information card
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Field Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00A651),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    'Dimensions:',
                    '${_width.toStringAsFixed(1)}m x ${_length.toStringAsFixed(1)}m',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow('Total Area:', '${area.toStringAsFixed(1)} m²'),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Planting Capacity:',
                    '~$minPlants-$maxPlants plants',
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 3D Visualization
          Center(
            child: SizedBox(
              width: double.infinity,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/soil_3d.png',
                      fit: BoxFit.contain,
                    ),
                  ),

                  // 3D label at bottom center
                  Positioned(
                    bottom: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Transform.rotate(
                            angle: 0.5, // Rotate slightly
                            child: const Icon(
                              Icons.refresh,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '3D',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Zoom controls
                  Positioned(
                    right: 10,
                    bottom: 50,
                    child: Column(
                      children: [
                        _buildZoomButton(Icons.add),
                        const SizedBox(height: 8),
                        _buildZoomButton(Icons.remove),
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

  Widget _buildLandDropdown() {
    final List<String> landOptions =
        widget.lands.isEmpty
            ? ['No lands available']
            : widget.lands
                .map((land) => "${land['name']} (${land['hectares']}ha)")
                .toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedLand,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        hint: const Text('Select a land'),
        isExpanded: true,
        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF00A651)),
        dropdownColor: Colors.white,
        items:
            landOptions.map((String land) {
              return DropdownMenuItem<String>(
                value: land == 'No lands available' ? null : land,
                enabled: land != 'No lands available',
                child: Text(
                  land,
                  style: TextStyle(
                    color:
                        land == 'No lands available'
                            ? Colors.grey
                            : Colors.black,
                  ),
                ),
              );
            }).toList(),
        onChanged: (String? newValue) {
          _updateSelectedLand(newValue);
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildZoomButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(icon, size: 20, color: Colors.black),
    );
  }
}
