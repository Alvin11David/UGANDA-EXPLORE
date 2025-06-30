import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:uganda_explore/screens/home/home_screen.dart';

class OnboardingScreen3 extends StatelessWidget {
  const OnboardingScreen3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
          child: Image.asset(
            'assets/images/onboardingscreen3bg.png',
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 90,
          bottom: 0,
          right: 0,
          child: Image.asset(
            'assets/images/armockup.png',
            fit: BoxFit.contain,
            height: MediaQuery.of(context).size.height,
          ),
         ),
         Positioned(
          top: 15,
          left: 5,
          right: 0,
          child: Center(
            child: Image.asset(
              'assets/logo/whiteugandaexplore.png',
              width: 260,
              height: 100,
              fit: BoxFit.contain,
            ),
          ),
         ),
         Positioned(
          top: 38,
          left: 2,
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Color(0xFF1FF813),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/onboarding_screen2');
                  }, 
                  icon: const Icon(Icons.arrow_back_sharp, color: Color(0xFF1FF813),),)
              ),
            ),
            
          )
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
                child: Column(
                  children: [
                    const SizedBox(height: 18,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                        const SizedBox(width: 12,),
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
                      ]
                    ),
                    const SizedBox(height: 24),
                      // Main text
                      const Text(
                        "Find Your Way With\n Augmented Reality\n (AR)",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Subtitle
                      const Text(
                        "Use real-time Augmented Reality to\n navigate easily to nearby attractions.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 22),
                      // Get Started Button
                      Center(
                        child: Container(
                          width: 323,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Color(0xFF000000),
                                Color(0xFF1FF813),
                              ],
                              stops: [0.0, 0.47],
                            ),
                            border: Border.all(
                              color: Color(0xFF1FF813),
                              width: 1,
                            ),
                          ),
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) => HomeScreen()),
                              );
                            },
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Continue",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                       ),
                     ),
                  ],
                )
              ),
            ),
          ),
          ),
         ]
        )
      );
  }
}