import 'package:flutter/material.dart';
import 'dart:async';
import 'package:second/screens/select_character_page.dart';
import '../models/auth_response.dart';
import '../models/doll_variant.dart';
import '../models/owned_doll.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/session_service.dart';

// Helper class to hold detailed info for an available doll
class AvailableDollInfo {
  final int ownedDollId;
  final String serialCode;
  final DollVariant details;

  AvailableDollInfo({required this.ownedDollId, required this.serialCode, required this.details});
}

class SelectDollPage extends StatefulWidget {
  const SelectDollPage({super.key});

  @override
  State<SelectDollPage> createState() => _SelectDollPageState();
}

class _SelectDollPageState extends State<SelectDollPage> {
  late Future<List<AvailableDollInfo>> _availableDollsFuture;
  final AuthService _authService = AuthService();

  final User? _user = SessionService().user;
  final AuthResponse? _authResponse = SessionService().authResponse;

  @override
  void initState() {
    super.initState();
    _availableDollsFuture = _fetchAvailableDolls();
  }

  // CORRECTED: Logic now also checks if an existing link is inactive
  Future<List<AvailableDollInfo>> _fetchAvailableDolls() async {
    if (_user == null || _authResponse == null) throw Exception('User not authenticated.');

    final allOwnedDolls = await _authService.getOwnedDolls(_user!.userID, _authResponse!.accessToken);
    if (allOwnedDolls.isEmpty) return [];

    final List<Future<AvailableDollInfo?>> futureAvailableDolls = allOwnedDolls.map((ownedDoll) async {
      final link = await _authService.getDollCharacterLink(ownedDoll.ownedDollId, _authResponse!.accessToken);
      
      // A doll is considered available if there is no link OR the existing link is not active.
      if (link == null || !link.isActive) {
        final dollDetails = await _authService.getDollVariantDetails(ownedDoll.dollVariantId, _authResponse!.accessToken);
        final fullOwnedDoll = await _authService.getSingleOwnedDoll(ownedDoll.ownedDollId, _authResponse!.accessToken);

        return AvailableDollInfo(
          ownedDollId: ownedDoll.ownedDollId,
          serialCode: fullOwnedDoll.serialCode,
          details: dollDetails,
        );
      }
      return null; // This doll has an active link, so we ignore it.
    }).toList();

    final allDolls = await Future.wait(futureAvailableDolls);
    return allDolls.where((doll) => doll != null).cast<AvailableDollInfo>().toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Choose an Available Doll', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
        child: FutureBuilder<List<AvailableDollInfo>>(
          future: _availableDollsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No available dolls found.'));
            } else {
              final availableDolls = snapshot.data!;
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: availableDolls.length,
                itemBuilder: (context, index) {
                  final dollInfo = availableDolls[index];
                  return _buildGridItem(context, dollInfo);
                },
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, AvailableDollInfo info) {
    return GestureDetector(
      onTap: () {
        // Navigate to the next step, passing the chosen ownedDollID
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => SelectCharacterPage(ownedDollId: info.ownedDollId),
        ));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 2))]
        ),
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
                      image: NetworkImage(info.details.image ?? 'https://via.placeholder.com/200'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(info.details.name, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(info.serialCode, style: TextStyle(color: Colors.grey[600], fontSize: 12), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
