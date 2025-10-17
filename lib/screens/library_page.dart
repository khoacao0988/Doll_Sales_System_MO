import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  bool _showDolls = true; // true for Dolls, false for Characters

  @override
  Widget build(BuildContext context) {
    // Dummy data
    final List<String> dolls = ['Cute Bunny', 'Robo Dog', 'Teddy Bear', 'Pikachu'];
    final List<String> characters = ['Warrior Princess', 'Space Explorer', 'Mage', 'Ninja'];

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
            // Toggle Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildToggleButton(context, 'Dolls', _showDolls),
                const SizedBox(width: 10),
                _buildToggleButton(context, 'Characters', !_showDolls),
              ],
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
                itemCount: _showDolls ? dolls.length : characters.length,
                itemBuilder: (context, index) {
                  final name = _showDolls ? dolls[index] : characters[index];
                  // The first item is 'Using'
                  final isUsing = index == 0;
                  return _buildGridItem(name, isUsing);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentItem: NavItem.library),
    );
  }

  Widget _buildToggleButton(BuildContext context, String text, bool isSelected) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _showDolls = text == 'Dolls';
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.grey[400] : Colors.grey[200],
        foregroundColor: Colors.black54,
        elevation: 0,
      ),
      child: Text(text),
    );
  }

  Widget _buildGridItem(String name, bool isUsing) {
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
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: isUsing ? Colors.grey[400] : Colors.white,
                foregroundColor: Colors.black,
                elevation: 0,
                minimumSize: const Size(100, 36),
              ),
              child: Text(isUsing ? 'Using' : 'Choose'),
            ),
          ],
        ),
      ),
    );
  }
}
