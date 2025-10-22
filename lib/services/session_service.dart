import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_response.dart';
import '../models/user.dart';

// A singleton class to manage the user's session data securely.
class SessionService {
  SessionService._internal();
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;

  final _secureStorage = const FlutterSecureStorage();

  // In-memory cache for faster access
  AuthResponse? _authResponse;
  User? _user;

  AuthResponse? get authResponse => _authResponse;
  User? get user => _user;

  // Keys for secure storage
  static const _keyAuthResponse = 'authResponse';
  static const _keyUser = 'user';

  // Call this method at app startup to load the session from storage.
  Future<void> init() async {
    try {
      final authString = await _secureStorage.read(key: _keyAuthResponse);
      final userString = await _secureStorage.read(key: _keyUser);

      if (authString != null && userString != null) {
        _authResponse = AuthResponse.fromJson(json.decode(authString));
        _user = User.fromJson(json.decode(userString));
      }
    } catch (e) {
      // If there's an error reading, clear the session to be safe
      await clearSession();
    }
  }

  // Save session data to memory and secure storage after login.
  Future<void> setSession(AuthResponse authData, User userData) async {
    _authResponse = authData;
    _user = userData;

    // Convert objects to JSON strings before storing
    await _secureStorage.write(key: _keyAuthResponse, value: json.encode(authData.toJson()));
    await _secureStorage.write(key: _keyUser, value: json.encode(userData.toJson()));
  }

  // Clear session data from memory and secure storage on logout.
  Future<void> clearSession() async {
    _authResponse = null;
    _user = null;

    await _secureStorage.deleteAll();
  }

  bool get isLoggedIn => _authResponse != null && _user != null;
}
