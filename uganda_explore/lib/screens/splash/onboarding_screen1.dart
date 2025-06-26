import 'dart:ui';
import 'package:flutter/material.dart';

class OnboardingScreen1 extends StatelessWidget {
  const OnboardingScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          SizedBox.expand(
            child: Image.asset(
              'assets/images/onboardingscreen1bg.png',
              fit: BoxFit.cover,
            ),
          ),
          // Top center logo
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
          // Bottom blur card
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
                      const SizedBox(height: 18),
                      // Page indicators
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
                          const SizedBox(width: 12),
                          Container(
                            width: 15,
                            height: 15,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF1FF813),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Main text
                      const Text(
                        "Discover the hidden gems,\ncultural heritage\nand stunning nature of\nUganda",
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
                        "Explore Uganda like never before",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
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
                              // Add navigation or action here
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
                                    "Get Started",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 5, bottom: 5, right: 5),
                                  child: Container(
                                    width: 52,
                                    height: 52,
                                    decoration: const BoxDecoration(
                                      color: Colors.black,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}