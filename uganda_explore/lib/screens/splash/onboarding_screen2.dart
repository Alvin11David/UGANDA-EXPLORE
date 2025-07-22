import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:uganda_explore/config/theme_notifier.dart';
import 'package:flutter/material.dart';

class OnboardingScreen2 extends StatelessWidget {
  const OnboardingScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/onboardingscreen2bg.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 90,
            bottom: 0,
            right: 0,
            child: Image.asset(
              'assets/images/360mockup.png',
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
                isDarkMode
                    ? 'assets/logo/whiteugandaexplore.png'
                    : 'assets/logo/blackugandaexplore.png',
                width: 220,
                height: 90,
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
                    color: isDarkMode
                        ? Colors.black.withOpacity(0.15)
                        : Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Color(0xFF3B82F6), // Blue
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pushReplacementNamed('/onboarding_screen1');
                    },
                    icon: const Icon(
                      Icons.arrow_back_sharp,
                      color: Color(0xFF3B82F6),
                    ), // Blue
                  ),
                ),
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
                    color: isDarkMode
                        ? Colors.black.withOpacity(0.15)
                        : Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF3B82F6), // Navy Blue
                            ),
                          ),
                          const SizedBox(width: 12),
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
                              color: Color(0xFF3B82F6), // Blue
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Main text
                      Text(
                        "See Before You\n Go",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                          color: isDarkMode
                              ? Colors.white
                              : Colors.black, // Navy Blue
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Subtitle
                      Text(
                        "Take 3D and 360° virtual tours of tourist\n sites from anywhere in the\n world.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: isDarkMode
                              ? Colors.white
                              : Colors.black, // Dark Gray
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
                              ).pushReplacementNamed('/onboarding_screen3');
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
                                    "Next",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black,
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
