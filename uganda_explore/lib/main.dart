import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uganda_explore/firebase_options.dart';
import 'package:uganda_explore/screens/auth/change_password_screen.dart';

// Auth Screens
import 'package:uganda_explore/screens/auth/forgot_password_screen.dart';
import 'package:uganda_explore/screens/auth/otp_screen.dart';
import 'package:uganda_explore/screens/auth/sign_in_screen.dart';
import 'package:uganda_explore/screens/home/results_screen.dart';
import 'package:uganda_explore/screens/home/search_screen.dart';
import 'package:uganda_explore/screens/places/place_details_screen.dart';

// Splash Screens
import 'package:uganda_explore/screens/splash/onboarding_screen1.dart';
import 'package:uganda_explore/screens/splash/onboarding_screen2.dart';
import 'package:uganda_explore/screens/splash/onboarding_screen3.dart';

// Other Screens
import 'package:uganda_explore/screens/home/home_screen.dart';
import 'package:uganda_explore/screens/profile/profile_screen.dart';
import 'package:uganda_explore/screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
  debugShowCheckedModeBanner: false,
  title: 'Uganda Explore',
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    useMaterial3: true,
  ),
  onGenerateRoute: (settings) {
    if (settings.name == '/place_details') {
      final siteName = settings.arguments as String;
      return MaterialPageRoute(
        builder: (context) => PlaceDetailsScreen(siteName: siteName),
      );
    }
    return null;
  },
  routes: {
    '/signin': (context) => const SignInScreen(),
    '/onboarding_screen1': (context) => const OnboardingScreen1(),
    '/onboarding_screen2': (context) => const OnboardingScreen2(),
    '/onboarding_screen3': (context) => const OnboardingScreen3(),
    '/forgot_password': (context) => const ForgotPasswordScreen(),
    '/otp': (context) => const OtpScreen(email: '', otp: ''),
    '/home': (context) => const HomeScreen(),
    '/profile': (context) => const ProfileScreen(),
    
  },
  home: const SearchScreen(),
);
  }
}
