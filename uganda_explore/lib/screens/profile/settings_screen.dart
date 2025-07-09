import 'dart:ui';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}
class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/profile');
    } else if (index == 3) {
      Navigator.pushReplacementNamed(context, '/map');
    }
    // Add more navigation logic for other indices if needed
  }
    @override
  Widget build(BuildContext context) {
    final String email = 'john.doe@email.com';
    final String name = 'John Doe';

    return Scaffold(
      backgroundColor: const Color(0xFFE5E3D4),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFEFE9DE),
              borderRadius: BorderRadius.circular(40),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Column(
              children: [