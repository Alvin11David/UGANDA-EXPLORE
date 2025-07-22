import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uganda_explore/config/theme_notifier.dart';


class OnboardingScreen1 extends StatelessWidget {
  const OnboardingScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
            top: 15,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                isDarkMode
                    ? 'assets/logo/whiteugandaexplore.png'
                    : 'assets/logo/blackugandaexplore.png',
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
                    border: Border.all(color: Colors.white, width: 1.1),
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
                                color: Color(0xFF3B82F6), // Blue
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
                              color: Color(0xFF3B82F6), // Navy Blue
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 15,
                            height: 15,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF3B82F6), // Blue
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Main text
                      Text(
                        "Discover the hidden gems,\ncultural heritage\nand stunning nature of\nUganda",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Subtitle
                      Text(
                        "Explore Uganda like never before",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: isDarkMode ? Colors.white : Colors.black,
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
                                Color(0xFF1E3A8A), // Navy Blue
                                Color(0xFF3B82F6), // Blue
                              ],
                              stops: [0.0, 0.47],
                            ),
                            border: Border.all(
                              color: Color(0xFF3B82F6), // Blue
                              width: 1,
                            ),
                          ),
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(
                                context,
                              ).pushReplacementNamed('/onboarding_screen2');
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
                                      color: isDarkMode ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 5,
                                    bottom: 5,
                                    right: 5,
                                  ),
                                  child: Container(
                                    width: 52,
                                    height: 52,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF3B82F6), // Blue
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
