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
      // මේක හොඳ programming practice එකක්.
      if (mounted) {
        // user login වෙලාද නැද්ද කියලා බලන්න AuthGate එකට යොමු කරනවා.
        // pushReplacement පාවිච්චි කරන්නේ user ට back button එකෙන් ආපහු splash screen එකට එන්න බැරි වෙන්නයි.
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const AuthGate()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo එක
            Icon(
              Icons.school_outlined, // Icon එක වෙනස් කළා. කැමති එකක් දාන්න.
              size: 100,
              color: Colors.blue,
            ),
            SizedBox(height: 20),

            // App Name එක
            Text(
              'Student Attendance',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 40),

            // Loading Indicator එක
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
