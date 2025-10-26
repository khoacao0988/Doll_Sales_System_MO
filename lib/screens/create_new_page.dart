import 'package:flutter/material.dart';
import 'package:second/screens/select_character_page.dart';
import 'package:second/screens/select_doll_page.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class CreateNewPage extends StatelessWidget {
  const CreateNewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Create New', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildOptionCard(
                  context,
                  'Connect Doll to Character',
                  'Create a new link between a doll and a character',
                  Icons.link,
                  Colors.blue,
                  () {
                    // Navigate to a page to select a doll first
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SelectDollPage()));
                  },
                ),
                const SizedBox(height: 20),
                _buildOptionCard(
                  context,
                  'Manage Your Connections',
                  'View, edit, or remove existing connections',
                  Icons.list_alt,
                  Colors.green,
                  () {
                    // You can navigate to the 'Your' page or a dedicated management page
                  },
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const CustomBottomNavBar(currentItem: NavItem.add));
  }

  Widget _buildOptionCard(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
