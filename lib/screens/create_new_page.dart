import 'package:flutter/material.dart';
import 'package:second/screens/qr_scanner_page.dart';
import 'package:second/screens/select_doll_page.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class CreateNewPage extends StatelessWidget {
  const CreateNewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[100], // Consistent background color
        appBar: AppBar(
          title: const Text('Create New', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildOptionCard(
                context,
                'Connect from List',
                'Select an available doll and character from your library.',
                Icons.link_rounded,
                Colors.blue,
                () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SelectDollPage()));
                },
              ),
              const SizedBox(height: 20),
              _buildOptionCard(
                context,
                'Connect by QR Code',
                'Scan a doll\'s QR code to start a new connection.',
                Icons.qr_code_scanner_rounded,
                Colors.deepPurple,
                () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const QRScannerPage()));
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar: const CustomBottomNavBar(currentItem: NavItem.add));
  }

  Widget _buildOptionCard(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.7), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, spreadRadius: 1, offset: const Offset(0, 4))]
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 5),
                  Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9))),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }
}
