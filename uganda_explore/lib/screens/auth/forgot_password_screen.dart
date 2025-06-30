import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [Color(0xFF0C0F0A), Color(0xFF1EF813)],
            stops: [0.03, 0.63],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 60),
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: Image.asset(
                  'assets/logo/blacklogo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Let's get you\n sorted!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 37,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
Container(
  width: 490,
  padding: const EdgeInsets.only(left: 4, right: 4, bottom: 0),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.vertical(
      top: Radius.circular(40),
    ),
  ),
  child: Column(
    children: const [
      SizedBox(height: 30),
      // Form elements will go here
    ],
  ),
),

          ],
        ),
      ),
    );
  }
}
