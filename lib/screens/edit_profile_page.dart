import 'package:flutter/material.dart';
import 'package:second/models/user.dart';
import 'package:second/services/session_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _phonesController;

  @override
  void initState() {
    super.initState();
    final User? user = SessionService().user;
    _usernameController = TextEditingController(text: user?.userName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phonesController = TextEditingController(text: user?.phones ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phonesController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Changes'),
          content: const Text('Are you sure you want to save these changes?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Save', style: TextStyle(color: Colors.blue)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      // TODO: Implement the API call to update the user profile.
      // For now, we just pop the screen.
      
      // Example of what the API call might look like:
      // final updatedEmail = _emailController.text;
      // final updatedPhone = _phonesController.text;
      // await authService.updateUserProfile(updatedEmail, updatedPhone);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile changes saved (simulation).'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          const SizedBox(height: 20),
          // Username field (read-only)
          _buildTextField(_usernameController, 'Username', Icons.person_outline, readOnly: true),
          const SizedBox(height: 16),
          // Email field (editable)
          _buildTextField(_emailController, 'Email', Icons.email_outlined),
          const SizedBox(height: 16),
          // Phone Number field (editable)
          _buildTextField(_phonesController, 'Phone Number', Icons.phone_outlined),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _saveChanges,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3F51B5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool readOnly = false}) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF3F51B5)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        // Make read-only fields visually distinct
        fillColor: readOnly ? Colors.grey[200] : Colors.grey[50],
      ),
    );
  }
}
