import 'package:flutter/material.dart';
import 'package:uganda_explore/firebase_options.dart';
import 'package:uganda_explore/screens/auth/sign_in_screen.dart';
import 'package:uganda_explore/screens/home/home_screen.dart';
import 'package:uganda_explore/screens/profile/profile_screen.dart';
import 'package:uganda_explore/screens/splash/onboarding_screen1.dart';
import 'package:uganda_explore/screens/splash/onboarding_screen2.dart';
import 'package:uganda_explore/screens/splash/onboarding_screen3.dart';
import 'package:uganda_explore/screens/splash/splash_screen.dart';
import 'screens/error/error_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1EF813)),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      // Change this to the screen you want to test
      home: const ProfileScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text('$_counter', style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
