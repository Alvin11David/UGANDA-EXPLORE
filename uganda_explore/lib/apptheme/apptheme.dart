import 'package:flutter/material.dart';

class AppThemeScreen extends StatelessWidget {
  const AppThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/vertical-shot-some-beautiful-trees-sun-setting-background.jpg'
              ), 
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
