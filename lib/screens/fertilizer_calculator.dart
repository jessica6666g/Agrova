import 'package:flutter/material.dart';

class FertilizerCalculatorPage extends StatefulWidget {
  final List<Map<String, dynamic>> lands;
  final Function(List<Map<String, dynamic>>) onLandsUpdated;

  const FertilizerCalculatorPage({
    super.key,
    required this.lands,
    required this.onLandsUpdated,
  });

  @override
  State<FertilizerCalculatorPage> createState() =>
      _FertilizerCalculatorPageState();
}

class _FertilizerCalculatorPageState extends State<FertilizerCalculatorPage> {
  // Selected land and fertilizer values
  String? _selectedLand;
  String _selectedFertilizer = "Nitrogen (N) (RM 1.25 /kg)";
  final TextEditingController _rateController = TextEditingController(
    text: "0",
  );

  // Calculation results
  double _totalAmount = 0.0;
  double _estimatedCost = 0.0;

  @override
  void initState() {
    super.initState();
    _rateController.addListener(_updateCalculation);

    // Set initial selected land if available
    if (widget.lands.isNotEmpty) {
      final land = widget.lands[0];
      _selectedLand = "${land['name']} (${land['hectares']}ha)";
      _updateCalculation();
    }
  }

  @override
  void dispose() {
    _rateController.dispose();
    super.dispose();
  }

  void _updateCalculation() {
    if (_rateController.text.isEmpty || _selectedLand == null) {
      setState(() {
        _totalAmount = 0.0;
        _estimatedCost = 0.0;
      });
      return;
    }

    try {
      final rate = double.parse(_rateController.text);
      // Extract hectares from the selected land
      final hectaresText = _selectedLand!.split('(')[1].split('ha)')[0];
      final hectares = double.parse(hectaresText);

      setState(() {
        _totalAmount = rate * hectares;
        // Get the fertilizer price from the selected fertilizer string
        double fertilizerPrice = 1.25; // Default
        if (_selectedFertilizer.contains("1.25")) {
          fertilizerPrice = 1.25;
        } else if (_selectedFertilizer.contains("1.50")) {
          fertilizerPrice = 1.50;
        } else if (_selectedFertilizer.contains("1.75")) {
          fertilizerPrice = 1.75;
        }
        _estimatedCost = _totalAmount * fertilizerPrice;
      });
    } catch (e) {
      print("Error in calculation: $e");
    }
  }

  // Save fertilizer calculation to the land data
  Future<void> _saveFertilizerCalculationToLand() async {
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

    // Update the land with fertilizer calculation data
    final updatedLands = List<Map<String, dynamic>>.from(widget.lands);

    updatedLands[landIndex] = {
      ...updatedLands[landIndex],
      'fertilizerRate': double.tryParse(_rateController.text) ?? 0,
      'fertilizerType': _selectedFertilizer,
      'lastFertilizerCalculation': {
        'date': DateTime.now().toIso8601String(),
        'totalAmount': _totalAmount,
        'cost': _estimatedCost,
      },
    };

    // Notify
    widget.onLandsUpdated(updatedLands);

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fertilizer calculation saved to schedule'),
        backgroundColor: Color(0xFF00A651),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check if the currently selected land is in the options
    final List<String> landOptions =
        widget.lands.isEmpty
            ? ['No lands available']
            : widget.lands
                .map((land) => "${land['name']} (${land['hectares']}ha)")
                .toList();

    if (_selectedLand != null && !landOptions.contains(_selectedLand)) {
      // Schedule a post-frame callback to update state
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _selectedLand = null;
        });
      });
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fertilizer Calculator',
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
            'Fertilizer Type',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          _buildDropdown(
            value: _selectedFertilizer,
            items: [
              "Nitrogen (N) (RM 1.25 /kg)",
              "Phosphorus (P) (RM 1.50 /kg)",
              "Potassium (K) (RM 1.75 /kg)",
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedFertilizer = value;
                  _updateCalculation();
                });
              }
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Application Rate (kg/ha)',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _rateController,
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
                      'Total Amount Required:',
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      '${_totalAmount.toStringAsFixed(2)} kg',
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
                      'RM ${_estimatedCost.toStringAsFixed(2)}',
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
                _selectedLand == null ? null : _saveFertilizerCalculationToLand,
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

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
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
        isExpanded: true,
        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF00A651)),
        dropdownColor: Colors.white,
        items:
            items.map((String item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
