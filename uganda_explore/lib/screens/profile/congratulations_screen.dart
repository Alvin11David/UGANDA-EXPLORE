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
            Color(0xFF0C0F0A),
            Color(0xFF235347),
          ],
          stops: [0.03, 0.63],
        ),
      ),
      child: Center(
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Image.asset(
        'assets/images/rigidcircle.png', // Update the path if needed
        width: 200, // Adjust size as needed
        height: 200,
      ),
      const SizedBox(height: 15), // Space between image and text
      const Text(
        'Congratulations',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w800, // Extra bold
          fontSize: 28,
          color: Color(0xFFFFFFFF),
        ),
      ),
      const SizedBox(height: 10), 
      const Text(
        'You have successfully completed your profile',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500, // Medium weight
          
    
        ),
      ),
    ],
  ),
),
    ),
  );
}
}