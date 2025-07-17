import 'dart:ui';
import 'package:flutter/material.dart';

class TermsPrivacyScreen extends StatelessWidget {
  const TermsPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0), // Cream background
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,

        child: SafeArea(
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                        // border: Border.all(color: Colors.grey[300].withOpacity(0.1), width: 0.5), // Optional faint border
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
                              icon: Icon(
                                Icons.arrow_back,
                                size: 20,
                                color: Colors.black,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Uganda',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 22, // Reduced font size
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Image.asset(
                                  'assets/logo/blacklogo.png',
                                  height: 30, // Reduced image size
                                  width: 30,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Explore',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 22, // Reduced font size
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.0,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12), // Placeholder for spacing
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Main content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      const Text(
                        'Terms & Privacy',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Content sections
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSection(
                                'Introduction',
                                'By using Uganda Explore, you agree to the following terms and conditions governing your use of the application and its services.',
                              ),
                              const SizedBox(height: 24),

                              _buildSection(
                                'Account & Data',
                                'Responsibility for account security.\nHandling of user data.\nHow the app uses location and content.',
                              ),
                              const SizedBox(height: 24),

                              _buildSection(
                                'Third-Party Services',
                                'Use of Google Maps, Firebase, or other tools\nLinks to their own terms (optional)',
                              ),
                              const SizedBox(height: 24),

                              _buildContactSection(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Container(height: 1, color: Colors.grey.withOpacity(0.3)),
      ],
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact Us',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'If you have any questions about these terms, contact us at: ',
          style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
        ),
        GestureDetector(
          onTap: () {
            // Handle email tap - you can implement email functionality here
          },
          child: const Text(
            'alvin69david@gmail.com',
            style: TextStyle(
              fontSize: 16,
              color: Colors.green,
              height: 1.5,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}

// Example usage in your main app
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uganda Explore',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'SF Pro Display', // or any other font you prefer
      ),
      home: const TermsPrivacyScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
