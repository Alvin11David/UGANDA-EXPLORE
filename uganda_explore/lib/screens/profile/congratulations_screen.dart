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
        'assets/images/rigidcircle.png', 
        width: 200, 
        height: 200,
      ),
      const SizedBox(height: 15),
      const Text(
        'Congratulations',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w800, 
          fontSize: 28,
          color: Color(0xFFFFFFFF),
        ),
      ),
      const SizedBox(height: 10), 
      const Text(
        'You have successfully reached your destination',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: Color(0xFFFFFFFF),
          ),
      ),
      const SizedBox(height: 50),
      Center(
        child: SizedBox(
          width: 323,
          height: 58,
          child: ElevatedButton(
          onPressed: () {
            // Navigate back to the home screen
         },
         style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(1.0), // Capacity 100%
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Done',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Color(0xFF235347),
             ),
          ),
        ),
      )
      )
    ],
  ),
),
    ),
  );
}
}