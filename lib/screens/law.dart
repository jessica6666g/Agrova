// screens/laws_page.dart
import 'package:agrova/models/agri_law_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class LawsPage extends StatefulWidget {
  const LawsPage({super.key});

  @override
  State<LawsPage> createState() => _LawsPageState();
}

class _LawsPageState extends State<LawsPage> {
  bool _isLoading = false;
  final List<AgricultureLaw> _laws = _getMockLaws();
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Regulations',
    'Subsidies',
    'Environmental',
    'Land Use',
    'Trade',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFADF5E9),
      appBar: AppBar(
        title: const Text(
          'Agricultural Laws & Policies',
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
                    : _buildLawsList(),
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

  Widget _buildLawsList() {
    // Filter laws based on selected category
    final filteredLaws =
        _selectedCategory == 'All'
            ? _laws
            : _laws.where((law) => law.category == _selectedCategory).toList();

    return filteredLaws.isEmpty
        ? _buildEmptyState()
        : RefreshIndicator(
          onRefresh: _refreshLaws,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredLaws.length,
            itemBuilder: (context, index) {
              final law = filteredLaws[index];
              return _buildLawCard(law);
            },
          ),
        );
  }

  Widget _buildLawCard(AgricultureLaw law) {
    final dateFormat = DateFormat('MMMM d, yyyy');
    final formattedDate = dateFormat.format(law.effectiveDate);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with category and date
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF00A651).withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    law.category,
                    style: const TextStyle(
                      color: Color(0xFF00A651),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey[700],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Effective: $formattedDate',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Law title
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              law.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          // Law description
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              law.description,
              style: const TextStyle(fontSize: 14, height: 1.4),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Law details button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    _showLawDetails(law);
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

  void _showLawDetails(AgricultureLaw law) {
    final dateFormat = DateFormat('MMMM d, yyyy');
    final formattedDate = dateFormat.format(law.effectiveDate);

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

                      // Law header
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                                    law.category,
                                    style: const TextStyle(
                                      color: Color(0xFF00A651),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  law.title,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Effective date
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
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
                                  'Effective Date',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  formattedDate,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Law description
                      const Text(
                        'Overview',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        law.description,
                        style: const TextStyle(fontSize: 15, height: 1.5),
                      ),

                      const SizedBox(height: 24),

                      // Key points
                      const Text(
                        'Key Provisions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...law.keyPoints.map(
                        (point) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.gavel,
                                color: Color(0xFF00A651),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  point,
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

                      // View document button (if document URL is available)
                      if (law.documentUrl != null)
                        ElevatedButton(
                          onPressed: () {
                            _launchUrl(law.documentUrl!);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00A651),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'View Official Document',
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
            Icon(Icons.gavel_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Laws or Policies Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'There are no agricultural laws or policies in this category. Try selecting a different category.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshLaws() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });
  }

  // Mock data generation
  static List<AgricultureLaw> _getMockLaws() {
    return [
      AgricultureLaw(
        id: '1',
        title: 'Agricultural Subsidies Act of 2023',
        description:
            'Establishes comprehensive subsidy programs to support farmers in adopting sustainable agricultural practices, investing in modern technology, and improving productivity while ensuring environmental protection.',
        category: 'Subsidies',
        effectiveDate: DateTime(2023, 6, 15),
        keyPoints: [
          'Provides financial incentives for farmers who adopt certified sustainable farming practices.',
          'Offers technology adoption grants covering up to 50% of costs for modernizing farm equipment.',
          'Establishes interest-free loans for small-scale farmers to improve irrigation systems.',
          'Creates tax exemptions for agricultural inputs and machinery.',
          'Requires annual reporting on subsidy utilization and impact assessment.',
        ],
      ),
      AgricultureLaw(
        id: '2',
        title: 'Pesticide Regulation Amendment',
        description:
            'Updates regulations regarding the use, storage, and disposal of agricultural pesticides to protect environmental health, farmer safety, and consumer well-being, while maintaining crop protection capabilities.',
        category: 'Regulations',
        effectiveDate: DateTime(2024, 1, 10),
        keyPoints: [
          'Bans 15 high-toxicity pesticides identified as harmful to pollinators and water systems.',
          'Requires certification and annual training for all pesticide applicators.',
          'Establishes buffer zones around water bodies and residential areas where pesticide application is restricted.',
          'Mandates detailed record-keeping of all pesticide applications.',
          'Sets stricter maximum residue limits for food crops based on latest scientific evidence.',
        ],
      ),
      AgricultureLaw(
        id: '3',
        title: 'Agricultural Land Protection Act',
        description:
            'Designates prime agricultural lands for protection from development and conversion to non-agricultural uses, ensuring long-term food security and preserving valuable farming resources for future generations.',
        category: 'Land Use',
        effectiveDate: DateTime(2022, 11, 5),
        keyPoints: [
          'Classifies and maps agricultural land into three tiers of importance based on soil quality and agricultural value.',
          'Requires special permissions and impact assessments for any conversion of tier 1 and 2 agricultural lands.',
          'Offers tax benefits to landowners who place their agricultural land under long-term conservation easements.',
          'Establishes a land bank program to purchase threatened agricultural lands for preservation.',
          'Creates penalties for unauthorized conversion of protected agricultural lands.',
        ],
      ),
      AgricultureLaw(
        id: '4',
        title: 'Climate-Smart Agriculture Initiative',
        description:
            'Comprehensive policy framework to support farmers in adopting climate-resilient farming practices, reducing greenhouse gas emissions, and sequestering carbon while maintaining productivity and profitability.',
        category: 'Environmental',
        effectiveDate: DateTime(2023, 9, 1),
        keyPoints: [
          'Establishes a carbon credit program specifically for agricultural carbon sequestration activities.',
          'Provides grants for implementing climate-adaptive farming techniques and infrastructure.',
          'Creates tax incentives for reducing methane emissions from livestock operations.',
          'Funds research and extension services focused on climate-resilient crop varieties and farming methods.',
          'Mandates climate risk assessments for large agricultural operations.',
        ],
      ),
      AgricultureLaw(
        id: '5',
        title: 'Agricultural Export Promotion Framework',
        description:
            'Establishes mechanisms to support and promote the export of agricultural products to international markets, including quality standards, certification processes, and trade facilitation measures.',
        category: 'Trade',
        effectiveDate: DateTime(2024, 3, 15),
        keyPoints: [
          'Creates a streamlined certification system for agricultural exports meeting international standards.',
          'Establishes an Agricultural Export Promotion Office to help farmers access international markets.',
          'Provides subsidies for export-related certifications and compliance costs.',
          'Develops country-specific marketing strategies for key agricultural exports.',
          'Offers financial support for participating in international trade shows and exhibitions.',
        ],
      ),
    ];
  }
}
