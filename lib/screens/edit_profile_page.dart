import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class EditProfilePage extends StatefulWidget {
  // REVERTED: No longer requires a user object.
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    // REVERTED: Using static data for initial values.
    _nameController = TextEditingController(text: 'character_doll_fan');
    _emailController = TextEditingController(text: 'myemail@email.com');
    _phoneController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF3F51B5); // Indigo

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
        children: <Widget>[
          const SizedBox(height: 20),
          Center(
            child: Stack(
              children: [
                 CircleAvatar(
                  radius: 70,
                  backgroundColor: primaryColor.withOpacity(0.1),
                  child: const CircleAvatar(
                    radius: 65,
                     backgroundImage: NetworkImage('https://placekitten.com/200/200'),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.camera_alt, color: primaryColor, size: 22),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 50),
          _buildTextField('Full Name', Icons.person_outline, primaryColor, _nameController),
          const SizedBox(height: 16),
          _buildTextField('Email', Icons.email_outlined, primaryColor, _emailController),
          const SizedBox(height: 16),
          _buildTextField('Phone Number', Icons.phone_outlined, primaryColor, _phoneController),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement Save Logic using the controllers' text
              Navigator.of(context).pop(); // Go back to profile page
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 2,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Go back to profile page
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.black54)),
          )
        ],
      ),
      // REVERTED: No longer passes user.
      bottomNavigationBar: const CustomBottomNavBar(currentItem: NavItem.profile),
    );
  }

  Widget _buildTextField(String hint, IconData icon, Color color, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: hint,
        prefixIcon: Icon(icon, color: color),
        labelStyle: TextStyle(color: Colors.grey[600]),
        filled: true,
        fillColor: color.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color),
        ),
      ),
    );
  }
}
