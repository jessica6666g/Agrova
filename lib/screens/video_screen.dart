// video_screen.dart
import 'dart:async';
import 'package:agrova/screens/market_page.dart';
import 'package:agrova/screens/farm_management_page.dart';
import 'package:agrova/screens/profile_page.dart';
import 'package:agrova/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart'; // Import video player package

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Removed "Pest Control" and "Water Management"
  final List<String> _trendingTopics = [
    'Organic Farming',
    'Seasonal Harvest',
    'Smart Technology',
  ];

  int _selectedTopicIndex = 0;

  // Add video controller for featured video
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;

  // Timer to update video position
  late Timer _positionTimer;

  // Mock data for short videos
  final List<ShortVideo> _shortVideos = [
    ShortVideo(
      id: '1',
      title: '3 tips to grow healthy tomatoes',
      description:
          '3 tips to grow healthy tomatoes : Planting, Pruning & Making an organic fertiliser',
      thumbnailUrl: 'assets/images/tomato_video.png',
      videoUrl: 'assets/videos/Download.mp4',
      authorName: 'GardenPro',
      likes: 2345,
      comments: 123,
      duration: const Duration(seconds: 15),
      tags: ['Organic Farming'],
      isLiked: false,
      isSaved: false,
    ),

    // Added video for Seasonal Harvest
    ShortVideo(
      id: '4',
      title: 'Huge Passionn Fruit Harvest',
      description:
          'This passion fruit has been here for only a year and I still got this insane harvest! ',
      thumbnailUrl: 'assets/images/harvestimage.png',
      videoUrl: 'assets/videos/harvestvideo.mp4',
      authorName: 'HarvestExpert',
      likes: 1532,
      comments: 78,
      duration: const Duration(seconds: 25),
      tags: ['Seasonal Harvest'],
      isLiked: false,
      isSaved: false,
    ),
    // Added another video for Smart Technology
    ShortVideo(
      id: '5',
      title: 'Smart agriculture technology',
      description:
          'Explore the innovative world of smart farming in South Korea, where advanced technology meets traditional agriculture to boost productivity and sustainability.',
      thumbnailUrl: 'assets/images/smartimage.png',
      videoUrl: 'assets/videos/smarttech.mp4',
      authorName: 'TechFarmer',
      likes: 2156,
      comments: 92,
      duration: const Duration(seconds: 35),
      tags: ['Smart Technology'],
      isLiked: false,
      isSaved: false,
    ),
  ];

  // Mock data for livestreams
  final List<Livestream> _livestreams = [
    Livestream(
      id: '1',
      title: 'Harvest Season Tips and Techniques',
      authorName: 'AgriExpert',
      thumbnailUrl: 'assets/images/harvest_stream.png',
      viewerCount: 285,
      isLive: true,
      scheduledTime: DateTime.now(),
      tags: ['Seasonal Harvest', 'Tech Tips'],
    ),
    Livestream(
      id: '2',
      title: 'FARMERS MARKET',
      authorName: 'MarketInsights',
      thumbnailUrl: 'assets/images/farmers_market.png',
      viewerCount: 142,
      isLive: true,
      scheduledTime: DateTime.now(),
      tags: ['Market Trends'],
    ),
    Livestream(
      id: '3',
      title: 'Q&A: Best Practices for Irrigation',
      authorName: 'WaterPro',
      thumbnailUrl: 'assets/images/irrigation.png',
      viewerCount: 0,
      isLive: false,
      scheduledTime: DateTime.now().add(const Duration(days: 2)),
      tags: ['Smart Technology'],
    ),
  ];

  // Mock data for featured creators
  final List<Creator> _creators = [
    Creator(
      id: '1',
      name: 'FarmEx',
      avatarUrl: 'assets/images/creator1.png', // Use correct path
      followers: 15200,
    ),
    Creator(
      id: '2',
      name: 'MarketIntel',
      avatarUrl: 'assets/images/creator2.png', // Use correct path
      followers: 8750,
    ),
    Creator(
      id: '3',
      name: 'OrgFar',
      avatarUrl: 'assets/images/creator3.png', // Use correct path
      followers: 12400,
    ),
    Creator(
      id: '4',
      name: 'HarvestPro',
      avatarUrl: 'assets/images/creator4.png', // Use correct path
      followers: 9300,
    ),
    Creator(
      id: '5',
      name: 'AgriTech',
      avatarUrl: 'assets/images/creator5.png', // Use correct path
      followers: 18900,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      // Check if the tab selection has actually changed
      if (_tabController.indexIsChanging ||
          _tabController.animation!.value != _tabController.index.toDouble()) {
        // If moving to Livestreams tab
        if (_tabController.index == 1) {
          // Make sure to pause video when leaving the Short Videos tab
          if (_isVideoInitialized && _videoController.value.isPlaying) {
            _videoController.pause();
            print('Video paused: leaving Short Videos tab'); // For debugging
          }
        } else if (_tabController.index == 0) {
          // Optionally auto-resume when returning to Short Videos tab

          // if (_isVideoInitialized && !_videoController.value.isPlaying) {
          //   _videoController.play();
          //   print('Video resumed: returning to Short Videos tab'); // For debugging
          // }
        }
      }

      // Always trigger a rebuild
      setState(() {});
    });

    // Initialize video player
    _initVideoPlayer();

    // Initialize timer to update the progress indicator every 200ms for smoother updates
    _positionTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (_isVideoInitialized && mounted && _videoController.value.isPlaying) {
        setState(() {
          // This triggers a rebuild to update the time indicator
        });
      }
    });
  }

  // Add a separate video position listener function
  void _videoPositionListener() {
    if (mounted) {
      setState(() {
        // This will rebuild the UI when the video position changes
      });
    }
  }

  void _initVideoPlayer() {
    // Initialize video with the currently selected topic's first video
    final filteredVideos =
        _shortVideos
            .where(
              (video) =>
                  video.tags.contains(_trendingTopics[_selectedTopicIndex]),
            )
            .toList();

    if (filteredVideos.isNotEmpty) {
      _videoController = VideoPlayerController.asset(filteredVideos[0].videoUrl)
        ..initialize().then((_) {
          // Set volume to max to ensure audio plays
          _videoController.setVolume(1.0);

          // Add position listener with explicit setState for timer updates
          _videoController.addListener(_videoPositionListener);

          setState(() {
            _isVideoInitialized = true;
          });

          // Set video to loop
          _videoController.setLooping(true);
          // Start playing automatically when initialized
          _videoController.play();
        });
    }
  }

  void _changeVideo(String topic) {
    // Remove listener before disposing
    _videoController.removeListener(_videoPositionListener);

    // Dispose current controller
    _videoController.dispose();
    setState(() {
      _isVideoInitialized = false;
    });

    // Find videos for the selected topic
    final filteredVideos =
        _shortVideos.where((video) => video.tags.contains(topic)).toList();

    if (filteredVideos.isNotEmpty) {
      _videoController = VideoPlayerController.asset(filteredVideos[0].videoUrl)
        ..initialize().then((_) {
          _videoController.setVolume(1.0);

          // Add position listener here too
          _videoController.addListener(_videoPositionListener);

          setState(() {
            _isVideoInitialized = true;
          });
          _videoController.setLooping(true);
          _videoController.play();
        });
    }
  }

  @override
  void dispose() {
    // First pause the video if it's playing
    if (_isVideoInitialized && _videoController.value.isPlaying) {
      _videoController.pause();
    }

    // Then handle the rest of the cleanup
    if (_isVideoInitialized) {
      _videoController.removeListener(_videoPositionListener);
    }
    _tabController.dispose();
    _videoController.dispose();
    _positionTimer.cancel(); // Cancel timer when widget is disposed
    super.dispose();
  }

  // Methods for interaction functions
  void _likeVideo(ShortVideo video) {
    setState(() {
      // Toggle like status
      video.isLiked = !video.isLiked;
      // Update likes count
      if (video.isLiked) {
        video.likes++;
      } else {
        video.likes--;
      }
    });

    _showInteractionMessage('Video ${video.isLiked ? 'liked' : 'unliked'}');
  }

  void _commentOnVideo(ShortVideo video) {
    // Show comment dialog
    _showCommentDialog(video);
  }

  void _shareVideo(ShortVideo video) {
    // Simulate sharing
    _showInteractionMessage('Sharing video: ${video.title}');
  }

  void _saveVideo(ShortVideo video) {
    setState(() {
      // Toggle save status
      video.isSaved = !video.isSaved;
    });

    _showInteractionMessage(
      video.isSaved ? 'Video saved to profile' : 'Video removed from profile',
    );
  }

  void _showInteractionMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  void _showCommentDialog(ShortVideo video) {
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Comment on "${video.title}"'),
            content: TextField(
              controller: commentController,
              decoration: const InputDecoration(
                hintText: 'Add your comment here...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (commentController.text.isNotEmpty) {
                    setState(() {
                      video.comments++;
                    });
                    Navigator.pop(context);
                    _showInteractionMessage('Comment added!');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A651),
                ),
                child: const Text('Post'),
              ),
            ],
          ),
    );
  }

  Widget _buildUpcomingStreamsList() {
    final upcomingStreams =
        _livestreams.where((stream) => !stream.isLive).toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: upcomingStreams.length,
      itemBuilder: (context, index) {
        final stream = upcomingStreams[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: SizedBox(
                  width: 120,
                  height: 80,
                  child: Image.asset(
                    'assets/images/irrigation.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Stream info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stream.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Starts on April 25, 2025',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Reminder',
                          style: TextStyle(color: Colors.black87, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToPage(int index) {
    // Pause video if it's playing before navigating away
    if (_isVideoInitialized && _videoController.value.isPlaying) {
      _videoController.pause();
    }

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MarketPage()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FarmManagementPage()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        break;
      case 3:
        // Already on VideoScreen
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage(username: '')),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFADF5E9),
      appBar: AppBar(
        title: const Text(
          'Farm Videos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00A651),
        elevation: 0,
        // Remove back button or any other buttons in the app bar
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [Tab(text: 'Short Videos'), Tab(text: 'Livestreams')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildShortVideosTab(), _buildLivestreamsTab()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3, // Video tab selected
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: _navigateToPage,
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

  Widget _buildShortVideosTab() {
    return Column(
      children: [
        _buildTrendingTopics(),
        Expanded(child: _buildFeaturedVideo()),
      ],
    );
  }

  Widget _buildTrendingTopics() {
    return Container(
      height: 50,
      color: const Color(0xFFCFF7EE),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _trendingTopics.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedTopicIndex == index;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTopicIndex = index;
                });
                // Change video when topic changes
                _changeVideo(_trendingTopics[index]);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF00A651) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF00A651), width: 1),
                ),
                child: Row(
                  children: [
                    if (isSelected)
                      const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    Text(
                      _trendingTopics[index],
                      style: TextStyle(
                        color:
                            isSelected ? Colors.white : const Color(0xFF00A651),
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedVideo() {
    // Get videos for the current topic
    final filteredVideos =
        _shortVideos
            .where(
              (video) =>
                  video.tags.contains(_trendingTopics[_selectedTopicIndex]),
            )
            .toList();

    if (filteredVideos.isEmpty) {
      return const Center(
        child: Text(
          'No videos found for this topic.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    // Display the first video in the filtered list
    final video = filteredVideos[0];

    return Stack(
      fit: StackFit.expand,
      children: [
        // Video player
        _isVideoInitialized
            ? GestureDetector(
              onTap: () {
                setState(() {
                  if (_videoController.value.isPlaying) {
                    _videoController.pause();
                  } else {
                    _videoController.play();
                  }
                });
              },
              child: AspectRatio(
                aspectRatio: _videoController.value.aspectRatio,
                child: VideoPlayer(_videoController),
              ),
            )
            : Image.asset(video.thumbnailUrl, fit: BoxFit.cover),

        // Play button overlay (shown when video is paused)
        if (_isVideoInitialized && !_videoController.value.isPlaying)
          Center(
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),

        // REMOVED: Duration indicator at top right

        // Interaction buttons (right side)
        Positioned(
          right: 16,
          bottom: 100,
          child: Column(
            children: [
              // Like button
              _buildInteractionButton(
                icon: video.isLiked ? Icons.favorite : Icons.favorite_border,
                label: video.likes.toString(),
                color: video.isLiked ? Colors.red : Colors.white,
                onTap: () => _likeVideo(video),
              ),
              const SizedBox(height: 16),
              // Comment button
              _buildInteractionButton(
                icon: Icons.comment,
                label: video.comments.toString(),
                onTap: () => _commentOnVideo(video),
              ),
              const SizedBox(height: 16),
              // Share button
              _buildInteractionButton(
                icon: Icons.share,
                label: 'Share',
                onTap: () => _shareVideo(video),
              ),
              const SizedBox(height: 16),
              // Save button
              _buildInteractionButton(
                icon: video.isSaved ? Icons.bookmark : Icons.bookmark_border,
                label: 'Save',
                color: video.isSaved ? Colors.yellow : Colors.white,
                onTap: () => _saveVideo(video),
              ),
            ],
          ),
        ),

        // Video info (bottom)
        Positioned(
          left: 16,
          right: 72,
          bottom: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                video.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                video.description,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.grey,
                    child: Text(
                      video.authorName[0],
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    video.authorName,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInteractionButton({
    required IconData icon,
    required String label,
    Color color = Colors.white,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // Update the _buildLivestreamsTab method to show trending topics with buttons that don't have functionality

  Widget _buildLivestreamsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add trending topics bar (no functionality)
          Container(
            height: 50,
            color: const Color(0xFFCFF7EE),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _trendingTopics.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          index == 0 ? const Color(0xFF00A651) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF00A651),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        if (index == 0)
                          const Padding(
                            padding: EdgeInsets.only(right: 4),
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        Text(
                          _trendingTopics[index],
                          style: TextStyle(
                            color:
                                index == 0
                                    ? Colors.white
                                    : const Color(0xFF00A651),
                            fontWeight:
                                index == 0
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Featured livestream
                _buildFeaturedLivestream(),

                // Live now section
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Live Now',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'See All',
                        style: TextStyle(color: Color(0xFF00A651)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildLiveNowGrid(),

                // Upcoming streams
                const SizedBox(height: 24),
                const Text(
                  'Upcoming Streams',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                _buildUpcomingStreamsList(),

                // Featured creators
                const SizedBox(height: 24),
                const Text(
                  'Featured Creators',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                _buildFeaturedCreators(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedLivestream() {
    final livestream = _livestreams[0];

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Thumbnail
          Image.asset('assets/images/harvest_stream.png', fit: BoxFit.cover),

          // Overlay gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
              ),
            ),
          ),

          // Live indicator and viewer count
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'LIVE',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),

          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  const Icon(Icons.visibility, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${livestream.viewerCount} watching',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),

          // Content info
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.white, size: 18),
                      SizedBox(width: 4),
                      Text(
                        'TECH TIPS',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  livestream.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'by ${livestream.authorName}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00A651),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Join',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveNowGrid() {
    final liveStreams = _livestreams.where((stream) => stream.isLive).toList();

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: liveStreams.length,
        itemBuilder: (context, index) {
          return Container(
            width: 200,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Thumbnail
                Image.asset(
                  index == 0
                      ? 'assets/images/harvest_stream.png'
                      : 'assets/images/farmers_market.png',
                  fit: BoxFit.cover,
                ),

                // Overlay gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),

                // Live indicator
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),

                // Content info
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 8,
                  child: Row(
                    children: [
                      // Channel icon/logo
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: index == 0 ? Colors.blue : Colors.grey,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          index == 0 ? Icons.check_circle : Icons.store,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Stream info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              index == 0 ? 'TECH TIPS' : 'FARMERS MARKET',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
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
        },
      ),
    );
  }

  Widget _buildFeaturedCreators() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _creators.length,
        itemBuilder: (context, index) {
          final creator = _creators[index];
          return Container(
            width: 70,
            margin: const EdgeInsets.only(right: 16),
            child: Column(
              children: [
                // Avatar - Use the proper creator avatar image path
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF00A651),
                      width: 2,
                    ),
                    image: DecorationImage(
                      image: AssetImage(
                        creator.avatarUrl,
                      ), // Use the avatarUrl property
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  creator.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Model Classes

class ShortVideo {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String videoUrl;
  final String authorName;
  int likes; // Changed to non-final so we can update it
  int comments; // Changed to non-final so we can update it
  final Duration duration;
  final List<String> tags;
  bool isLiked; // Added to track if the user has liked the video
  bool isSaved; // Added to track if the user has saved the video

  ShortVideo({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    this.videoUrl = '',
    required this.authorName,
    required this.likes,
    required this.comments,
    required this.duration,
    required this.tags,
    this.isLiked = false,
    this.isSaved = false,
  });
}

class Livestream {
  final String id;
  final String title;
  final String authorName;
  final String thumbnailUrl;
  final int viewerCount;
  final bool isLive;
  final DateTime scheduledTime;
  final List<String> tags;

  Livestream({
    required this.id,
    required this.title,
    required this.authorName,
    required this.thumbnailUrl,
    required this.viewerCount,
    required this.isLive,
    required this.scheduledTime,
    required this.tags,
  });
}

class Creator {
  final String id;
  final String name;
  final String avatarUrl;
  final int followers;

  Creator({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.followers,
  });
}
