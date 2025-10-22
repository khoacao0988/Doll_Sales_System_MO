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
      return const Scaffold(
        body: Center(
          child: Text('Error: User not logged in.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
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
                  backgroundColor: const Color(0xFF3F51B5).withOpacity(0.1),
                  child: CircleAvatar(
                    radius: 65,
                    child: Text(user.userName.substring(0, 1).toUpperCase(), style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Colors.indigo)),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.camera_alt, color: const Color(0xFF3F51B5), size: 22),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 50),
          _buildInfoField(context, 'Username', user.userName, Icons.person_outline),
          const SizedBox(height: 16),
          _buildInfoField(context, 'Email', user.email, Icons.email_outlined),
          const SizedBox(height: 16),
          _buildInfoField(context, 'Role', user.role, Icons.security_outlined),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            icon: const Icon(Icons.edit_outlined, size: 20),
            label: const Text('Edit Profile'),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const EditProfilePage()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3F51B5),
              foregroundColor: Colors.white,
              elevation: 2,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
             icon: const Icon(Icons.logout, size: 20, color: Colors.redAccent),
            label: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
            onPressed: () {
              SessionService().clearSession();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (Route<dynamic> route) => false,
              );
            },
             style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: Colors.red.shade100),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentItem: NavItem.profile),
    );
  }

  Widget _buildInfoField(BuildContext context, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200)
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[400]),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
