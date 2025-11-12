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
    const skyBlueColor = Color(0xFF87CEEB);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Your Connections', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: skyBlueColor, // Changed to sky blue
        elevation: 0,
        automaticallyImplyLeading: false,
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
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      clipBehavior: Clip.antiAlias, // Ensures the content respects the rounded corners
      child: Stack(
        children: [
          // 1. Doll Image (Main background)
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              info.dollDetails.image ?? '',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.error, color: Colors.grey, size: 40),
              ),
            ),
          ),

          // 2. Gradient overlay for text readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent, Colors.black.withOpacity(0.6)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),
          
          // 3. Doll Name (Bottom Left)
          Positioned(
            bottom: 10,
            left: 12,
            right: 80, // Leave space for the disconnect button
            child: Text(
              info.dollDetails.name,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, shadows: [Shadow(blurRadius: 2, color: Colors.black87)]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // 4. AI Character Info (Top Right)
          Positioned(
            top: 10,
            right: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4, spreadRadius: 1)],
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(info.characterDetails.image ?? ''),
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    info.characterDetails.name,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          // 5. Disconnect Button
          Positioned(
            bottom: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.link_off, color: Colors.white),
              tooltip: 'Disconnect',
              onPressed: () => _disconnect(info.linkId),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withOpacity(0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
