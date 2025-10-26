import 'package:flutter/material.dart';
import '../services/session_service.dart';
import 'profile_page.dart';
import 'library_page.dart';
import 'your_page.dart';
import 'create_new_page.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userName = SessionService().user?.userName ?? 'User';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Home', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                userName.isNotEmpty ? userName.substring(0, 1).toUpperCase() : 'U',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6A11CB)),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Reverted to a single, static image
            SizedBox(
              height: 200,
              width: double.infinity,
              child: Image.network(
                'https://res.cloudinary.com/dygipvoal/image/upload/v1760081448/jirj9tgnupvsa0blmaua.jpg',
                fit: BoxFit.cover,
              ),
            ),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              padding: const EdgeInsets.all(20),
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              children: <Widget>[
                _buildMenuCard(context, 'Create new', const Color(0xFFF44336)),
                _buildMenuCard(context, 'Library', const Color(0xFF4CAF50)),
                _buildMenuCard(context, 'Your', const Color(0xFF2196F3)),
                _buildMenuCard(context, 'Profile', const Color(0xFFFF9800)),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentItem: NavItem.home), 
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, Color color) {
    return GestureDetector(
      onTap: () {
        if (title == 'Profile') {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ProfilePage()));
        } else if (title == 'Library') {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LibraryPage()));
        } else if (title == 'Your') {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const YourPage()));
        } else if (title == 'Create new') {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CreateNewPage()));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
           boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 3)),
          ],
        ),
        child: Center(
          child: Text(title, style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
