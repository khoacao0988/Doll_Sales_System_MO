import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/auth_service.dart';
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

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authResponse = await _authService.login(_usernameController.text, _passwordController.text);
      final Map<String, dynamic> decodedToken = JwtDecoder.decode(authResponse.accessToken);
      final userId = int.parse(decodedToken['sub'] ?? '0');

      if (userId == 0) throw Exception('User ID not found in token.');

      final user = await _authService.getUserDetailsById(userId, authResponse.accessToken);
      SessionService().setSession(authResponse, user);

      // After successful login, get FCM token and send it to the backend.
      // This is a "fire-and-forget" operation to not block the UI.
      NotificationService.instance.getFcmToken().then((fcmToken) {
        if (fcmToken != null) {
          _authService.updateFcmToken(user.userID, fcmToken, authResponse.accessToken);
        }
      });

      if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const HomePage()));
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() { _isLoading = false; });
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text('Character Doll', textAlign: TextAlign.center, style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF3F51B5))),
                const SizedBox(height: 10),
                const Text('Welcome back!', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Colors.black54)),
                const SizedBox(height: 50),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  ),
                TextField(controller: _usernameController, decoration: const InputDecoration(hintText: 'Username', filled: true, fillColor: Color(0xFFF1F4FF), prefixIcon: Icon(Icons.person_outline, color: Color(0xFF3F51B5)), border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none))),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: _isPasswordObscured,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    filled: true,
                    fillColor: const Color(0xFFF1F4FF),
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
                Row(children: <Widget>[const Expanded(child: Divider(color: Colors.grey)), Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0), child: Text('Or continue with', style: TextStyle(color: Colors.grey[600]))), const Expanded(child: Divider(color: Colors.grey))]),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  // Reverted to a simple text-based icon
                  icon: const Text('G', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue)),
                  label: const Text('Google', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                  onPressed: () { /* TODO: Implement Google Login */ },
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), side: BorderSide(color: Colors.grey.shade300), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(height: 40),
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
