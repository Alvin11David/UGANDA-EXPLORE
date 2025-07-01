import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E3D4),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin:const EdgeInsets.symmetric(horizontal:0, vertical: 0),
            decoration: BoxDecoration(
              color: const Color(0xFFE5E3D4),
              borderRadius: BorderRadius.circular(40),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                
              ],
            )
          )
        )
      )
    );
  }
}