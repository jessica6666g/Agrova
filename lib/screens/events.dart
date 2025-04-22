// screens/events_page.dart
import 'package:agrova/models/event_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  bool _isLoading = false;
  final List<AgricultureEvent> _events = _getMockEvents();

  // Filter state
  String _selectedFilter = 'All';
  final List<String> _filterOptions = [
    'All',
    'Upcoming',
    'Past',
    'This Month',
    'Next Month',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFADF5E9),
      appBar: AppBar(
        title: const Text(
          'Agriculture Events',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF00A651),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilterOptions(),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildEventsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOptions() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filterOptions.length,
        itemBuilder: (context, index) {
          final filter = _filterOptions[index];
          final isSelected = filter == _selectedFilter;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = filter;
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
                  filter,
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

  List<AgricultureEvent> _getFilteredEvents() {
    final now = DateTime.now();
    final thisMonthEnd = DateTime(now.year, now.month + 1, 0);
    final nextMonthStart = DateTime(now.year, now.month + 1, 1);
    final nextMonthEnd = DateTime(now.year, now.month + 2, 0);

    switch (_selectedFilter) {
      case 'Upcoming':
        return _events.where((event) => event.date.isAfter(now)).toList();
      case 'Past':
        return _events.where((event) => event.date.isBefore(now)).toList();
      case 'This Month':
        return _events
            .where(
              (event) =>
                  event.date.isAfter(now) &&
                  event.date.isBefore(
                    thisMonthEnd.add(const Duration(days: 1)),
                  ),
            )
            .toList();
      case 'Next Month':
        return _events
            .where(
              (event) =>
                  event.date.isAfter(nextMonthStart) &&
                  event.date.isBefore(
                    nextMonthEnd.add(const Duration(days: 1)),
                  ),
            )
            .toList();
      case 'All':
      default:
        return _events;
    }
  }

  Widget _buildEventsList() {
    final filteredEvents = _getFilteredEvents();

    return RefreshIndicator(
      onRefresh: _refreshEvents,
      child:
          filteredEvents.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredEvents.length,
                itemBuilder: (context, index) {
                  final event = filteredEvents[index];
                  return _buildEventCard(event);
                },
              ),
    );
  }

  Widget _buildEventCard(AgricultureEvent event) {
    final dateFormat = DateFormat('EEE, MMM d, yyyy');
    final formattedDate = dateFormat.format(event.date);

    // Calculate if event is upcoming or past
    final now = DateTime.now();
    final isUpcoming = event.date.isAfter(now);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event image or placeholder
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
                  event.imageUrl.isNotEmpty
                      ? DecorationImage(
                        image: AssetImage(event.imageUrl),
                        fit: BoxFit.cover,
                      )
                      : null,
            ),
            child:
                event.imageUrl.isEmpty
                    ? Center(
                      child: Icon(
                        Icons.event,
                        size: 60,
                        color: const Color(0xFF00A651).withValues(alpha: 0.5),
                      ),
                    )
                    : null,
          ),

          // Event status badge
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isUpcoming
                            ? const Color(0xFF00A651).withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isUpcoming ? 'Upcoming' : 'Past Event',
                    style: TextStyle(
                      color:
                          isUpcoming
                              ? const Color(0xFF00A651)
                              : Colors.grey[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  formattedDate,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),

          // Event title
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              event.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          // Event location
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  event.location,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),

          // Event description
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              event.description,
              style: const TextStyle(fontSize: 14, height: 1.4),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Event details button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    _showEventDetails(event);
                  },
                  child: const Row(
                    children: [
                      Text(
                        'View Details',
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

  void _showEventDetails(AgricultureEvent event) {
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final formattedDate = dateFormat.format(event.date);

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

                      // Event image
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00A651).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          image:
                              event.imageUrl.isNotEmpty
                                  ? DecorationImage(
                                    image: AssetImage(event.imageUrl),
                                    fit: BoxFit.cover,
                                  )
                                  : null,
                        ),
                        child:
                            event.imageUrl.isEmpty
                                ? Center(
                                  child: Icon(
                                    Icons.event,
                                    size: 80,
                                    color: const Color(
                                      0xFF00A651,
                                    ).withValues(alpha: 0.5),
                                  ),
                                )
                                : null,
                      ),

                      const SizedBox(height: 24),

                      // Event title
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Event date and location
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  color: Color(0xFF00A651),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Date',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      formattedDate,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Color(0xFF00A651),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Location',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      event.location,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Icon(
                                  Icons.person_outline,
                                  color: Color(0xFF00A651),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Organizer',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      event.organizer,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Event description
                      const Text(
                        'About This Event',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        event.description,
                        style: const TextStyle(fontSize: 15, height: 1.5),
                      ),

                      const SizedBox(height: 32),

                      // Register button
                      ElevatedButton(
                        onPressed: () {
                          _showRegistrationDialog(event);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00A651),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Register for This Event',
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

  void _showRegistrationDialog(AgricultureEvent event) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Registration Confirmation'),
            content: Text(
              'Would you like to register for the event: ${event.title}?\n\n'
              'This is a placeholder for actual registration functionality.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Registration successful!'),
                      backgroundColor: Color(0xFF00A651),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A651),
                ),
                child: const Text('Register'),
              ),
            ],
          ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Events Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _selectedFilter == 'All'
                  ? 'There are no agricultural events to display at this time. Check back later for upcoming events.'
                  : 'There are no events in the "$_selectedFilter" category. Try selecting a different filter.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshEvents() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });
  }

  static List<AgricultureEvent> _getMockEvents() {
    return [
      AgricultureEvent(
        id: '1',
        title: 'National Agricultural Exhibition 2025',
        description:
            'Join us for the largest agricultural exhibition showcasing the latest farming technologies, sustainable practices, and innovations. Network with industry experts, attend workshops, and explore opportunities for growth in the agricultural sector.',
        date: DateTime.now().add(const Duration(days: 30)),
        location: 'Kuala Lumpur Convention Center',
        organizer: 'Ministry of Agriculture Malaysia',
      ),
      AgricultureEvent(
        id: '2',
        title: 'Sustainable Farming Workshop',
        description:
            'Learn practical techniques for sustainable farming that increase yield while preserving the environment. This hands-on workshop covers organic pest control, water conservation, soil health management, and crop rotation strategies.',
        date: DateTime.now().add(const Duration(days: 15)),
        location: 'UPM Agricultural Campus, Serdang',
        organizer: 'Sustainable Agriculture Association',
      ),
      AgricultureEvent(
        id: '3',
        title: 'Agricultural Technology Summit',
        description:
            'Discover how emerging technologies are revolutionizing agriculture. Topics include precision farming, IoT applications, drone usage, AI in crop management, and blockchain for supply chain transparency.',
        date: DateTime.now().add(const Duration(days: 45)),
        location: 'Putrajaya International Convention Centre',
        organizer: 'AgriTech Malaysia',
      ),
      AgricultureEvent(
        id: '4',
        title: 'Local Farmers Market',
        description:
            'Connect directly with consumers at this farmers market featuring locally grown produce. A great opportunity for small-scale farmers to showcase their products and build customer relationships.',
        date: DateTime.now().add(const Duration(days: 7)),
        location: 'Taman Tasik Titiwangsa, Kuala Lumpur',
        organizer: 'Community Farming Network',
      ),
      AgricultureEvent(
        id: '5',
        title: 'Crop Disease Management Seminar',
        description:
            'Expert plant pathologists will present the latest research on identifying, preventing, and treating common crop diseases affecting Malaysian agriculture, with a focus on sustainable and integrated pest management approaches.',
        date: DateTime.now().subtract(const Duration(days: 10)), // Past event
        location: 'MARDI Research Centre, Serdang',
        organizer: 'Plant Protection Society of Malaysia',
      ),
      AgricultureEvent(
        id: '6',
        title: 'Urban Farming Conference',
        description:
            'Explore the potential of urban farming to enhance food security in cities. This conference covers vertical farming, hydroponics, rooftop gardens, and community-based agricultural initiatives in urban environments.',
        date: DateTime.now().add(const Duration(days: 20)),
        location: 'KLCC Convention Centre, Kuala Lumpur',
        organizer: 'Urban Agriculture Society',
      ),
      AgricultureEvent(
        id: '7',
        title: 'Organic Certification Workshop',
        description:
            'A comprehensive workshop on organic certification requirements, processes, and standards. Learn how to transition to certified organic production and access premium markets for organic produce.',
        date: DateTime.now().add(const Duration(days: 60)),
        location: 'Department of Agriculture, Putrajaya',
        organizer: 'Malaysian Organic Farmers Association',
      ),
      AgricultureEvent(
        id: '8',
        title: 'Agriculture Finance Forum',
        description:
            'Financial experts discuss grants, loans, subsidies, and investment opportunities specifically for the agricultural sector. Learn about financial planning, risk management, and accessing capital for farm expansion.',
        date: DateTime.now().add(const Duration(days: 25)),
        location: 'Kuala Lumpur Financial District',
        organizer: 'Agricultural Development Bank',
      ),
      AgricultureEvent(
        id: '9',
        title: 'Youth in Agriculture Summit',
        description:
            'Encouraging the next generation of farmers and agricultural entrepreneurs. Young farmers share success stories, while industry leaders discuss career opportunities and innovative approaches in modern agriculture.',
        date: DateTime.now().add(const Duration(days: 35)),
        location: 'UiTM Shah Alam Campus',
        organizer: 'Young Farmers Network Malaysia',
      ),
      AgricultureEvent(
        id: '10',
        title: 'Agricultural Policy Roundtable',
        description:
            'Government officials, farmers, and agricultural stakeholders discuss current policies and future regulatory directions for Malaysian agriculture, focusing on sustainability, competitiveness, and food security.',
        date: DateTime.now().subtract(const Duration(days: 20)), // Past event
        location: 'Ministry of Agriculture Headquarters, Putrajaya',
        organizer: 'Policy Research Institute',
      ),
    ];
  }
}
