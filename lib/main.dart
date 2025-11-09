import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:second/screens/your_page.dart';
import 'package:second/services/notification_service.dart';
import 'package:second/services/session_service.dart';
import 'firebase_options.dart';
import 'screens/home_page.dart';
import 'screens/library_page.dart';
import 'screens/login_page.dart';
import 'screens/notification_page.dart';
import 'screens/profile_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Failed to initialize Firebase: $e');
  }

  // Initialize Notification Service (This call is lightweight)
  await NotificationService.instance.initialize();

  // Check if user is already logged in
  final isLoggedIn = await SessionService().isLoggedIn;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // This will remove the DEBUG banner
      title: 'Doll World',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto', 
      ),
      home: isLoggedIn ? const HomePage() : const LoginPage(),
      routes: {
        '/home': (context) => const HomePage(),
        '/library': (context) => const LibraryPage(),
        '/your': (context) => const YourPage(),
        '/profile': (context) => const ProfilePage(),
        '/notifications': (context) => const NotificationPage(),
      },
    );
  }
}
