import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedIndex = 1;
  bool _showNavBar = true;
  double _lastOffset = 0.0;
  final ScrollController _scrollController = ScrollController();

  String email = '';
  String fullNames = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        email = doc.data()?['email'] ?? user.email ?? '';
        fullNames = doc.data()?['fullNames'] ?? '';
      });
    }
  }

  void _handleScroll() {
    double offset = _scrollController.offset;
    if (offset > _lastOffset + 10 && _showNavBar) {
      setState(() => _showNavBar = false);
    } else if (offset < _lastOffset - 10 && !_showNavBar) {
      setState(() => _showNavBar = true);
    }
    _lastOffset = offset;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (index == 1) {
      // Stay on settings
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/map'); // This navigates to the map screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E3D4),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFEFE9DE),
              borderRadius: BorderRadius.circular(40),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.chevron_left, color: Colors.black),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF3B82F6),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      color: Colors.white,
                    ),
                    child: CircleAvatar(
                      radius: 56,
                      backgroundColor: Colors.white,
                      backgroundImage: null,
                      child: Text(
                        (fullNames.isNotEmpty
                                ? fullNames[0]
                                : (email.isNotEmpty ? email[0] : ''))
                            .toUpperCase(),
                        style: const TextStyle(
                          fontSize: 36,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  fullNames,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 3),
                Text(
                  email,
                  style: const TextStyle(fontSize: 20, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _SettingsOptionButton(
                            icon: Icons.person,
                            label: 'Edit Profile',
                            onTap: () =>
                                Navigator.pushNamed(context, '/edit_profile'),
                          ),
                          const SizedBox(height: 12),
                          _SettingsOptionButton(
                            icon: Icons.brightness_6,
                            label: 'App Theme',
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/app_theme',
                            ),
                          ),
                          const SizedBox(height: 12),
                          _SettingsOptionButton(
                            icon: Icons.description,
                            label: 'Terms & Privacy',
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/termsandprivacy',
                            ),
                          ),
                          const SizedBox(height: 12),
                          _SettingsOptionButton(
                            icon: Icons.share,
                            label: 'Share App',
                             onTap: () => Navigator.pushNamed(
                              context,
                              '/termsandprivacy',
                            ),
                          ),
                          const SizedBox(height: 12),
                          _SettingsOptionButton(
                            icon: Icons.logout,
                            label: 'Logout',
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/logout',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        offset: _showNavBar ? Offset.zero : const Offset(0, 1),
        child: Padding(
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
                      selected: _selectedIndex == 0,
                      onTap: () => _onItemTapped(0),
                    ),
                    _NavIcon(
                      icon: Icons.settings,
                      label: 'Settings',
                      selected: _selectedIndex == 1,
                      onTap: () => _onItemTapped(1),
                    ),
                    _NavIcon(
                      icon: Icons.map,
                      label: 'Map',
                      selected: _selectedIndex == 2,
                      onTap: () => _onItemTapped(2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
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
          color: selected ? const Color(0xFF3B82F6) : Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? Colors.white : Colors.black, size: 24),
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

class _SettingsOptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsOptionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            height: 59,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.22),
              border: Border.all(
                color: const Color(0xFF3B82F6).withOpacity(0.7),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.black),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.black),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
