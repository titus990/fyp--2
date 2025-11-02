import 'package:flutter/material.dart';
import 'dart:async';
import 'boxing_page.dart';
import 'self_defense.dart';
import 'kick_boxing.dart';
import 'widgets/custom_button.dart';

void main() {
  runApp(const StrikeForceApp());
}

class StrikeForceApp extends StatelessWidget {
  const StrikeForceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Strike Force',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/welcome': (context) => const WelcomePage(),
        '/boxing': (context) => const BoxingPage(),
        '/selfdefense': (context) => const SelfDefensePage(),
        '/kickboxing': (context) => const KickBoxingPage(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    // Navigate to Welcome Page after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/welcome');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Using Icon instead of Image.asset to avoid missing asset error
              Icon(Icons.sports_mma, size: 120, color: Colors.redAccent),
              const SizedBox(height: 24),
              const Text(
                'STRIKE FORCE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'WHERE FISTS MEET DISCIPLINE',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Welcome to Strike Force',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 40),

                // Boxing Button
                CustomButton(
                  label: 'Boxing',
                  color: Colors.redAccent,
                  onPressed: () {
                    Navigator.pushNamed(context, '/boxing');
                  },
                ),
                const SizedBox(height: 20),

                // Self Defense Button
                CustomButton(
                  label: 'Self Defense',
                  color: Colors.blueAccent,
                  onPressed: () {
                    Navigator.pushNamed(context, '/selfdefense');
                  },
                ),
                const SizedBox(height: 20),

                // Kick Boxing Button
                CustomButton(
                  label: 'Kick Boxing',
                  color: Colors.orangeAccent,
                  onPressed: () {
                    Navigator.pushNamed(context, '/kickboxing');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
