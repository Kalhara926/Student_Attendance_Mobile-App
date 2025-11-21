import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

import '../auth/login_screen.dart'; // Make sure this path is correct

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // UI එකේ තියෙන ප්‍රධාන නිල් පාට
    const primaryColor = Color(0xFF0D6EFD);
    // UI එකේ තියෙන පසුබිම් පාට
    const backgroundColor = Color(0xFFF8F9FA);

    // Onboarding screen එක ඉවර වුණාම Login screen එකට යවන function එක
    void onDone(BuildContext context) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }

    // Page වල title සහ body text වලට අදාළ style එක
    const pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(
        fontSize: 26.0,
        fontWeight: FontWeight.bold,
        color: Color(0xFF212529),
      ),
      bodyTextStyle: TextStyle(fontSize: 16.0, color: Color(0xFF6C757D)),
      bodyPadding: EdgeInsets.symmetric(horizontal: 24.0),
      pageColor: backgroundColor,
      imagePadding: EdgeInsets.only(top: 80, bottom: 24),
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: IntroductionScreen(
          // Onboarding pages ටික
          pages: [
            // පළවෙනි page එක
            PageViewModel(
              title: "Your Academic Life,\nSimplified",
              body:
                  "Effortlessly track your attendance, manage deadlines, and organize your schedule all in one place.",
              image: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Image.asset('assets/onboarding1.png', height: 300),
              ),
              decoration: pageDecoration,
            ),
            // දෙවෙනි page එක
            PageViewModel(
              title: "Stay Organized,\nEffortlessly",
              body:
                  "Track all your assignments, quizzes, and exams in one place. We'll help you stay on top of your schedule.",
              image: Image.asset('assets/onboarding2.png', height: 300),
              decoration: pageDecoration,
            ),
            // තුන්වෙනි page එක (Custom Body එකක් සමඟ)
            PageViewModel(
              title: "Your Academic\nSuccess, Simplified.",
              image: Image.asset('assets/onboarding3.png', height: 300),
              // Body එක වෙනුවට custom widget එකක්
              bodyWidget: Column(
                children: [
                  const Text(
                    "Stay organized, track progress, and ace your classes with ease.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16.0, color: Color(0xFF6C757D)),
                  ),
                  const SizedBox(height: 24),
                  // Feature cards තුන
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildFeatureCard(
                        icon: Icons.check_circle_outline,
                        title: "Track Attendance",
                        subtitle: "Never miss a class again.",
                        iconColor: Colors.green,
                      ),
                      _buildFeatureCard(
                        icon: Icons.calendar_today_outlined,
                        title: "Master Your Schedule",
                        subtitle: "View timetables & deadlines.",
                        iconColor: Colors.orange,
                      ),
                      _buildFeatureCard(
                        icon: Icons.trending_up,
                        title: "Reach Your Goals",
                        subtitle: "Monitor your progress.",
                        iconColor: Colors.blueAccent,
                      ),
                    ],
                  ),
                ],
              ),
              decoration: pageDecoration.copyWith(
                bodyFlex: 2, // Body එකට වැඩි ඉඩක් ලබා දීම
                imageFlex: 2, // Image එකට ඉඩ
              ),
            ),
          ],

          // Navigation Buttons
          onDone: () => onDone(context),
          onSkip: () => onDone(context), // Skip කරාමත් Login එකට යනවා
          showSkipButton: true,
          skip: const Text('Skip', style: TextStyle(color: Colors.grey)),
          showNextButton: true,
          next: const Text(
            'Next',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          showBackButton: true,
          back: const Text(
            'Back',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          done: const Text(
            'Get Started',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),

          // Button Style
          baseBtnStyle: TextButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          skipStyle: TextButton.styleFrom(
            foregroundColor: Colors.grey.shade700,
          ),
          backStyle: TextButton.styleFrom(foregroundColor: primaryColor),
          nextStyle: TextButton.styleFrom(foregroundColor: Colors.white),
          doneStyle: TextButton.styleFrom(foregroundColor: Colors.white),

          // Dots Indicator Style
          dotsDecorator: const DotsDecorator(
            size: Size.square(8.0),
            activeSize: Size(20.0, 8.0),
            activeColor: primaryColor,
            color: Colors.black26,
            spacing: EdgeInsets.symmetric(horizontal: 3.0),
            activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25.0)),
            ),
          ),

          // Header (Logo) & Footer (Login link)
          globalHeader: const Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(top: 20, left: 20),
              child: Icon(Icons.school, color: primaryColor, size: 30),
            ),
          ),
          globalFooter: SizedBox(
            width: double.infinity,
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Already have an account? ",
                  style: TextStyle(color: Colors.grey),
                ),
                GestureDetector(
                  onTap: () => onDone(context), // Login එකට යනවා
                  child: const Text(
                    "Log In",
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          controlsPadding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 16.0),
        ),
      ),
    );
  }

  // තුන්වෙනි screen එකේ feature cards හදන widget එක
  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
  }) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
