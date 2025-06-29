import 'package:flutter/material.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

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
            colors: [
              Color(0xFF0C0F0A),
              Color(0xFF1EF813),
            ],
            stops: [0.03, 0.63],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Center(
                child: Image.asset(
                  'logo/ugandaexplore.png', 
                  width: 268,
                  height: 60,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                "Let’s get you \nsorted!",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}