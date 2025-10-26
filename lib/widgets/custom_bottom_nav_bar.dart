import 'package:flutter/material.dart';
import '../screens/home_page.dart';
import '../screens/profile_page.dart';
import '../screens/library_page.dart';
import '../screens/your_page.dart';
import '../screens/create_new_page.dart';

enum NavItem { home, checklist, add, library, profile }

class CustomBottomNavBar extends StatelessWidget {
  final NavItem currentItem;

  const CustomBottomNavBar({
    super.key,
    required this.currentItem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomAppBar(
        color: Colors.transparent,
        elevation: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavItem(context, NavItem.home, Icons.home),
            _buildNavItem(context, NavItem.checklist, Icons.library_add_check),
            _buildNavItem(context, NavItem.add, Icons.add),
            _buildNavItem(context, NavItem.library, Icons.pets),
            _buildNavItem(context, NavItem.profile, Icons.person),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, NavItem item, IconData icon) {
    final isSelected = currentItem == item;

    if (item == NavItem.add) {
      return GestureDetector(
        onTap: () {
          if (isSelected) return;
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CreateNewPage()),
          );
        },
        child: CircleAvatar(
          backgroundColor: isSelected ? Colors.white : Colors.white70,
          child: const Icon(Icons.add, color: Color(0xFF6A11CB)),
        ),
      );
    }

    return IconButton(
      icon: Icon(icon, color: isSelected ? Colors.white : Colors.white70, size: isSelected ? 30 : 26),
      onPressed: () {
        if (isSelected) return;

        switch (item) {
          case NavItem.home:
             Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const HomePage()),
              (route) => false,
            );
            break;
          case NavItem.profile:
             Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const ProfilePage()),
              (route) => false,
            );
            break;
          case NavItem.library:
             Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LibraryPage()),
              (route) => false,
            );
            break;
          case NavItem.checklist:
             Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const YourPage()),
              (route) => false,
            );
            break;
          case NavItem.add:
            break;
        }
      },
    );
  }
}
