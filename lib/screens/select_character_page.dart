import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class SelectCharacterPage extends StatelessWidget {
  const SelectCharacterPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy Data for available characters
    final List<String> availableCharacters = ['Captain Astro', 'Mystic Sorceress', 'Cyber Runner', 'Forest Guardian'];

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
                itemCount: availableCharacters.length,
                itemBuilder: (context, index) {
                  final characterName = availableCharacters[index];
                  return _buildGridItem(context, characterName);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentItem: NavItem.add),
    );
  }

  Widget _buildGridItem(BuildContext context, String name) {
    return Card(
      color: Colors.grey[200],
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Image placeholder
            AspectRatio(
              aspectRatio: 1.0,
              child: Container(
                color: Colors.white,
              ),
            ),
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            ElevatedButton(
              onPressed: () {
                // TODO: Pass the selected character back to the CreateNewPage
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 0,
                minimumSize: const Size(100, 36),
              ),
              child: const Text('Choose'),
            ),
          ],
        ),
      ),
    );
  }
}
