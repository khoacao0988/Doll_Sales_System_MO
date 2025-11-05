import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/session_service.dart';
import 'login_page.dart';
import 'edit_profile_page.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = SessionService().user;

    if (user == null) {
      // This should ideally not happen if the app flow is correct
      return const Scaffold(
        body: Center(child: Text('Error: User not logged in.')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100], // Consistent background color
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
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
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
        children: <Widget>[
          const SizedBox(height: 20),
          _buildProfileHeader(user),
          const SizedBox(height: 30),
          _buildInfoSection(user),
          const SizedBox(height: 30),
          _buildActionButtons(context),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentItem: NavItem.profile),
    );
  }

  Widget _buildProfileHeader(User user) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: 70,
            backgroundColor: Colors.white,
            child: Text(
              user.userName.isNotEmpty ? user.userName.substring(0, 1).toUpperCase() : 'U',
              style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Color(0xFF3F51B5)),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 4,
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.grey[100], // Match background
              child: const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                child: Icon(Icons.camera_alt_outlined, color: Color(0xFF3F51B5), size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(User user) {
    return Column(
      children: [
        _buildInfoField('Username', user.userName, Icons.person_outline),
        const SizedBox(height: 16),
        _buildInfoField('Email', user.email, Icons.email_outlined),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.edit_outlined, size: 20),
            label: const Text('Edit Profile'),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const EditProfilePage()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3F51B5),
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: const Color(0xFF3F51B5).withOpacity(0.4),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.logout, size: 20),
            label: const Text('Logout'),
            onPressed: () {
              SessionService().clearSession();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (Route<dynamic> route) => false,
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade700,
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: Colors.white,
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoField(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF3F51B5).withOpacity(0.7)),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
            ],
          ),
        ],
      ),
    );
  }
}
