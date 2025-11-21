import 'package:flutter/material.dart';
import 'package:student_attendance_app/models/user_model.dart';
import 'package:student_attendance_app/services/auth_service.dart';

import '../services/database_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController(); // නම ඇතුළත් කරන්න field එකක්

  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();

  bool _isLoading = false;

  // මතක තියාගන්න lifecycle method එකක්. Screen එක close කරද්දි memory leaks නවත්තනවා.
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    // Keyboard එක hide කරනවා
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Firebase Authentication එකේ user account එක හදනවා
      var user = await _authService.register(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user != null) {
        // Authentication සාර්ථක නම්, Firestore එකේ user data ටික save කරනවා
        UserModel newUser = UserModel(
          uid: user.uid,
          email: user.email!,
          name: _nameController.text.trim(), // User type කරපු නම save කරනවා
          studentId: 'N/A', // Register වෙද්දී මේවා හිස්ව තියමු
          phone: 'N/A',
          dob: 'N/A',
          degree: 'N/A',
          yearSem: 'N/A',
          profilePicUrl: '',
        );

        await _dbService.createUserInDb(newUser);

        print(
          "Registration successful and user created in DB for: ${user.uid}",
        );

        // Widget එක තවමත් screen එකේ තියෙනවද කියලා බලනවා (හොඳ practice එකක්)
        if (mounted) {
          // Register screen එකෙන් අයින් වෙලා login screen එකට යනවා
          Navigator.of(context).pop();
          // සාර්ථක බවට message එකක් පෙන්වනවා
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Registration successful! Please login."),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Authentication අසාර්ථක නම්, error message එකක් පෙන්වනවා
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Registration failed. Email might already be in use or password is too weak.",
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }

      // Loading indicator එක නවත්වනවා
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Account"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Get Started",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "Create your account to continue",
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Full Name",
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // Register Button
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.blue,
                        ),
                        child: const Text(
                          "Register",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
