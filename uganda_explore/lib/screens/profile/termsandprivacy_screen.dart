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
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Image.asset(
                                  'assets/logo/blacklogo.png',
                                  height: 30,
                                  width: 30,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Explore',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.0,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
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
                      const Text(
                        'Terms & Privacy',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 24),
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: Colors.white.withOpacity(0.4),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavIcon(
                    icon: Icons.home,
                    label: 'Home',
                    selected: false,
                    onTap: () => Navigator.pushReplacementNamed(context, '/home'),
                  ),
                  // Profile button removed
                  _NavIcon(
                    icon: Icons.settings,
                    label: 'Settings',
                    selected: false,
                    onTap: () => Navigator.pushReplacementNamed(context, '/settings'),
                  ),
                  _NavIcon(
                    icon: Icons.map,
                    label: 'Map',
                    selected: false,
                    onTap: () => Navigator.pushReplacementNamed(context, '/map'),
                  ),
                ],
              ),
            ),
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

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavIcon({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1FF813) : Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black, size: 24),
            if (selected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}