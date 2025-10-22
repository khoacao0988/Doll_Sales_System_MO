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

  final User? _user = SessionService().user;
  final AuthResponse? _authResponse = SessionService().authResponse;

  @override
  void initState() {
    super.initState();
    _detailedCharactersFuture = _fetchCharacterDetails();
    _detailedDollsFuture = _fetchDollDetails();
  }

  Future<List<Character>> _fetchCharacterDetails() async {
    if (_user == null || _authResponse == null) {
      throw Exception('User not authenticated.');
    }
    final ownedCharacters = await _authService.getOwnedCharacters(_user!.userID, _authResponse!.accessToken);
    if (ownedCharacters.isEmpty) return [];
    final detailFutures = ownedCharacters.map((owned) {
      return _authService.getCharacterDetails(owned.characterId, _authResponse!.accessToken);
    }).toList();
    return await Future.wait(detailFutures);
  }

  Future<List<DollVariant>> _fetchDollDetails() async {
    if (_user == null || _authResponse == null) {
      throw Exception('User not authenticated.');
    }
    final ownedDolls = await _authService.getOwnedDolls(_user!.userID, _authResponse!.accessToken);
    if (ownedDolls.isEmpty) return [];
    final detailFutures = ownedDolls.map((owned) {
      return _authService.getDollVariantDetails(owned.dollVariantId, _authResponse!.accessToken);
    }).toList();
    return await Future.wait(detailFutures);
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF4CAF50); // Green

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Library', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search in Library...',
                  prefixIcon: const Icon(Icons.search, color: primaryColor),
                  filled: true,
                  fillColor: primaryColor.withOpacity(0.05),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(child: _buildToggleButton(context, 'Dolls', _showDolls, primaryColor)),
                  Expanded(child: _buildToggleButton(context, 'Characters', !_showDolls, primaryColor)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _showDolls
                ? _buildDollsGrid() 
                : _buildCharactersGrid(),
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
          final characters = snapshot.data!;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: characters.length,
            itemBuilder: (context, index) {
              final character = characters[index];
              return _buildGridItem(character.name, character.image, false, const Color(0xFF4CAF50));
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
          final dolls = snapshot.data!;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: dolls.length,
            itemBuilder: (context, index) {
              final doll = dolls[index];
              return _buildGridItem(doll.name, doll.image, false, const Color(0xFF4CAF50));
            },
          );
        }
      },
    );
  }

  Widget _buildToggleButton(BuildContext context, String text, bool isSelected, Color color) {
    return GestureDetector(
       onTap: () {
        setState(() {
          _showDolls = text == 'Dolls';
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
         decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem(String name, String? imageUrl, bool isUsing, Color color) {
    return Container(
       decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ]
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            AspectRatio(
              aspectRatio: 1.0,
              child: Container(
                 decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl ?? 'https://placekitten.com/200/200'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            ElevatedButton(
              onPressed: isUsing ? null : () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
                elevation: 0,
                minimumSize: const Size(100, 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(isUsing ? 'Using' : 'Choose'),
            ),
          ],
        ), 
      ),
    );
  }
}
