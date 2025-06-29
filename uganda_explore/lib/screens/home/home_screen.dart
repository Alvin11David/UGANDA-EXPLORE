import 'dart:ui';

import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 179, 175, 151), // Background color E5E3D4
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 0, left: 0, right: 0),
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30)
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(
                  height: 155,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    border: Border.all(
                      color: Colors.white.withOpacity(1),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'logo/blackugandaexplore.png',
                height: 60,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            top: 80,
            left: 4,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                  ),
                  ],
                  ),
              child: const Center(
                child: Icon(
                  Icons.location_on,
                  color: Colors.black87,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              const Text(
                'Location',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black87,
              ),
            ),
            const SizedBox(height: 2,),
            Row(
              children: [
                Text(
                  'Kampala',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(width: 4,),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: Colors.black87,
                ),
              ],
            ),
            ],
            ),
            ],
          ),
        ),
        Positioned(
            top: 80,
            right: 104,
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.sunny,
                  color: Colors.amber,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}