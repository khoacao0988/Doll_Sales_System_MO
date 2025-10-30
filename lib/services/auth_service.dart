import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_response.dart';
import '../models/owned_character.dart';
import '../models/character.dart';
import '../models/owned_doll.dart';
import '../models/doll_variant.dart';
import '../models/doll_character_link.dart';
import '../models/user.dart';
import '../models/user_character.dart';

class AuthService {
  static const String _baseUrl = 'https://dollaistore-api-dxdggjazgpckh2cc.japaneast-01.azurewebsites.net';
  static const Duration _timeout = Duration(seconds: 30);

  Future<AuthResponse> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    ).timeout(_timeout);
    if (response.statusCode == 200) {
      return authResponseFromJson(response.body);
    } else {
      throw Exception('Failed to login. Status code: ${response.statusCode}');
    }
  }

  Future<User> getUserDetailsById(int userId, String token) async {
    final response = await http.get(Uri.parse('$_baseUrl/api/users/$userId'), headers: {'Authorization': 'Bearer $token'}).timeout(_timeout);
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return User.fromJson(jsonData['data']);
    } else {
      throw Exception('Failed to load user details. Status code: ${response.statusCode}');
    }
  }

  // New method to update user profile
  Future<User> updateUserProfile(int userId, String token, Map<String, dynamic> data) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl/api/users/$userId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    ).timeout(_timeout);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return User.fromJson(jsonData['data']);
    } else {
      throw Exception('Failed to update profile. Status code: ${response.statusCode}');
    }
  }

  Future<List<OwnedCharacter>> getOwnedCharacters(int userId, String token) async {
    final response = await http.get(Uri.parse('$_baseUrl/api/user-characters/users/$userId'), headers: {'Authorization': 'Bearer $token'}).timeout(_timeout);
    if (response.statusCode == 200) {
      return ownedCharacterFromJson(response.body);
    } else {
      throw Exception('Failed to load owned characters. Status code: ${response.statusCode}');
    }
  }
  
  Future<List<UserCharacter>> getActiveUserCharacters(int userId, String token) async {
    final response = await http.get(Uri.parse('$_baseUrl/api/user-characters/users/$userId/active'), headers: {'Authorization': 'Bearer $token'}).timeout(_timeout);
    if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> characterList = jsonData['data'] ?? [];
        return List<UserCharacter>.from(characterList.map((x) => UserCharacter.fromJson(x)));
    } else {
      throw Exception('Failed to load active characters. Status code: ${response.statusCode}');
    }
  }

  Future<Character> getCharacterDetails(int characterId, String token) async {
    final response = await http.get(Uri.parse('$_baseUrl/api/characters/$characterId'), headers: {'Authorization': 'Bearer $token'}).timeout(_timeout);
    if (response.statusCode == 200) {
      return characterFromJson(response.body);
    } else {
      throw Exception('Failed to load character details. Status code: ${response.statusCode}');
    }
  }

  Future<List<OwnedDoll>> getOwnedDolls(int userId, String token) async {
    final response = await http.get(Uri.parse('$_baseUrl/api/owned-dolls/users/$userId'), headers: {'Authorization': 'Bearer $token'}).timeout(_timeout);
    if (response.statusCode == 200) {
      return ownedDollFromJson(response.body);
    } else {
      throw Exception('Failed to load owned dolls. Status code: ${response.statusCode}');
    }
  }

  Future<DollVariant> getDollVariantDetails(int dollVariantId, String token) async {
    final response = await http.get(Uri.parse('$_baseUrl/api/doll-variants/$dollVariantId'), headers: {'Authorization': 'Bearer $token'}).timeout(_timeout);
    if (response.statusCode == 200) {
      return dollVariantFromJson(response.body);
    } else {
      throw Exception('Failed to load doll variant details. Status code: ${response.statusCode}');
    }
  }

  Future<List<DollVariant>> getAllDollVariants(String token) async {
    final response = await http.get(Uri.parse('$_baseUrl/api/doll-variants?pageSize=100'), headers: {'Authorization': 'Bearer $token'}).timeout(_timeout);
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final List<dynamic> dollList = jsonData['items'] ?? [];
      return List<DollVariant>.from(dollList.map((x) => DollVariant.fromJson(x)));
    } else {
      throw Exception('Failed to load all doll variants. Status code: ${response.statusCode}');
    }
  }

  Future<DollCharacterLink?> getDollCharacterLink(int ownedDollId, String token) async {
    final response = await http.get(Uri.parse('$_baseUrl/api/doll-character-links/owned-dolls/$ownedDollId'), headers: {'Authorization': 'Bearer $token'}).timeout(_timeout);
    if (response.statusCode == 200) {
      return dollCharacterLinkFromJson(response.body);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to check doll link status. Status code: ${response.statusCode}');
    }
  }

  Future<OwnedDoll> getSingleOwnedDoll(int ownedDollId, String token) async {
    final response = await http.get(Uri.parse('$_baseUrl/api/owned-dolls/$ownedDollId'), headers: {'Authorization': 'Bearer $token'}).timeout(_timeout);
    if (response.statusCode == 200) {
      return singleOwnedDollFromJson(response.body);
    } else {
      throw Exception('Failed to load owned doll. Status code: ${response.statusCode}');
    }
  }
  
  Future<OwnedDoll> getOwnedDollBySerial(String serialCode, String token) async {
    final response = await http.get(Uri.parse('$_baseUrl/api/owned-dolls/serial-code/$serialCode'), headers: {'Authorization': 'Bearer $token'}).timeout(_timeout);
    if (response.statusCode == 200) {
      return singleOwnedDollFromJson(response.body);
    } else {
      throw Exception('Failed to find doll by serial code. Status code: ${response.statusCode}');
    }
  }

  Future<UserCharacter> getSingleUserCharacter(int userCharacterId, String token) async {
    final response = await http.get(Uri.parse('$_baseUrl/api/user-characters/$userCharacterId'), headers: {'Authorization': 'Bearer $token'}).timeout(_timeout);
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return UserCharacter.fromJson(jsonData['data']);
    } else {
      throw Exception('Failed to load user character. Status code: ${response.statusCode}');
    }
  }

  Future<void> deleteDollCharacterLink(int linkId, String token) async {
    final response = await http.delete(Uri.parse('$_baseUrl/api/doll-character-links/$linkId'), headers: {'Authorization': 'Bearer $token'}).timeout(_timeout);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete connection. Status code: ${response.statusCode}');
    }
  }
  
  Future<void> bindDollToCharacter(int ownedDollId, int userCharacterId, String token) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/doll-character-links'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'ownedDollID': ownedDollId,
        'userCharacterID': userCharacterId,
        'boundAt': DateTime.now().toIso8601String(),
        'note': 'Created from app'
      }),
    ).timeout(_timeout);
    if (response.statusCode != 200 && response.statusCode != 201) {
      try {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['message'] ?? errorBody.toString();
        throw Exception('$errorMessage (Status code: ${response.statusCode})');
      } catch (_) {
        throw Exception('Failed to create connection. Status code: ${response.statusCode}. Response: ${response.body}');
      }
    }
  }
}
