import 'dart:ui';

import 'package:flutter/material.dart';

class OnboardingScreen1 extends StatelessWidget {
  const OnboardingScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/onboardingscreen1bg.png',
              fit: BoxFit.cover,
        ),
      ), 
      Positioned(
        top: 5,
        left: 0,
        right: 0,
        child: Center(

          child: Image.asset(
            'logo/whiteugandaexplore.png',
            width: 260,
            height: 100,
            fit: BoxFit.contain,
          ),
        ),
      ),
      Positioned(
        left: 4,
        right: 4,
        bottom: 4,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              height: 386,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(40), 
                border: Border.all(
                  color: Colors.white,
                  width: 1.1,
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 18,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Color(0xFF1FF813),
                            width: 3,
                          ),
                          color: Colors.transparent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 15,
                        height: 15,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF1FF813),
                        ),
                      ),
                      const SizedBox(width: 12,),
                      Container(
                        width: 15,
                        height: 15,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF1FF813),
                        ),
                      ),
                    ],
                  )
                ],
              )
            ),
          ),
        ),
      ),
      ],
      ),
    );
  }
}