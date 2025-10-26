import 'package:flutter/material.dart';
import 'dart:async';
import '../models/auth_response.dart';
import '../models/character.dart';
import '../models/doll_variant.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/session_service.dart';
import '../widgets/custom_bottom_nav_bar.dart';

// Helper class to hold the full details of a linked pair
class FullLinkedInfo {
  final int linkId;
  final DollVariant dollDetails;
  final Character characterDetails;

  FullLinkedInfo({required this.linkId, required this.dollDetails, required this.characterDetails});
}

class YourPage extends StatefulWidget {
  const YourPage({super.key});

  @override
  State<YourPage> createState() => _YourPageState();
}

class _YourPageState extends State<YourPage> {
  late Future<List<FullLinkedInfo>> _linkedInfoFuture;
  final AuthService _authService = AuthService();

  final User? _user = SessionService().user;
  final AuthResponse? _authResponse = SessionService().authResponse;

  @override
  void initState() {
    super.initState();
    _linkedInfoFuture = _fetchFullLinkedInfo();
  }

  Future<List<FullLinkedInfo>> _fetchFullLinkedInfo() async {
    if (_user == null || _authResponse == null) throw Exception('User not authenticated.');

    final ownedDolls = await _authService.getOwnedDolls(_user!.userID, _authResponse!.accessToken);
    if (ownedDolls.isEmpty) return [];

    List<FullLinkedInfo> linkedPairs = [];

    for (var ownedDoll in ownedDolls) {
      final link = await _authService.getDollCharacterLink(ownedDoll.ownedDollId, _authResponse!.accessToken);

      if (link != null && link.isActive) {
        final userCharacter = await _authService.getSingleUserCharacter(link.userCharacterID, _authResponse!.accessToken);

        final results = await Future.wait([
          _authService.getDollVariantDetails(ownedDoll.dollVariantId, _authResponse!.accessToken),
          _authService.getCharacterDetails(userCharacter.characterID, _authResponse!.accessToken),
        ]);

        final dollDetails = results[0] as DollVariant;
        final characterDetails = results[1] as Character;

        linkedPairs.add(FullLinkedInfo(
          linkId: link.linkID,
          dollDetails: dollDetails,
          characterDetails: characterDetails,
        ));
      }
    }

    return linkedPairs;
  }

  void _disconnect(int linkId) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Disconnect'),
          content: const Text('Are you sure you want to disconnect this pair?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Disconnect', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await _authService.deleteDollCharacterLink(linkId, _authResponse!.accessToken);
        setState(() {
          _linkedInfoFuture = _fetchFullLinkedInfo();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connection removed successfully.'), backgroundColor: Colors.green),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove connection: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Your Connections', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
      body: FutureBuilder<List<FullLinkedInfo>>(
        future: _linkedInfoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text('Error: ${snapshot.error}', textAlign: TextAlign.center)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No active connections found.'));
          } else {
            final pairs = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: pairs.length,
              itemBuilder: (context, index) {
                return _buildConnectionCard(pairs[index]);
              },
            );
          }
        },
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentItem: NavItem.checklist),
    );
  }

  Widget _buildConnectionCard(FullLinkedInfo info) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Doll Image (bottom left half)
            ClipPath(
              clipper: DiagonalClipper(isTopRight: false),
              child: Image.network(
                info.dollDetails.image ?? '',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(color: Colors.white),
              ),
            ),
            // AI Character Image (top right half)
            ClipPath(
              clipper: DiagonalClipper(isTopRight: true),
              child: Image.network(
                info.characterDetails.image ?? '',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(color: Colors.green),
              ),
            ),
            // Names Overlay
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'AI: ${info.characterDetails.name}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, shadows: [Shadow(blurRadius: 2, color: Colors.black54)]),
                  ),
                  Text(
                    'Doll: ${info.dollDetails.name}',
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16, shadows: [Shadow(blurRadius: 2, color: Colors.white70)]),
                  ),
                ],
              ),
            ),
            // Disconnect Button
            Positioned(
              bottom: 8,
              right: 8,
              child: Material(
                color: Colors.transparent,
                child: IconButton(
                  icon: const Icon(Icons.link_off, color: Colors.white),
                  tooltip: 'Disconnect',
                  onPressed: () => _disconnect(info.linkId),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// CORRECTED Custom Clipper for the diagonal image effect
class DiagonalClipper extends CustomClipper<Path> {
  final bool isTopRight;

  DiagonalClipper({required this.isTopRight});

  @override
  Path getClip(Size size) {
    final path = Path();
    if (isTopRight) {
      // Creates a triangular path for the top-right half.
      path.moveTo(0, 0); // Start at top-left
      path.lineTo(size.width, 0); // Go to top-right
      path.lineTo(size.width, size.height); // Go to bottom-right
      path.close(); // Automatically draws back to the start, creating a triangle
    } else {
      // Creates a triangular path for the bottom-left half.
      path.moveTo(0, 0); // Start at top-left
      path.lineTo(0, size.height); // Go to bottom-left
      path.lineTo(size.width, size.height); // Go to bottom-right
      path.close(); // Automatically draws back to the start, creating a triangle
    }
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
