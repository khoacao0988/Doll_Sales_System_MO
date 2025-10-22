import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_response.dart';
import '../models/owned_character.dart';
import '../models/character.dart';
import '../models/owned_doll.dart';
import '../models/doll_variant.dart';
import '../models/user.dart';

class AuthService {
  static const String _baseUrl = 'https://10.0.2.2:7152';

  Future<AuthResponse> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/Auth/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return authResponseFromJson(response.body);
    } else if (response.statusCode == 400 || response.statusCode == 401) {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Invalid username or password');
    } else {
      throw Exception('Failed to login. Status code: ${response.statusCode}');
    }
  }

  Future<User> getUserDetailsById(int userId, String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/User/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load user details. Status code: ${response.statusCode}');
    }
  }

  Future<List<OwnedCharacter>> getOwnedCharacters(int userId, String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/UserCharacter/user/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return ownedCharacterFromJson(response.body);
    } else {
      throw Exception('Failed to load owned characters. Status code: ${response.statusCode}');
    }
  }

  Future<Character> getCharacterDetails(int characterId, String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/Character/$characterId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return characterFromJson(response.body);
    } else {
      throw Exception('Failed to load character details. Status code: ${response.statusCode}');
    }
  }

  Future<List<OwnedDoll>> getOwnedDolls(int userId, String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/OwnedDoll/user/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return ownedDollFromJson(response.body);
    } else {
      throw Exception('Failed to load owned dolls. Status code: ${response.statusCode}');
    }
  }

  Future<DollVariant> getDollVariantDetails(int dollVariantId, String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/DollVariant/$dollVariantId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return dollVariantFromJson(response.body);
    } else {
      throw Exception('Failed to load doll variant details. Status code: ${response.statusCode}');
    }
  }
}
