import 'package:agrova/screens/start_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:agrova/services/auth_service.dart';
import 'package:agrova/screens/home_page.dart';
import 'package:agrova/screens/login_page.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Check if user is logged in
  final authService = AuthService();
  final bool isLoggedIn = await authService.isLoggedIn();

  // Run app with initial route based on login status
  runApp(AgrovaApp(isLoggedIn: isLoggedIn));
}

class AgrovaApp extends StatelessWidget {
  final bool isLoggedIn;

  const AgrovaApp({super.key, this.isLoggedIn = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agrova',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.green),
          titleTextStyle: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 18.0,
          ),
        ),
      ),
      // Choose initial route based on authentication status
      home: isLoggedIn ? const HomePage() : const StartPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/start': (context) => const StartPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
