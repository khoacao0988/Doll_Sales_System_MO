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
  String? selectedDoll;
  String? selectedCharacter;
  final Color primaryColor = const Color(0xFF9C27B0); // Purple

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create New Connection', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            _buildSelectionCard(
              context,
              title: 'Doll',
              subtitle: selectedDoll ?? 'Tap to choose a doll',
              icon: Icons.smart_toy_outlined,
              onTap: () async {
                final result = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SelectDollPage()));
                if (result != null && result is String) {
                  setState(() {
                    selectedDoll = result;
                  });
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Icon(Icons.add_circle_outline, size: 40, color: primaryColor.withOpacity(0.5)),
            ),
            _buildSelectionCard(
              context,
              title: 'Character',
              subtitle: selectedCharacter ?? 'Tap to choose a character',
              icon: Icons.person_search_outlined,
              onTap: () async {
                final result = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SelectCharacterPage()));
                if (result != null && result is String) {
                  setState(() {
                    selectedCharacter = result;
                  });
                }
              },
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: (selectedDoll != null && selectedCharacter != null)
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: primaryColor,
                          content: Text('Success! Connected $selectedDoll with $selectedCharacter'),
                        ),
                      );
                      Future.delayed(const Duration(seconds: 2), () {
                        if (mounted) {
                           Navigator.of(context).pop();
                        }
                      });
                    }
                  : null, // Button is disabled if either is null
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('CREATE CONNECTION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentItem: NavItem.add),
    );
  }

  Widget _buildSelectionCard(BuildContext context, {required String title, required String subtitle, required IconData icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: primaryColor.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: primaryColor),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
