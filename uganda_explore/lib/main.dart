import 'package:flutter/material.dart';

// Import your page here - uncomment the one you're working on
// import 'sign_in_screen.dart';
// import 'forgot_password_screen.dart';
//import 'screens/error/error_screen.dart';
import 'apptheme/apptheme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1EF813)),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      // Replace with whatever page you're working on
      home: const AppThemeScreen(),
    );
  }
}