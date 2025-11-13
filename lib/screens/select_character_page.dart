import 'package:flutter/material.dart';
import 'dart:async';
import 'package:second/screens/home_page.dart';
import '../models/auth_response.dart';
import '../models/character.dart';
import '../models/user_character.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/session_service.dart';

// Helper class to hold detailed info for an available character
class AvailableCharacterInfo {
  final int userCharacterId;
  final Character details;

  AvailableCharacterInfo({required this.userCharacterId, required this.details});
}

class SelectCharacterPage extends StatefulWidget {
  final int ownedDollId;

  const SelectCharacterPage({super.key, required this.ownedDollId});

  @override
  State<SelectCharacterPage> createState() => _SelectCharacterPageState();
}

class _SelectCharacterPageState extends State<SelectCharacterPage> {
  late Future<List<AvailableCharacterInfo>> _availableCharactersFuture;
  final AuthService _authService = AuthService();

  final User? _user = SessionService().user;
  final AuthResponse? _authResponse = SessionService().authResponse;

  @override
  void initState() {
    super.initState();
    _availableCharactersFuture = _fetchAvailableCharacters();
  }

  Future<List<AvailableCharacterInfo>> _fetchAvailableCharacters() async {
    if (_user == null || _authResponse == null) throw Exception('User not authenticated.');

    final activeUserChars = await _authService.getActiveUserCharacters(_user!.userID, _authResponse!.accessToken);
    if (activeUserChars.isEmpty) return [];

    final detailFutures = activeUserChars.map((userChar) async {
      final charDetails = await _authService.getCharacterDetails(userChar.characterID, _authResponse!.accessToken);
      return AvailableCharacterInfo(userCharacterId: userChar.userCharacterID, details: charDetails);
    });

    return await Future.wait(detailFutures);
  }

  void _connect(int userCharacterId) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Connection'),
          content: const Text('Are you sure you want to connect this doll and character?'),
          actions: <Widget>[
            TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(context).pop(false)),
            TextButton(
              child: const Text('Connect', style: TextStyle(color: Colors.green)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await _authService.bindDollToCharacter(widget.ownedDollId, userCharacterId, _authResponse!.accessToken);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connected successfully!'), backgroundColor: Colors.green),
        );
        // Navigate to the home page after successful connection
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to connect: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const skyBlueColor = Color(0xFF87CEEB);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Choose a Character', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: skyBlueColor, // Changed to sky blue
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<AvailableCharacterInfo>>(
          future: _availableCharactersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No available characters found.'));
            } else {
              final availableCharacters = snapshot.data!;
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: availableCharacters.length,
                itemBuilder: (context, index) {
                  final charInfo = availableCharacters[index];
                  return _buildGridItem(context, charInfo);
                },
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, AvailableCharacterInfo info) {
    return GestureDetector(
      onTap: () => _connect(info.userCharacterId),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 2))]),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(info.details.image ?? 'https://via.placeholder.com/201'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(info.details.name, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}
