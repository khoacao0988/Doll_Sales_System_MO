import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/auth_service.dart';
import '../models/auth_response.dart' as auth_model;
import '../models/user.dart';
import '../services/notification_service.dart';
import '../services/session_service.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  bool _isPasswordObscured = true;

  // Re-enable Google Sign-In
  final bool _isGoogleSignInEnabled = true;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authResponse = await _authService.login(_usernameController.text, _passwordController.text);
      await _handleSuccessfulLogin(authResponse, isGoogleLogin: false);
    } catch (e) {
      _handleLoginError(e);
    }
  }

  Future<void> _signInWithGoogle() async {
    if (!_isGoogleSignInEnabled) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: '117505181305-ta0t5dfuub24c7o4e885vlfn5ro6ppd2.apps.googleusercontent.com',
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Could not get Google ID token.');
      }

      final String? fcmToken = await NotificationService.instance.getFcmToken();
      final authResponse = await _authService.googleLogin(idToken, fcmToken);
      await _handleSuccessfulLogin(authResponse, isGoogleLogin: true);

    } catch (e) {
      _handleLoginError(e);
    } finally {
      await GoogleSignIn().signOut();
    }
  }

  Future<void> _handleSuccessfulLogin(auth_model.AuthResponse authResponse, {required bool isGoogleLogin}) async {
    User? user;
    if (isGoogleLogin && authResponse.user != null) {
      user = authResponse.user!;
    } else {
      final Map<String, dynamic> decodedToken = JwtDecoder.decode(authResponse.accessToken);
      final userId = int.tryParse(decodedToken['sub'] ?? '');
      if (userId == null) throw Exception('User ID not found or invalid in token.');
      user = await _authService.getUserDetailsById(userId, authResponse.accessToken);
    }

    SessionService().setSession(authResponse, user);

    if (!isGoogleLogin) {
      NotificationService.instance.getFcmToken().then((deviceToken) {
        if (deviceToken != null) {
          _authService.updateDeviceToken(deviceToken, authResponse.accessToken);
        }
      });
    }

    if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const HomePage()));
  }

  void _handleLoginError(dynamic e) {
    if (mounted) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _launchURL() async {
    final Uri url = Uri.parse('https://doll-sales-system-fe.vercel.app/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch registration page.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text('Doll World', textAlign: TextAlign.center, style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF3F51B5))),
                const SizedBox(height: 10),
                const Text('Welcome back!', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Colors.black54)),
                const SizedBox(height: 50),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  ),
                TextField(controller: _usernameController, decoration: const InputDecoration(hintText: 'Username', filled: true, fillColor: Colors.white, prefixIcon: Icon(Icons.person_outline, color: Color(0xFF3F51B5)), border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none))),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: _isPasswordObscured,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF3F51B5)),
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF3F51B5)),
                      onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
                    ),
                    border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3F51B5), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('LOGIN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 20),
                if (_isGoogleSignInEnabled) ...[
                  Row(children: <Widget>[const Expanded(child: Divider(color: Colors.grey)), Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0), child: Text('Or continue with', style: TextStyle(color: Colors.grey[600]))), const Expanded(child: Divider(color: Colors.grey))]),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    icon: const Text('G', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue)),
                    label: const Text('Google', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                    onPressed: _isLoading ? null : _signInWithGoogle,
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), side: BorderSide(color: Colors.grey.shade300), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                  const SizedBox(height: 40),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Not a member? ", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                    GestureDetector(
                      onTap: _launchURL,
                      child: const Text('Register now', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3F51B5), fontSize: 14)),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
