import 'package:flutter/material.dart';
import 'package:student_attendance_app/screens/main_screen.dart';
import 'package:student_attendance_app/services/auth_service.dart';

// RegisterScreen එක අවශ්‍ය නම් import කරගන්න.
// import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  // UI එකට ගැලපෙන්න controller එකේ නම වෙනස් කළා
  final _studentIdController = TextEditingController();
  final _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isPasswordVisible = false; // Password visibility control කිරීමට

  @override
  void dispose() {
    _studentIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Login logic එකේ කිසිම වෙනසක් කරලා නැහැ.
  // Student ID එක email විදිහට භාවිතා කරනවා කියලා උපකල්පනය කරනවා.
  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // මෙතනදී Student ID එක තමයි email විදිහට යවන්නේ
      var user = await _authService.signIn(
        _studentIdController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user != null) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Login Failed. Please check your credentials."),
              backgroundColor: Colors.red,
            ),
          );
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Design එකේ තියෙන පාටවල්
    const primaryColor = Color(0xFF0B4F6C);
    const backgroundColor = Color(0xFFF0F2F5);
    const textColor = Color(0xFF1D2D3A);
    const subtleTextColor = Color(0xFF6C757D);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Card(
            elevation: 0, // No shadow needed if background is not white
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- Header ---
                    const CircleAvatar(
                      radius: 35,
                      backgroundColor: Color(0xFFE0E8F0),
                      child: Icon(
                        Icons.school_outlined,
                        color: primaryColor,
                        size: 35,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Welcome Back!",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Log in to your student portal",
                      style: TextStyle(fontSize: 16, color: subtleTextColor),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // --- Student ID Field ---
                    const Text(
                      'Student ID',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _studentIdController,
                      decoration: InputDecoration(
                        hintText: "Enter your student ID",
                        prefixIcon: const Icon(
                          Icons.person_outline,
                          color: subtleTextColor,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      keyboardType: TextInputType.text, // Email වෙනුවට text
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your student ID';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // --- Password Field ---
                    const Text(
                      'Password',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        hintText: "Enter your password",
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: subtleTextColor,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: subtleTextColor,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      obscureText: !_isPasswordVisible,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // --- Login Button ---
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                    const SizedBox(height: 16),

                    // --- Forgot Password Link ---
                    TextButton(
                      onPressed: () {
                        // TODO: Forgot Password logic එක මෙතනට දාන්න
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Forgot Password clicked!"),
                          ),
                        );
                      },
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(color: primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
