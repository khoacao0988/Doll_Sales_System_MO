import 'package:second/models/auth_response.dart';
import 'package:second/models/user.dart';

class SessionService {
  // Singleton pattern
  static final SessionService _instance = SessionService._internal();
  factory SessionService() {
    return _instance;
  }
  SessionService._internal();

  AuthResponse? _authResponse;
  User? _user;

  // Getter to check if the user is logged in
  bool get isLoggedIn => _authResponse != null;

  AuthResponse? get authResponse => _authResponse;
  User? get user => _user;

  // An init method for any future async initialization
  Future<void> init() async {
    // This can be used later to load session from secure storage
  }

  void setSession(AuthResponse authResponse, User user) {
    _authResponse = authResponse;
    _user = user;
  }

  void updateUser(User newUser) {
    _user = newUser;
  }

  void clearSession() {
    _authResponse = null;
    _user = null;
  }
}
