import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'select_doll_page.dart';
import 'select_character_page.dart';

class CreateNewPage extends StatefulWidget {
  const CreateNewPage({super.key});

  @override
  State<CreateNewPage> createState() => _CreateNewPageState();
}

class _CreateNewPageState extends State<CreateNewPage> {
  // These will hold the selected items later
  String? selectedDoll;
  String? selectedCharacter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSelectionCard(
              context,
              title: 'Doll',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SelectDollPage())),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Icon(Icons.add, size: 40, color: Colors.black54),
            ),
            _buildSelectionCard(
              context,
              title: 'Character',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SelectCharacterPage())),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentItem: NavItem.add),
    );
  }

  Widget _buildSelectionCard(BuildContext context, {required String title, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap, // Use the passed onTap callback
      child: AspectRatio(
        aspectRatio: 1.0, // Makes it a square
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              title,
              style: const TextStyle(fontSize: 24, color: Colors.black54),
            ),
          ),
        ),
      ),
    );
  }
}
