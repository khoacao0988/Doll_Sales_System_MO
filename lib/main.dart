import 'dart:io';
import 'package:flutter/material.dart';
import 'package:second/screens/home_page.dart';
import 'services/session_service.dart';
import 'screens/login_page.dart';

// This class allows the app to trust the self-signed certificate used by the local server.
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  // Ensure Flutter engine is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Activate the HttpOverrides to allow connection to the local HTTPS server
  HttpOverrides.global = MyHttpOverrides();

  // Initialize the session service to load any stored credentials
  await SessionService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Character Doll App',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3F51B5)), // Indigo
      ),
      // CORRECT WAY: Decide the home page based on login status
      home: SessionService().isLoggedIn ? const HomePage() : const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
