import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center:Alignment.center,
            radius: 1.0,
            colors: [
              Color(0xFF0C0F0A),
              Color(0xFF1FF813),
            ],
          )
        ),
      )
    );
  }
}