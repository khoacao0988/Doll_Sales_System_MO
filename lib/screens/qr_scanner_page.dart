import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:second/screens/select_character_page.dart';
import '../models/auth_response.dart';
import '../services/auth_service.dart';
import '../services/session_service.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final AuthService _authService = AuthService();
  bool _isProcessing = false;

  void _handleQRCode(String serialCode) async {
    // Prevent multiple scans
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
    });

    final AuthResponse? auth = SessionService().authResponse;
    if (auth == null) {
      _showError('Authentication token not found. Please log in again.');
      return;
    }

    try {
      // 1. Find the owned doll by its serial code
      final ownedDoll = await _authService.getOwnedDollBySerial(serialCode, auth.accessToken);

      // 2. Check if this doll is already actively linked
      final link = await _authService.getDollCharacterLink(ownedDoll.ownedDollId, auth.accessToken);

      if (link != null && link.isActive) {
        // If it's already linked and active, show a message and stop.
        _showError('This doll is already connected to a character.');
      } else {
        // If not linked or the link is inactive, proceed to the character selection page.
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => SelectCharacterPage(ownedDollId: ownedDoll.ownedDollId),
        ));
      }
    } catch (e) {
      _showError('Error processing QR code: ${e.toString()}');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
    // Allow for another scan after a delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const skyBlueColor = Color(0xFF87CEEB);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Doll QR Code', style: TextStyle(color: Colors.white)),
        backgroundColor: skyBlueColor, // Changed to sky blue
        elevation: 0,
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String? code = barcodes.first.rawValue;
                if (code != null) {
                  _handleQRCode(code);
                }
              }
            },
          ),
          // Scanner overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
