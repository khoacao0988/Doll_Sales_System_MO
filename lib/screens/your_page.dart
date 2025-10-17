import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class YourPage extends StatelessWidget {
  const YourPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy Data
    final List<Map<String, String>> connectedItems = [
      {'doll': 'Cute Bunny', 'character': 'Warrior Princess', 'status': 'Using'},
      {'doll': 'Robo Dog', 'character': 'Space Explorer', 'status': 'Choose'},
      {'doll': 'Teddy Bear', 'character': 'Mage', 'status': 'Choose'},
      {'doll': 'Pikachu', 'character': 'Ninja', 'status': 'Choose'},
    ];

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search bar',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Grid View
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
                itemCount: connectedItems.length,
                itemBuilder: (context, index) {
                  final item = connectedItems[index];
                  return _buildGridItem(item['doll']!, item['character']!, item['status']!);
                },
              ),
            ),
          ],
        ),
      ),
       bottomNavigationBar: const CustomBottomNavBar(currentItem: NavItem.checklist), // Checklist is the second item
    );
  }

  Widget _buildGridItem(String dollName, String characterName, String status) {
    final isUsing = status == 'Using';
    return Card(
      color: Colors.grey[200],
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                  Container(color: Colors.white),
                  const Center(child: Divider(color: Colors.black, thickness: 1)),
                  const Positioned(
                    top: 10,
                    right: 10,
                    child: Text('Doll', style: TextStyle(color: Colors.black54, fontSize: 12)),
                  ),
                   const Positioned(
                    bottom: 10,
                    left: 10,
                    child: Text('Character', style: TextStyle(color: Colors.black54, fontSize: 12)),
                  ),
                ],
              ),
            ),
            Text('Option ${connectedItems.indexOf(connectedItems.firstWhere((element) => element['doll'] == dollName)) + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: isUsing ? Colors.grey[400] : Colors.white,
                foregroundColor: Colors.black,
                elevation: 0,
                minimumSize: const Size(100, 36),
              ),
              child: Text(status),
            ),
          ],
        ),
      ),
    );
  }
}

// A bit of a hack to get the index for the option number. 
// In a real app, the data model would have an ID.
final List<Map<String, String>> connectedItems = [
  {'doll': 'Cute Bunny', 'character': 'Warrior Princess', 'status': 'Using'},
  {'doll': 'Robo Dog', 'character': 'Space Explorer', 'status': 'Choose'},
  {'doll': 'Teddy Bear', 'character': 'Mage', 'status': 'Choose'},
  {'doll': 'Pikachu', 'character': 'Ninja', 'status': 'Choose'},
];
