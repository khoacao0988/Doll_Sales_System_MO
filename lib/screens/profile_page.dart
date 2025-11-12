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
    const skyBlueColor = Color(0xFF87CEEB);

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Error: User not logged in.')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: skyBlueColor, // Changed to sky blue
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('My Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 2, color: Colors.black45)])),
              background: Container(
                color: skyBlueColor, // Set a solid background color
                child: Image.network(
                  'https://res.cloudinary.com/dygipvoal/image/upload/v1762391998/di1z5bqlmnimy5knpjdv.png',
                  fit: BoxFit.cover,
                  color: Colors.black.withOpacity(0.3),
                  colorBlendMode: BlendMode.darken,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0), // Adjusted padding
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildInfoSection(user, skyBlueColor),
                const SizedBox(height: 30),
                _buildActionButtons(context, skyBlueColor),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentItem: NavItem.profile),
    );
  }

  Widget _buildInfoSection(User user, Color themeColor) {
    return Column(
      children: [
        _buildInfoField('Username', user.userName, Icons.person_outline, themeColor),
        const SizedBox(height: 16),
        if (user.fullName != null && user.fullName!.isNotEmpty) ...[
          _buildInfoField('Full Name', user.fullName!, Icons.badge_outlined, themeColor),
          const SizedBox(height: 16),
        ],
        _buildInfoField('Email', user.email, Icons.email_outlined, themeColor),
        const SizedBox(height: 16),
        if (user.phones != null && user.phones!.isNotEmpty) ...[
           _buildInfoField('Phone', user.phones!, Icons.phone_outlined, themeColor),
        ],
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, Color themeColor) {
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
              backgroundColor: themeColor,
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: themeColor.withOpacity(0.4),
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

  Widget _buildInfoField(String label, String value, IconData icon, Color themeColor) {
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
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: themeColor.withOpacity(0.7)),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
