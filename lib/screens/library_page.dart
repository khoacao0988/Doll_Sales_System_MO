import 'package:flutter/material.dart';
import '../models/character.dart';
import '../models/doll_variant.dart';
import '../services/auth_service.dart';
import '../services/session_service.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'chat_screen.dart'; // Import the new chat screen

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  bool _showDolls = true;
  late Future<List<Character>> _detailedCharactersFuture;
  late Future<List<DollVariant>> _detailedDollsFuture;
  final AuthService _authService = AuthService();

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final session = SessionService();
    if (session.user != null && session.authResponse != null) {
      _detailedCharactersFuture = _fetchCharacterDetails(session.user!.userID, session.authResponse!.accessToken);
      _detailedDollsFuture = _fetchDollDetails(session.user!.userID, session.authResponse!.accessToken);
    } else {
      // Handle not logged in case
      _detailedCharactersFuture = Future.value([]);
      _detailedDollsFuture = Future.value([]);
    }

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Character>> _fetchCharacterDetails(int userId, String token) async {
    final ownedCharacters = await _authService.getOwnedCharacters(userId, token);
    if (ownedCharacters.isEmpty) return [];
    final detailFutures = ownedCharacters.map((owned) => _authService.getCharacterDetails(owned.characterId, token));
    return await Future.wait(detailFutures);
  }

  Future<List<DollVariant>> _fetchDollDetails(int userId, String token) async {
    final ownedDolls = await _authService.getOwnedDolls(userId, token);
    if (ownedDolls.isEmpty) return [];
    final detailFutures = ownedDolls.map((owned) => _authService.getDollVariantDetails(owned.dollVariantId, token));
    return await Future.wait(detailFutures);
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF87CEEB); // Sky Blue

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Library', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor, // Changed to sky blue
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            final session = SessionService();
             if (session.user != null && session.authResponse != null) {
              _detailedCharactersFuture = _fetchCharacterDetails(session.user!.userID, session.authResponse!.accessToken);
              _detailedDollsFuture = _fetchDollDetails(session.user!.userID, session.authResponse!.accessToken);
            } 
          });
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search in Library...',
                      prefixIcon: const Icon(Icons.search, color: primaryColor),
                      filled: true,
                      fillColor: Colors.white,
                      border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0)), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Expanded(child: _buildToggleButton(context, 'Dolls', _showDolls, primaryColor)),
                        Expanded(child: _buildToggleButton(context, 'Characters', !_showDolls, primaryColor)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _showDolls ? _buildDollsGrid() : _buildCharactersGrid(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentItem: NavItem.library),
    );
  }

  Widget _buildCharactersGrid() {
    return FutureBuilder<List<Character>>(
      future: _detailedCharactersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No characters found.'));
        } else {
          final filteredCharacters = snapshot.data!.where((character) {
            return character.name.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

          if (filteredCharacters.isEmpty) {
            return const Center(child: Text('No matching characters found.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.8),
            itemCount: filteredCharacters.length,
            itemBuilder: (context, index) {
              final character = filteredCharacters[index];
              // CORRECTED: Pass the navigation logic to the onTap parameter
              return _buildGridItem(
                character.name,
                character.image,
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      characterId: character.characterId.toString(),
                      characterName: character.name,
                      characterImageUrl: character.image ?? '',
                    ),
                  ));
                },
              );
            },
          );
        }
      },
    );
  }

  Widget _buildDollsGrid() {
    return FutureBuilder<List<DollVariant>>(
      future: _detailedDollsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No dolls found.'));
        } else {
          final filteredDolls = snapshot.data!.where((doll) {
            return doll.name.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

          if (filteredDolls.isEmpty) {
            return const Center(child: Text('No matching dolls found.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.8),
            itemCount: filteredDolls.length,
            itemBuilder: (context, index) {
              final doll = filteredDolls[index];
              // Dolls are not clickable for chat, so onTap is null
              return _buildGridItem(doll.name, doll.image, onTap: null);
            },
          );
        }
      },
    );
  }

  Widget _buildToggleButton(BuildContext context, String text, bool isSelected, Color color) {
    return GestureDetector(
      onTap: () {
        setState(() { _showDolls = text == 'Dolls'; });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: isSelected ? color : Colors.transparent, borderRadius: BorderRadius.circular(12)),
        child: Center(child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black54))),
      ),
    );
  }

  Widget _buildGridItem(String name, String? imageUrl, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Image.network(
                imageUrl ?? 'https://res.cloudinary.com/dygipvoal/image/upload/v1760081448/jirj9tgnupvsa0blmaua.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, color: Colors.grey, size: 40),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}
