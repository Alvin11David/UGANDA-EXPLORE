import 'dart:ui';

import 'package:flutter/material.dart';

class OnboardingScreen2 extends StatelessWidget {
  const OnboardingScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
          child: Image.asset(
            'assets/images/onboardingscreen2bg.png',
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          child: Image.asset(
            'assets/images/360mockup.png',
            fit: BoxFit.contain,
            height: MediaQuery.of(context).size.height,
          ),
         ),
         Positioned(
          top: 5,
          left: 0,
          right: 0,
          child: Center(
            child: Image.asset(
              'assets/logo/blackugandaexplore.png',
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
              filter: ImageFilter.blur(sigmaX:15, sigmaY: 15),
              child: Container(
                height: 386,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: Colors.white,
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
          ),
         ]
        )
      );
  }
}