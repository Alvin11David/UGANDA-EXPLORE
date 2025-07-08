import 'dart:ui';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E3D4),
      body: SafeArea(
        child: Stack(
          children: [
            // Top Glass Container
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    height: 120,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
            ),

            // Main Content
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Back Button
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 22),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),

                  // Profile Picture
                  Center(
                    child: Stack(
                      children: [
                        const CircleAvatar(
                          radius: 60,
                          backgroundImage: AssetImage('assets/profile.jpg'), // replace with your asset
                        ),
                        Positioned(
                          bottom: 0,
                          right: 4,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.green,
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Title & Subtitle
                  const Text(
                    "Edit Profile",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const Text(
                    "Fill in the fields below",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),

                  const SizedBox(height: 20),

                  // Glass Form Container
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        width: double.infinity,
                        color: Colors.white.withOpacity(0.1),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildFloatingField(Icons.person, "Full Names"),
                            _buildFloatingField(Icons.email, "Email"),
                            _buildFloatingField(Icons.phone, "Phone Contact"),
                            _buildFloatingField(Icons.location_on, "Location"),

                            // Bio Field with floating label
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: TextFormField(
                                maxLines: 3,
                                decoration: InputDecoration(
                                  labelText: 'Bio',
                                  labelStyle: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.15),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: const BorderSide(color: Colors.green, width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: const BorderSide(color: Colors.green, width: 2),
                                  ),
                                  suffixIcon: const Icon(Icons.edit, color: Colors.black54, size: 18),
                                ),
                                style: const TextStyle(color: Colors.black87, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Update Button
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: const LinearGradient(
                          colors: [Colors.black, Colors.greenAccent],
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
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 100), // Space for nav bar
                ],
              ),
            ),

            // Bottom Navigation Bar
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      height: 60,
                      color: Colors.white.withOpacity(0.1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.home, color: Colors.black),
                            onPressed: () => Navigator.pushNamed(context, '/home'),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.person, color: Colors.white),
                                SizedBox(width: 6),
                                Text("Profile", style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.settings, color: Colors.black),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.map, color: Colors.black),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingField(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          prefixIcon: Icon(icon, color: Colors.black),
          filled: true,
          fillColor: Colors.white.withOpacity(0.15),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.green, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.green, width: 2),
          ),
          suffixIcon: const Icon(Icons.edit, size: 18, color: Colors.black54),
        ),
        style: const TextStyle(color: Colors.black87, fontSize: 16),
      ),
    );
  }
}