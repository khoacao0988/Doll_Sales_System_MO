import 'package:flutter/material.dart';

class SelectDollPage extends StatelessWidget {
  const SelectDollPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> availableDolls = ['Fluffy Cat', 'Sleepy Panda', 'Racing Car', 'Unicorn'];
    const Color primaryColor = Color(0xFF9C27B0); // Purple

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Choose a Doll', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(), // Just pop without a value
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search for a doll...',
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
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: availableDolls.length,
                itemBuilder: (context, index) {
                  final dollName = availableDolls[index];
                  return _buildGridItem(context, dollName, primaryColor);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, String name, Color color) {
    return Container(
       decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
            AspectRatio(
              aspectRatio: 1.0,
              child: Container(
                 decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  image: const DecorationImage(
                    image: NetworkImage('https://placekitten.com/200/200'), // Placeholder
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            ElevatedButton(
              onPressed: () {
                // Pass the selected doll's name back to the previous screen
                Navigator.of(context).pop(name);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size(100, 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Choose'),
            ),
          ],
        ),
      ),
    );
  }
}
