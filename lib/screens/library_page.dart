import 'package:flutter/material.dart';
import '../models/auth_response.dart';
import '../models/character.dart';
import '../models/doll_variant.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/session_service.dart';
import '../widgets/custom_bottom_nav_bar.dart';

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

  // For Search functionality
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final User? _user = SessionService().user;
  final AuthResponse? _authResponse = SessionService().authResponse;

  @override
  void initState() {
    super.initState();
    _detailedCharactersFuture = _fetchCharacterDetails();
    _detailedDollsFuture = _fetchDollDetails();

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

  Future<List<Character>> _fetchCharacterDetails() async {
    if (_user == null || _authResponse == null) throw Exception('User not authenticated.');
    final ownedCharacters = await _authService.getOwnedCharacters(_user!.userID, _authResponse!.accessToken);
    if (ownedCharacters.isEmpty) return [];
    final detailFutures = ownedCharacters.map((owned) => _authService.getCharacterDetails(owned.characterId, _authResponse!.accessToken));
    return await Future.wait(detailFutures);
  }

  Future<List<DollVariant>> _fetchDollDetails() async {
    if (_user == null || _authResponse == null) throw Exception('User not authenticated.');
    final ownedDolls = await _authService.getOwnedDolls(_user!.userID, _authResponse!.accessToken);
    if (ownedDolls.isEmpty) return [];
    final detailFutures = ownedDolls.map((owned) => _authService.getDollVariantDetails(owned.dollVariantId, _authResponse!.accessToken));
    return await Future.wait(detailFutures);
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF87CEEB); // Sky Blue

    return Scaffold(
      backgroundColor: Colors.grey[100], // Consistent background color
      appBar: AppBar(
        title: const Text('Library', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search in Library...',
                  prefixIcon: const Icon(Icons.search, color: primaryColor),
                  filled: true,
                  fillColor: Colors.white, // Changed for better contrast
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0)), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), // Changed for better contrast
              child: Row(
                children: [
                  Expanded(child: _buildToggleButton(context, 'Dolls', _showDolls, primaryColor)),
                  Expanded(child: _buildToggleButton(context, 'Characters', !_showDolls, primaryColor)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _showDolls ? _buildDollsGrid() : _buildCharactersGrid(),
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
          // Filter the list based on the search query
          final filteredCharacters = snapshot.data!.where((character) {
            return character.name.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

          if (filteredCharacters.isEmpty) {
            return const Center(child: Text('No matching characters found.'));
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.8),
            itemCount: filteredCharacters.length,
            itemBuilder: (context, index) {
              final character = filteredCharacters[index];
              return _buildGridItem(character.name, character.image, false, const Color(0xFF87CEEB));
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
          // Filter the list based on the search query
          final filteredDolls = snapshot.data!.where((doll) {
            return doll.name.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

          if (filteredDolls.isEmpty) {
            return const Center(child: Text('No matching dolls found.'));
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.8),
            itemCount: filteredDolls.length,
            itemBuilder: (context, index) {
              final doll = filteredDolls[index];
              return _buildGridItem(doll.name, doll.image, false, const Color(0xFF87CEEB));
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
        child: Center(child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : color))),
      ),
    );
  }

  Widget _buildGridItem(String name, String? imageUrl, bool isUsing, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), spreadRadius: 1, blurRadius: 8, offset: const Offset(0, 2))]
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(image: NetworkImage(imageUrl ?? 'https://placekitten.com/200/200'), fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
