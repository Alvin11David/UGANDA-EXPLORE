import 'package:flutter/material.dart';

class CongratulationsScreen extends StatelessWidget {
  const CongratulationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              Color(0xFF0C0F0A), // OCOFOA at 3%
              Color(0xFF235347), // 235347 at 63%
            ],
            stops: [0.03, 0.63],
          ),
        ),
      ),
    );
  }
}