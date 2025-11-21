import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

import '../auth/login_screen.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Onboarding screen එක ඉවර වුණාම Login screen එකට යවන function එක
    void onDone(BuildContext context) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
    }

    return Scaffold(
      body: IntroductionScreen(
        pages: [
          // පළවෙනි page එක
          PageViewModel(
            title: "Track Your Attendance",
            body:
                "Easily mark and view your attendance for every class without any hassle.",
            image: const Center(
              child: Icon(Icons.class_, size: 100.0, color: Colors.blue),
            ),
            decoration: const PageDecoration(
              titleTextStyle: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
              ),
              bodyTextStyle: TextStyle(fontSize: 18.0),
            ),
          ),
          // දෙවෙනි page එක
          PageViewModel(
            title: "View Your Timetable",
            body: "Access your weekly class schedule anytime, anywhere.",
            image: const Center(
              child: Icon(Icons.schedule, size: 100.0, color: Colors.blue),
            ),
            decoration: const PageDecoration(
              titleTextStyle: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
              ),
              bodyTextStyle: TextStyle(fontSize: 18.0),
            ),
          ),
          // තුන්වෙනි page එක
          PageViewModel(
            title: "Check Your Grades",
            body:
                "Keep up with your academic performance by checking your grades instantly.",
            image: const Center(
              child: Icon(Icons.grade, size: 100.0, color: Colors.blue),
            ),
            decoration: const PageDecoration(
              titleTextStyle: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
              ),
              bodyTextStyle: TextStyle(fontSize: 18.0),
            ),
          ),
        ],
        showNextButton: true,
        next: const Icon(Icons.arrow_forward),
        done: const Text(
          "Get Started",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        onDone: () =>
            onDone(context), // Done button එක click කරාම මොකද වෙන්න ඕන
        dotsDecorator: DotsDecorator(
          size: const Size.square(10.0),
          activeSize: const Size(20.0, 10.0),
          activeColor: Colors.blue,
          color: Colors.black26,
          spacing: const EdgeInsets.symmetric(horizontal: 3.0),
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
      ),
    );
  }
}
