import 'package:flutter/material.dart';
import 'dart:async';
import '../models/auth_response.dart';
import '../services/session_service.dart';
import '../services/auth_service.dart';
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
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;
  late Future<List<String>> _imagesFuture;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _imagesFuture = _fetchImages();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startTimer(int pageCount) {
    if (pageCount <= 1) return; // Don't start timer if there's only one or zero images

    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      int nextPage = (_currentPage + 1) % pageCount;
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeIn,
        );
      }
    });
  }

  Future<List<String>> _fetchImages() async {
    try {
      final AuthResponse? auth = SessionService().authResponse;
      if (auth == null) throw Exception('Not authenticated');

      final allVariants = await _authService.getAllDollVariants(auth.accessToken);
      final images = allVariants.map((v) => v.image).where((img) => img != null && img.isNotEmpty).cast<String>().toList();
      
      if (mounted) {
        _startTimer(images.length);
      }
      return images;
    } catch (e) {
      print('Failed to fetch images: $e');
      return []; // Return empty list on error to show the default image
    }
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
      // CORRECTED: Using CustomScrollView with Slivers for better performance and layout structure.
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildImageCarousel(),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              children: <Widget>[
                _buildMenuCard(context, 'Create new', const Color(0xFFF44336)),
                _buildMenuCard(context, 'Library', const Color(0xFF4CAF50)),
                _buildMenuCard(context, 'Your', const Color(0xFF2196F3)),
                _buildMenuCard(context, 'Profile', const Color(0xFFFF9800)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentItem: NavItem.home), 
    );
  }

  Widget _buildImageCarousel() {
    return FutureBuilder<List<String>>(
      future: _imagesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return SizedBox(height: 200, width: double.infinity, child: Image.network('https://res.cloudinary.com/dygipvoal/image/upload/v1760081448/jirj9tgnupvsa0blmaua.jpg', fit: BoxFit.cover));
        }

        final images = snapshot.data!;
        return SizedBox(
          height: 200.0,
          child: PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) => Image.network(images[index], fit: BoxFit.cover, width: double.infinity),
          ),
        );
      },
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, Color color) {
    return Card(
      color: color,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () {
          if (title == 'Profile') Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ProfilePage()));
          else if (title == 'Library') Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LibraryPage()));
          else if (title == 'Your') Navigator.of(context).push(MaterialPageRoute(builder: (context) => const YourPage()));
          else if (title == 'Create new') Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CreateNewPage()));
        },
        borderRadius: BorderRadius.circular(20),
        child: Center(child: Text(title, style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold))),
      ),
    );
  }
}
