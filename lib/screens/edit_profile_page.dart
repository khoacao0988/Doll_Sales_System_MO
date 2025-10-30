import 'package:flutter/material.dart';
import 'package:second/models/auth_response.dart';
import 'package:second/models/user.dart';
import 'package:second/services/auth_service.dart';
import 'package:second/services/session_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _authService = AuthService();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _phonesController;
  late TextEditingController _fullNameController;
  late TextEditingController _ageController;

  @override
  void initState() {
    super.initState();
    final User? user = SessionService().user;
    _usernameController = TextEditingController(text: user?.userName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phonesController = TextEditingController(text: user?.phones ?? '');
    _fullNameController = TextEditingController(text: user?.fullName ?? '');
    // Convert age to string for the text field
    _ageController = TextEditingController(text: user?.age?.toString() ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phonesController.dispose();
    _fullNameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Changes'),
        content: const Text('Are you sure you want to save these changes?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Save', style: TextStyle(color: Colors.blue))),
        ],
      ),
    );

    if (confirm != true) return;

    final AuthResponse? auth = SessionService().authResponse;
    final User? currentUser = SessionService().user;
    if (auth == null || currentUser == null) return;

    final updateData = {
      'fullName': _fullNameController.text,
      'phones': _phonesController.text,
      'email': _emailController.text,
      'age': int.tryParse(_ageController.text) ?? currentUser.age,
    };

    try {
      final updatedUser = await _authService.updateUserProfile(currentUser.userID, auth.accessToken, updateData);
      // Update the session with the new user data
      SessionService().updateUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.of(context).pop()),
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)], begin: Alignment.topLeft, end: Alignment.bottomRight))),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          const SizedBox(height: 20),
          _buildTextField(_usernameController, 'Username', Icons.person_outline, readOnly: true),
          const SizedBox(height: 16),
          _buildTextField(_fullNameController, 'Full Name', Icons.badge_outlined),
          const SizedBox(height: 16),
          _buildTextField(_emailController, 'Email', Icons.email_outlined),
          const SizedBox(height: 16),
          _buildTextField(_phonesController, 'Phone Number', Icons.phone_outlined),
          const SizedBox(height: 16),
          _buildTextField(_ageController, 'Age', Icons.cake_outlined, keyboardType: TextInputType.number),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _saveChanges,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3F51B5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool readOnly = false, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF3F51B5)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: readOnly ? Colors.grey[200] : Colors.grey[50],
      ),
    );
  }
}
