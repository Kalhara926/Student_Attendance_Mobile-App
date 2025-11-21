import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:student_attendance_app/auth_gate.dart';
import 'firebase_options.dart'; // <-- අලුතෙන් හැදුනු file එක import කරගන්න

void main() async {
  // මේ line දෙක අනිවාර්යයි
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase initialize කරන අලුත් ක්‍රමය
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // <-- මේ line එක වැදගත්
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Attendance App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor:
            Colors.grey[100], // UI එකට පොඩි look එකක් දෙන්න
      ),
      // App එකේ පළවෙනි screen එක AuthGate එක.
      // Splash screen එක AuthGate එක ඇතුළෙන් handle වෙනවා.
      home: const AuthGate(),
    );
  }
}
