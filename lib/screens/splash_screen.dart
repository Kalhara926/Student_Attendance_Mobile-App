import 'dart:async';
import 'package:flutter/material.dart';
import 'package:student_attendance_app/auth_gate.dart'; // AuthGate එක import කරගන්නවා

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    // තත්පර 3ක delay එකකින් පස්සේ ඊළඟ screen එකට යනවා
    Timer(const Duration(seconds: 3), () {
      // widget එක තවමත් screen එකේ පවතිනවද කියලා බලනවා.
      if (mounted) {
        // user login වෙලාද නැද්ද කියලා බලන්න AuthGate එකට යොමු කරනවා.
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const AuthGate()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // --- UI එක design එකට අනුව යාවත්කාලීන කරන ලදී ---
    return Scaffold(
      backgroundColor: const Color(0xFF0D47A1), // Deep blue background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Spacer to push content down
            const Spacer(flex: 2),

            // App Logo
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.school, // The graduation cap icon from the image
                size: 50,
                color: Color(0xFF0D47A1), // Deep blue icon color
              ),
            ),
            const SizedBox(height: 24),

            // App Name
            const Text(
              'AcademiaTrack', // App name from the image
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),

            // Spacer to push loader to the bottom
            const Spacer(flex: 3),

            // Loading Text
            const Text(
              'Checking credentials...',
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 16),

            // Custom Linear Progress Indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: const LinearProgressIndicator(
                  minHeight: 6,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(0xFFFFC107),
                  ), // Amber/Yellow color
                ),
              ),
            ),

            // Bottom padding
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
