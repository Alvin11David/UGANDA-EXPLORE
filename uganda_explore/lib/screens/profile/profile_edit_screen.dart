import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uganda_explore/screens/virtual_ar/map_view_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  int _selectedIndex = 0;
  File? _profileImage;
  final String email = "user@email.com"; // Replace with actual user email

  final TextEditingController fullNamesController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneContactController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) Navigator.pushReplacementNamed(context, '/home');
    if (index == 1) Navigator.pushReplacementNamed(context, '/settings');
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MapViewScreen(
            siteName: 'Your Current Location',
            showCurrentLocation: true,
          ),
        ),
      );
    }
  }

  Future<void> _onChangePicture() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _profileImage = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color mainGreen = const Color(0xFF1FF813);

    return Scaffold(
      backgroundColor: const Color(0xFFE5E3D4),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                // Back button
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.chevron_left, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Profile avatar with green border and camera icon
                Center(
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: mainGreen, width: 1),
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
                          radius: 60,
                          backgroundColor: mainGreen.withOpacity(0.15),
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : null,
                          child: _profileImage == null
                              ? Text(
                                  email.isNotEmpty
                                      ? email[0].toUpperCase()
                                      : '',
                                  style: TextStyle(
                                    fontSize: 40,
                                    color: mainGreen,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                  ),
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _onChangePicture,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            padding: const EdgeInsets.all(6),
                            child: Icon(
                              Icons.camera_alt,
                              color: mainGreen,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Title
                const Text(
                  "Edit Profile",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  "Fill in the fields below",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 20),

                // Glass Container for Fields and Update Button
                ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.only(
                        left: 4,
                        right: 4,
                        bottom: 0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          _buildFloatingField(
                            Icons.person,
                            "Full Names",
                            controller: fullNamesController,
                            iconColor: mainGreen,
                          ),
                          _buildFloatingField(
                            Icons.email,
                            "Email",
                            controller: emailController,
                            iconColor: mainGreen,
                          ),
                          _buildFloatingField(
                            Icons.phone,
                            "Phone Contact",
                            controller: phoneContactController,
                            iconColor: mainGreen,
                          ),
                          _buildFloatingField(
                            Icons.location_on,
                            "Location",
                            controller: locationController,
                            iconColor: mainGreen,
                          ),
                          _buildFloatingField(
                            Icons.edit,
                            "Bio",
                            controller: bioController,
                            isMultiline: true,
                            iconColor: mainGreen,
                          ),
                          const SizedBox(height: 24),

                          // Update Button
                          GestureDetector(
                            onTap: () async {
                              final user = FirebaseAuth.instance.currentUser;
                              if (user != null) {
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .update({
                                      'fullNames': fullNamesController.text
                                          .trim(),
                                      'email': emailController.text.trim(),
                                      'phoneContact': phoneContactController
                                          .text
                                          .trim(),
                                      'location': locationController.text
                                          .trim(),
                                      'bio': bioController.text.trim(),
                                    });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Profile updated!'),
                                  ),
                                );
                                Navigator.pop(
                                  context,
                                ); // Optionally go back to profile screen
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                gradient: LinearGradient(
                                  colors: [Colors.black, mainGreen],
                                  stops: const [0.0, 0.47],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  'Update',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
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
                    color: mainGreen,
                  ),
                  _NavIcon(
                    icon: Icons.settings,
                    label: 'Settings',
                    selected: _selectedIndex == 1,
                    onTap: () => _onItemTapped(1),
                    color: mainGreen,
                  ),
                  _NavIcon(
                    icon: Icons.map,
                    label: 'Map',
                    selected: _selectedIndex == 2,
                    onTap: () => _onItemTapped(2),
                    color: mainGreen,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingField(
    IconData icon,
    String label, {
    bool isMultiline = false,
    Color? iconColor,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        maxLines: isMultiline ? 3 : 1,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w300,
            fontSize: 16,
            fontFamily: 'Poppins',
          ),
          prefixIcon: Icon(
            icon,
            color: icon == Icons.edit
                ? Colors.black
                : (iconColor ?? Colors.black),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.15),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30), // Change this value for field border radius
            borderSide: const BorderSide(color: Colors.green, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30), // Change this value for field border radius
            borderSide: const BorderSide(color: Colors.green, width: 2),
          ),
          suffixIcon: const Icon(Icons.edit, size: 19, color: Colors.black),
        ),
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 16,
          fontFamily: 'Poppins',
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
  final Color color;

  const _NavIcon({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
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
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}