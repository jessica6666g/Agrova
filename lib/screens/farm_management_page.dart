import 'package:agrova/screens/fertilizer_calculator.dart';
import 'package:agrova/screens/home_page.dart';
import 'package:agrova/screens/market_page.dart';
import 'package:agrova/screens/profile_page.dart';
import 'package:agrova/screens/water_calculator.dart';
import 'package:agrova/screens/yield_tracking.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FarmManagementPage extends StatefulWidget {
  const FarmManagementPage({super.key});

  @override
  State<FarmManagementPage> createState() => _FarmManagementPageState();
}

class _FarmManagementPageState extends State<FarmManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final int _selectedIndex = 1;

  // Lands list
  List<Map<String, dynamic>> _lands = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _loadLands();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Load saved lands
  Future<void> _loadLands() async {
    final prefs = await SharedPreferences.getInstance();
    final String? landsJson = prefs.getString('lands');

    if (landsJson != null) {
      setState(() {
        final List<dynamic> decoded = jsonDecode(landsJson);
        _lands =
            decoded.map((item) => Map<String, dynamic>.from(item)).toList();
      });
    }
  }

  // Save lands to SharedPreferences
  Future<void> _saveLands() async {
    final prefs = await SharedPreferences.getInstance();

    // Convert the List of Maps to a JSON string
    final String landsJson = jsonEncode(_lands);

    // Save to SharedPreferences
    await prefs.setString('lands', landsJson);
  }

  // Update lands data from child components
  void _updateLands(List<Map<String, dynamic>> updatedLands) {
    setState(() {
      _lands = updatedLands;
    });
    _saveLands();
  }

  void _addNewLand() {
    String name = '';
    String sizeText = '';
    String crop = '';
    String soil = '';

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Add New Land'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Land Name',
                    hintText: 'e.g., North Field',
                  ),
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  onChanged: (value) {
                    name = value;
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Size (hectares)',
                    hintText: 'e.g., 2.5',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    sizeText = value;
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Crop Type',
                    hintText: 'e.g., Corn',
                  ),
                  textCapitalization: TextCapitalization.words,
                  onChanged: (value) {
                    crop = value;
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Soil Type',
                    hintText: 'e.g., Loamy',
                  ),
                  textCapitalization: TextCapitalization.words,
                  onChanged: (value) {
                    soil = value;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A651),
              ),
              onPressed: () {
                // Process values
                final landName =
                    name.isNotEmpty ? name : 'New Land ${_lands.length + 1}';
                final hectares = double.tryParse(sizeText) ?? 2.5;
                final cropType = crop.isNotEmpty ? crop : 'Not set';
                final soilType = soil.isNotEmpty ? soil : 'Not set';

                // Close dialog
                Navigator.of(dialogContext).pop();

                // Update state
                setState(() {
                  _lands.add({
                    'name': landName,
                    'hectares': hectares,
                    'crop': cropType,
                    'soil': soilType,
                  });
                });

                // Save lands to storage
                _saveLands();

                // Show feedback
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('New land added'),
                    backgroundColor: Color(0xFF00A651),
                  ),
                );
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _deleteLand(int index) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Land'),
          content: Text(
            'Are you sure you want to delete "${_lands[index]['name']}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  // Remove the land
                  _lands.removeAt(index);
                });

                // Save changes
                _saveLands();

                // Show feedback
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Land deleted'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDCF5EA),
      appBar: AppBar(
        title: const Text(
          'Farm Management',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00A651),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildLandsSection(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                FertilizerCalculatorPage(
                  lands: _lands,
                  onLandsUpdated: _updateLands,
                ),
                WaterCalculatorPage(
                  lands: _lands,
                  onLandsUpdated: _updateLands,
                ),
                YieldTrackingPage(lands: _lands, onLandsUpdated: _updateLands),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildLandsSection() {
    return Container(
      color: const Color(0xFFDCF5EA),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Lands',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: _addNewLand,
                icon: const Icon(Icons.add, color: Color(0xFF00A651)),
                label: const Text(
                  'Add New',
                  style: TextStyle(color: Color(0xFF00A651)),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _lands.isEmpty
              ? _buildEmptyLandsSection()
              : SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _lands.length,
                  itemBuilder: (context, index) {
                    final land = _lands[index];
                    return _buildLandCard(
                      name: land['name'],
                      hectares: land['hectares'],
                      crop: land['crop'],
                      soil: land['soil'],
                      onDelete: () => _deleteLand(index),
                    );
                  },
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildEmptyLandsSection() {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF00A651).withValues(alpha: 0.3),
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_location_alt_outlined,
            size: 32,
            color: const Color(0xFF00A651).withValues(alpha: 0.7),
          ),
          const SizedBox(height: 12),
          const Text(
            'No lands yet. Add your first land!',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _addNewLand,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00A651),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Add New Land'),
          ),
        ],
      ),
    );
  }

  Widget _buildLandCard({
    required String name,
    required double hectares,
    required String crop,
    required String soil,
    VoidCallback? onDelete,
  }) {
    return Container(
      width: 160,
      height: 140,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00A651).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.layers,
                        color: Color(0xFF00A651),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.crop_square_outlined,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$hectares hectares',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Crops:',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              crop,
                              style: const TextStyle(fontSize: 12),
                              textAlign: TextAlign.right,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Soil:',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              soil,
                              style: const TextStyle(fontSize: 12),
                              textAlign: TextAlign.right,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (onDelete != null)
            Positioned(
              top: 0,
              right: 0,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onDelete,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      ),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFF00A651),
        labelColor: const Color(0xFF00A651),
        unselectedLabelColor: Colors.grey,
        tabs: const [
          Tab(text: 'Fertilizer'),
          Tab(text: 'Water'),
          Tab(text: 'Yield'),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == _selectedIndex) return;

          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MarketPage()),
              );
              break;
            case 1:
              // We're already on the Management page, no need to navigate
              break;
            case 2:
              // Navigate to Home page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomePage(initialTab: 0),
                ),
              );
              break;
            case 3:
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Video page coming soon'),
                  duration: Duration(seconds: 2),
                ),
              );
              break;
            case 4:
              // Navigate to Profile page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfilePage(username: ''),
                ),
              );
              break;
          }
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
