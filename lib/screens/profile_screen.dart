import 'package:flutter/material.dart';
import 'package:student_attendance_app/models/user_model.dart';
import 'package:student_attendance_app/services/auth_service.dart';
import 'package:student_attendance_app/services/database_service.dart';

import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();
  UserModel? _userModel;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    final user = _authService.getCurrentUser();
    if (user != null) {
      final userData = await _dbService.getUserFromDb(user.uid);
      setState(() {
        _userModel = userData;
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              /* TODO: Implement Edit Profile */
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userModel == null
          ? const Center(child: Text("Could not load user data."))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Profile Header
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _userModel!.profilePicUrl.isNotEmpty
                        ? NetworkImage(_userModel!.profilePicUrl)
                        : null,
                    child: _userModel!.profilePicUrl.isEmpty
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _userModel!.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Student ID: ${_userModel!.studentId}",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 30),

                  // Personal Details
                  _buildInfoCard(
                    title: "Personal Details",
                    details: {
                      Icons.email: _userModel!.email,
                      Icons.phone: _userModel!.phone,
                      Icons.calendar_today: _userModel!.dob,
                    },
                  ),
                  const SizedBox(height: 20),

                  // Academic Information
                  _buildInfoCard(
                    title: "Academic Information",
                    details: {
                      Icons.school: _userModel!.degree,
                      Icons.book: _userModel!.yearSem,
                      Icons.check_circle_outline: "Active",
                    },
                  ),
                  const SizedBox(height: 20),

                  // Security
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.lock, color: Colors.blue),
                      title: const Text("Change Password"),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        /* TODO: Implement Change Password */
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required Map<IconData, String> details,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...details.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Icon(entry.key, color: Colors.grey[600], size: 20),
                    const SizedBox(width: 16),
                    Text(entry.value, style: const TextStyle(fontSize: 16)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
