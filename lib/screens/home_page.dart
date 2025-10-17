import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'library_page.dart';
import 'your_page.dart';
import 'create_new_page.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            color: Colors.grey[300],
            child: const Center(child: Text('Logo web', style: TextStyle(fontSize: 10, color: Colors.black54))),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: const Text('User', style: TextStyle(fontSize: 12, color: Colors.black54)),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // Hero Section
          Container(
            color: Colors.grey[300],
            height: 200,
            width: double.infinity,
            child: const Center(
              child: Text(
                'Hero Section',
                style: TextStyle(fontSize: 24, color: Colors.black54),
              ),
            ),
          ),
          // Grid Menu
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(20),
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              children: <Widget>[
                _buildMenuCard(context, 'Create new'),
                _buildMenuCard(context, 'Library'),
                _buildMenuCard(context, 'Your'),
                _buildMenuCard(context, 'Profile'),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentItem: NavItem.home),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title) {
    return GestureDetector(
      onTap: () {
        if (title == 'Profile') {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const ProfilePage()),
            (route) => false,
          );
        } else if (title == 'Library') {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LibraryPage()),
            (route) => false,
          );
        } else if (title == 'Your') {
           Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const YourPage()),
            (route) => false,
          );
        } else if (title == 'Create new') {
           Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CreateNewPage()),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, color: Colors.black54),
          ),
        ),
      ),
    );
  }
}
