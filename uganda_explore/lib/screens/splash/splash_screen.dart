import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center:Alignment.center,
            radius: 1.0,
            colors: [
              Color(0xFF0C0F0A),
              Color(0xFF1FF813),
            ],
            stops: [
              0.03,
              0.63,
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 30,
              left: 180,
              child: Image.asset(
                'assets/images/snake.png',
                width: 60,
                height: 60,
              ),
            ),
            Positioned(
              top: 120,
              left: 280,
              child: Image.asset(
                'assets/images/rhino.png',
                width: 80,
                height: 80,
              ),
            ),
            Positioned(
              top: 95,
              left: 50,
              child: Image.asset(
                'assets/images/impala.png',
                width: 60,
                height: 60,
              ),
            ),
            Positioned(
              top: 25,
              right: 20,
              child: Image.asset(
                'assets/images/elephant.png',
                width: 60,
                height: 60,
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: SvgPicture.asset(
                'assets/vectors/toppattern.svg',
                width: 160,
                height: 160,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: SvgPicture.asset(
                'assets/vectors/bottompattern.svg',
                width: 160,
                height: 160,
              ),
            ),
            Positioned(
              top: 180,
              left: 0,
              right: null,
              child: Center(
                child: Stack(
                  children: [
                    Text(
                      "Uganda",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 120,
                        fontWeight: FontWeight.bold,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 1.39
                          ..color = Colors.white,
                      ),
                    ),
                    Text(
                      "Uganda",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 120,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      )
                    )
                  ]
                )
              )
            )
          ]
        ),
      )
    );
  }
}