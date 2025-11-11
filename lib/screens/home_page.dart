import 'package:flutter/material.dart';
import 'dart:async';
import 'package:video_player/video_player.dart';
import '../services/session_service.dart';
import 'profile_page.dart';
import 'library_page.dart';
import 'your_page.dart';
import 'create_new_page.dart';
import 'notification_page.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // For Video Player
  late VideoPlayerController _videoController;

  // For Animated Background
  Timer? _backgroundTimer;
  Alignment _begin = Alignment.topLeft;
  Alignment _end = Alignment.bottomRight;
  final List<Color> _gradientColors = [
    Colors.grey[100]!,
    Colors.lightBlue[50]!,
    Colors.purple[50]!,
  ];
  int _colorIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialize Video Player
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse('https://res.cloudinary.com/dygipvoal/video/upload/v1762022212/myhc16ricbztewdpzjcg.mp4'),
    )..initialize().then((_) {
        // CORRECTED: Mute the video by setting volume to 0
        _videoController.setVolume(0.0);
        _videoController.setLooping(true);
        _videoController.play();
        setState(() {});
      });

    _startBackgroundAnimation();
  }

  void _startBackgroundAnimation() {
    _backgroundTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        _colorIndex = (_colorIndex + 1) % _gradientColors.length;
        _begin = _getRandomAlignment();
        _end = _getRandomAlignment();
      });
    });
  }

  Alignment _getRandomAlignment() {
    final alignments = [Alignment.topLeft, Alignment.topRight, Alignment.bottomLeft, Alignment.bottomRight, Alignment.center, Alignment.centerLeft, Alignment.centerRight];
    return alignments[DateTime.now().microsecond % alignments.length];
  }

  @override
  void dispose() {
    _videoController.dispose();
    _backgroundTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userName = SessionService().user?.userName ?? 'User';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Home', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)], begin: Alignment.topLeft, end: Alignment.bottomRight))),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none_outlined, color: Colors.white), onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const NotificationPage()))),
          Padding(padding: const EdgeInsets.only(right: 12.0, left: 8.0), child: CircleAvatar(backgroundColor: Colors.white, child: Text(userName.isNotEmpty ? userName.substring(0, 1).toUpperCase() : 'U', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6A11CB))))),
        ],
      ),
      body: Stack(
        children: [
          // Animated Background
          AnimatedContainer(
            duration: const Duration(seconds: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: _begin,
                end: _end,
                colors: [_gradientColors[_colorIndex], _gradientColors[(_colorIndex + 1) % _gradientColors.length]],
              ),
            ),
          ),
          // Main Content
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildVideoPlayer()),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverGrid.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  children: <Widget>[
                    _buildMenuCard(context, 'Create new', Icons.add_circle_outline, const Color(0xFF4A90E2)),
                    _buildMenuCard(context, 'Library', Icons.library_books_outlined, const Color(0xFF50E3C2)),
                    _buildMenuCard(context, 'Your Dolls', Icons.smart_toy_outlined, const Color(0xFF7B61FF)),
                    _buildMenuCard(context, 'Profile', Icons.person_outline, const Color(0xFFF5A623)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentItem: NavItem.home),
    );
  }

  Widget _buildVideoPlayer() {
    return SizedBox(
      height: 200.0,
      width: double.infinity,
      child: _videoController.value.isInitialized
          ? AspectRatio(
              aspectRatio: _videoController.value.aspectRatio,
              child: VideoPlayer(_videoController),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color) {
    return Card(
      color: color,
      elevation: 8,
      shadowColor: color.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () {
          if (title == 'Profile') Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ProfilePage()));
          else if (title == 'Library') Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LibraryPage()));
          else if (title == 'Your Dolls') Navigator.of(context).push(MaterialPageRoute(builder: (context) => const YourPage()));
          else if (title == 'Create new') Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CreateNewPage()));
        },
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.white),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
