import 'package:flutter/material.dart';

class WaterCalculatorPage extends StatefulWidget {
  final List<Map<String, dynamic>> lands;
  final Function(List<Map<String, dynamic>>) onLandsUpdated;

  const WaterCalculatorPage({
    super.key,
    required this.lands,
    required this.onLandsUpdated,
  });

  @override
  State<WaterCalculatorPage> createState() => _WaterCalculatorPageState();
}

class _WaterCalculatorPageState extends State<WaterCalculatorPage> {
  // Selected land and water values
  String? _selectedLand;
  final TextEditingController _waterVolumeController = TextEditingController(
    text: "0.0",
  );
  final TextEditingController _waterRateController = TextEditingController(
    text: "0",
  );

  // Calculation results
  double _totalWaterVolume = 0.0;
  double _estimatedWaterCost = 0.0;

  @override
  void initState() {
    super.initState();
    _waterVolumeController.addListener(_updateCalculation);
    _waterRateController.addListener(_updateCalculation);

    // Set initial selected land if available
    if (widget.lands.isNotEmpty) {
      final land = widget.lands[0];
      _selectedLand = "${land['name']} (${land['hectares']}ha)";
      _updateCalculation();
    }
  }

  @override
  void dispose() {
    _waterVolumeController.dispose();
    _waterRateController.dispose();
    super.dispose();
  }

  // Save water calculation to the land data
  Future<void> _saveWaterCalculationToLand() async {
    if (_selectedLand == null) return;

    // Find the selected land
    final landName = _selectedLand!.split(' (')[0];
    int landIndex = -1;

    for (int i = 0; i < widget.lands.length; i++) {
      if (widget.lands[i]['name'] == landName) {
        landIndex = i;
        break;
      }
    }

    if (landIndex == -1) return;

    // Update the land with water calculation data
    final updatedLands = List<Map<String, dynamic>>.from(widget.lands);

    updatedLands[landIndex] = {
      ...updatedLands[landIndex],
      'waterRate': double.tryParse(_waterRateController.text) ?? 0,
      'waterVolume': double.tryParse(_waterVolumeController.text) ?? 0,
      'lastWaterCalculation': {
        'date': DateTime.now().toIso8601String(),
        'totalVolume': _totalWaterVolume,
        'cost': _estimatedWaterCost,
      },
    };

    // Notify
    widget.onLandsUpdated(updatedLands);

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Water calculation saved to schedule'),
        backgroundColor: Color(0xFF00A651),
      ),
    );
  }

  void _updateCalculation() {
    if (_waterRateController.text.isEmpty ||
        _waterVolumeController.text.isEmpty ||
        _selectedLand == null) {
      setState(() {
        _totalWaterVolume = 0.0;
        _estimatedWaterCost = 0.0;
      });
      return;
    }

    try {
      final rate = double.parse(_waterRateController.text);
      final pricePerLiter = double.parse(_waterVolumeController.text);

      // Extract hectares from the selected land
      final hectaresText = _selectedLand!.split('(')[1].split('ha)')[0];
      final hectares = double.parse(hectaresText);

      setState(() {
        _totalWaterVolume = rate * hectares;
        _estimatedWaterCost = _totalWaterVolume * pricePerLiter;
      });
    } catch (e) {
      // Handle parsing errors
      print("Error in water calculation: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Water Calculator',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Select Land',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          _buildLandDropdown(),
          const SizedBox(height: 16),
          const Text(
            'Water Volume',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _waterVolumeController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
              prefixText: 'RM',
              suffixText: '/litres',
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Application Rate (Litres/ha)',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _waterRateController,
            keyboardType: TextInputType.number,
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
          ),
          const SizedBox(height: 24),
          const Text(
            'Calculation Results',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Volume Required:',
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      '${_totalWaterVolume.toStringAsFixed(0)} litres',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Estimated Cost:',
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      'RM ${_estimatedWaterCost.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF00A651),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text(
              'Save To Schedule',
              style: TextStyle(fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00A651),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed:
                _selectedLand == null ? null : _saveWaterCalculationToLand,
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
          setState(() {
            _selectedLand = newValue;
            _updateCalculation();
          });
        },
      ),
    );
  }
}
