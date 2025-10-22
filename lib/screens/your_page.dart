import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class YourPage extends StatelessWidget {
  const YourPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF2196F3); // Blue

    final List<Map<String, String>> connectedItems = [
      {'doll': 'Cute Bunny', 'character': 'Warrior Princess', 'status': 'Using'},
      {'doll': 'Robo Dog', 'character': 'Space Explorer', 'status': 'Choose'},
      {'doll': 'Teddy Bear', 'character': 'Mage', 'status': 'Choose'},
      {'doll': 'Pikachu', 'character': 'Ninja', 'status': 'Choose'},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Your Connections', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
         automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search your connections...',
                  prefixIcon: const Icon(Icons.search, color: primaryColor),
                  filled: true,
                   fillColor: primaryColor.withOpacity(0.05),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Grid View
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: connectedItems.length,
              itemBuilder: (context, index) {
                final item = connectedItems[index];
                return _buildGridItem(item['doll']!, item['character']!, item['status']!, primaryColor, index + 1);
              },
            ),
          ],
        ),
      ),
       bottomNavigationBar: const CustomBottomNavBar(currentItem: NavItem.checklist),
    );
  }

  Widget _buildGridItem(String dollName, String characterName, String status, Color color, int optionNumber) {
    final isUsing = status == 'Using';
    return Container(
       decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isUsing ? color : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: isUsing ? color.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ]
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Image placeholder with diagonal text
            AspectRatio(
              aspectRatio: 1.0,
              child: Stack(
                children: [
                  Container(
                     decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const Center(child: Divider(color: Colors.grey, thickness: 1)),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Text('Doll', style: TextStyle(color: Colors.grey[700], fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                   Positioned(
                    bottom: 10,
                    left: 10,
                    child: Text('Character', style: TextStyle(color: Colors.grey[700], fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            Text('Option $optionNumber', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ElevatedButton(
              onPressed: isUsing ? null : () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                disabledBackgroundColor: color.withOpacity(0.5),
                elevation: 0,
                minimumSize: const Size(100, 36),
                 shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(status),
            ),
          ],
        ),
      ),
    );
  }
}
