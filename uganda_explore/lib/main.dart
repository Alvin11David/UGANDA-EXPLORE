import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uganda_explore/Admin/Admin_Dashboard.dart';
import 'package:uganda_explore/apptheme/apptheme.dart';
import 'package:uganda_explore/config/theme_notifier.dart';
import 'package:uganda_explore/firebase_options.dart';

// Auth Screens
import 'package:uganda_explore/screens/auth/forgot_password_screen.dart';
import 'package:uganda_explore/screens/auth/otp_screen.dart';
import 'package:uganda_explore/screens/auth/sign_in_screen.dart';
import 'package:uganda_explore/screens/places/place_details_screen.dart';
import 'package:uganda_explore/screens/profile/profile_edit_screen.dart';
import 'package:uganda_explore/screens/profile/settings_screen.dart';
import 'package:uganda_explore/screens/profile/termsandprivacy_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Splash Screens
import 'package:uganda_explore/screens/splash/onboarding_screen1.dart';
import 'package:uganda_explore/screens/splash/onboarding_screen2.dart';
import 'package:uganda_explore/screens/splash/onboarding_screen3.dart';

// Other Screens
import 'package:uganda_explore/screens/home/home_screen.dart';
import 'package:uganda_explore/screens/profile/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize WebView Platform - This is crucial for Street View to work
  try {
    // This ensures the WebView platform is properly initialized
    WebViewPlatform.instance ??= WebViewPlatform.instance;
    print('WebView platform initialized successfully');
  } catch (e) {
    print('Error initializing WebView platform: $e');
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Uganda Explore',
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeNotifier.isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,
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
            '/edit_profile': (context) => const EditProfileScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/app_theme': (context) => const AppThemeScreen(),
            '/privacy': (context) => const TermsPrivacyScreen(),
            '/admin_dashboard': (context) => const AdminDashboard(),
            '/termsandprivacy': (context) => const TermsPrivacyScreen(),
          },
          home: const SignInScreen(),
        );
      },
    );
  }
}
