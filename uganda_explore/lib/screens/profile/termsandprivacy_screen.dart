import 'dart:ui';
import 'package:flutter/material.dart';

class TermsPrivacyScreen extends StatelessWidget {
  const TermsPrivacyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0), // Cream background
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and logo
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, size: 20, color: Colors.black),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Uganda',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 42,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Image.asset(
                                'assets/logo/blacklogo.png',
                                height: 48,
                                width: 48,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Explore',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 42,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 48), // Spacer to balance the back button width
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Content will be added in next parts
          ],
        ),
      ),
    );
  }
}
