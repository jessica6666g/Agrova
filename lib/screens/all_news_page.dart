import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AllNewsPage extends StatefulWidget {
  final List<dynamic> newsList;

  const AllNewsPage({super.key, required this.newsList});

  @override
  State<AllNewsPage> createState() => _AllNewsPageState();
}

class _AllNewsPageState extends State<AllNewsPage> {
  List<dynamic> _filteredNews = [];
  String _selectedFilter = 'All'; // Default filter

  // List of filter categories
  final List<String> _filterOptions = [
    'All',
    'Weather',
    'Technology',
    'Finance',
    'Policy',
    'Animals',
    'Crops',
  ];

  @override
  void initState() {
    super.initState();
    _filteredNews = List.from(widget.newsList);
    debugPrint(
      'AllNewsPage initialized with ${widget.newsList.length} news items',
    );
  }

  // Apply filter to news list
  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;

      if (filter == 'All') {
        _filteredNews = List.from(widget.newsList);
      } else {
        _filteredNews =
            widget.newsList.where((news) {
              final title = (news['title'] ?? '').toLowerCase();
              final description = (news['description'] ?? '').toLowerCase();
              final content = '$title $description';

              switch (filter) {
                case 'Weather':
                  return content.contains('weather') ||
                      content.contains('climate') ||
                      content.contains('rain') ||
                      content.contains('temperature');
                case 'Technology':
                  return content.contains('tech') ||
                      content.contains('digital') ||
                      content.contains('innovation') ||
                      content.contains('device');
                case 'Finance':
                  return content.contains('money') ||
                      content.contains('price') ||
                      content.contains('fund') ||
                      content.contains('subsidy') ||
                      content.contains('cost');
                case 'Policy':
                  return content.contains('policy') ||
                      content.contains('law') ||
                      content.contains('regulation') ||
                      content.contains('government');
                case 'Animals':
                  return content.contains('animal') ||
                      content.contains('livestock') ||
                      content.contains('cattle') ||
                      content.contains('poultry');
                case 'Crops':
                  return content.contains('crop') ||
                      content.contains('harvest') ||
                      content.contains('grain') ||
                      content.contains('plant');
                default:
                  return true;
              }
            }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Agriculture News',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF00A651),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Colors.white,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    'Filter by category:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        _filterOptions.map((filter) {
                          final isSelected = _selectedFilter == filter;

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              selected: isSelected,
                              label: Text(filter),
                              onSelected: (_) => _applyFilter(filter),
                              backgroundColor: Colors.grey[200],
                              selectedColor: const Color(
                                0xFF00A651,
                              ).withValues(alpha: 0.2),
                              checkmarkColor: const Color(0xFF00A651),
                              labelStyle: TextStyle(
                                color:
                                    isSelected
                                        ? const Color(0xFF00A651)
                                        : Colors.black87,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // News count
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  '${_filteredNews.length} news articles',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_selectedFilter != 'All')
                  TextButton.icon(
                    onPressed: () => _applyFilter('All'),
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Clear filter'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // News list
          Expanded(
            child:
                _filteredNews.isEmpty
                    ? _buildEmptyFilterState()
                    : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredNews.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final news = _filteredNews[index];

                        // Extract source name
                        String sourceName = '';
                        if (news['source'] != null &&
                            news['source']['name'] != null) {
                          sourceName = news['source']['name'];
                        }

                        return _buildNewsItem(
                          title: news['title'] ?? 'No title available',
                          description:
                              news['description'] ?? 'No description available',
                          url: news['url'] ?? '',
                          imageUrl: news['urlToImage'],
                          publishedAt: news['publishedAt'] ?? '',
                          sourceName: sourceName,
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  // Empty state when filter returns no results
  Widget _buildEmptyFilterState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.filter_list_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No articles found for "$_selectedFilter" category',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Try selecting a different category filter',
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _applyFilter('All'),
              icon: const Icon(Icons.refresh),
              label: const Text('Show All News'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A651),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsItem({
    required String title,
    required String description,
    required String url,
    String? imageUrl,
    required String publishedAt,
    required String sourceName,
  }) {
    String timeAgo = '';

    if (publishedAt.isNotEmpty) {
      try {
        final date = DateTime.parse(publishedAt);
        final now = DateTime.now();
        final difference = now.difference(date);

        // Show time ago in a user-friendly format
        if (difference.inDays > 0) {
          timeAgo = '${difference.inDays}d ago';
        } else if (difference.inHours > 0) {
          timeAgo = '${difference.inHours}h ago';
        } else if (difference.inMinutes > 0) {
          timeAgo = '${difference.inMinutes}m ago';
        } else {
          timeAgo = 'Just now';
        }
      } catch (e) {
        debugPrint('Error parsing date: $e');
      }
    }

    return InkWell(
      onTap: () {
        if (url.isNotEmpty) {
          _launchNewsUrl(url);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child:
                  imageUrl != null && imageUrl.isNotEmpty
                      ? Image.network(
                        imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.white70,
                              ),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },
                      )
                      : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.white70,
                          ),
                        ),
                      ),
            ),

            const SizedBox(width: 12),

            // News content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Description
                  Text(
                    description,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Time ago, source and date
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // Time ago with highlighted color
                      if (timeAgo.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF00A651,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            timeAgo,
                            style: const TextStyle(
                              color: Color(0xFF00A651),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                      if (timeAgo.isNotEmpty && sourceName.isNotEmpty)
                        const SizedBox(width: 6),

                      // Source
                      if (sourceName.isNotEmpty)
                        Expanded(
                          child: Text(
                            sourceName,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
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
    );
  }

  // Launch URL for news article
  Future<void> _launchNewsUrl(String url) async {
    try {
      debugPrint('Attempting to launch URL: $url');
      final uri = Uri.parse(url);

      // Check if URL can be launched first
      final canLaunch = await canLaunchUrl(uri);
      debugPrint('Can launch URL: $canLaunch');

      if (canLaunch) {
        final result = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        debugPrint('Launch result: $result');
      } else {
        debugPrint('Cannot launch URL: $url');
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open article. Please try again later.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
