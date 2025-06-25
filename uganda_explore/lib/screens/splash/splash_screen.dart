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
              top: 100,
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
            Align(
              alignment: Alignment.center,
              child: Image.asset(
                'assets/logo/whitelogo.png',
                width: 100,
                height: 100,
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height/2 + 20,
              right: 0,
              child: Opacity(
                opacity: 0.7,
              child: Text(
                "Explore",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 120,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 0.8
                    ..color = Colors.white,
                ),
                textAlign: TextAlign.right,
              )
            ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height/2 + 190,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  "Discover the pearl of Africa in 3D",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 25,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Positioned(
              top: 160,
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
            ),
            Positioned(
              bottom:0,
              left: 0,
              child: Image.asset(
                'assets/images/crestedcrane.png',
                width: 150,
                height: 150,
              ),
            ),
          ]
        ),
      )
    );
  }
}