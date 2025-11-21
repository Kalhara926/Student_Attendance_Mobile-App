import 'package:flutter/material.dart';
import 'package:student_attendance_app/models/user_model.dart';
import 'package:student_attendance_app/services/auth_service.dart';
import '../services/database_service.dart';

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
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    final user = _authService.getCurrentUser();
    if (user != null) {
      final userData = await _dbService.getUserFromDb(user.uid);
      if (mounted) {
        setState(() {
          _userModel = userData;
        });
      }
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    await _authService.signOut();
    if (mounted) {
      // Navigate to LoginScreen and remove all previous routes
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Changed background color
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: "Edit Profile",
            onPressed: () {
              // TODO: Implement Edit Profile Navigation
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Edit profile feature coming soon!"),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: "Logout",
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userModel == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Could not load user data."),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _loadUserData,
                    child: const Text("Try Again"),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadUserData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // --- Profile Header ---
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blue.shade100,
                      backgroundImage: _userModel!.profilePicUrl.isNotEmpty
                          ? NetworkImage(_userModel!.profilePicUrl)
                          : null,
                      child: _userModel!.profilePicUrl.isEmpty
                          ? Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.blue.shade800,
                            )
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _userModel!.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Student ID: ${_userModel!.studentId}",
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 30),

                    // --- Personal Details ---
                    _buildInfoCard(
                      title: "Personal Details",
                      details: {
                        Icons.email_outlined: _userModel!.email,
                        Icons.phone_outlined: _userModel!.phone,
                        Icons.calendar_today_outlined: _userModel!.dob,
                      },
                    ),
                    const SizedBox(height: 20),

                    // --- Academic Information ---
                    _buildInfoCard(
                      title: "Academic Information",
                      details: {
                        Icons.school_outlined: _userModel!.degree,
                        Icons.book_outlined: _userModel!.yearSem,
                        Icons.check_circle_outline: "Active", // Status
                      },
                    ),
                    const SizedBox(height: 20),

                    // --- Security Section ---
                    Card(
                      elevation: 2,
                      shadowColor: Colors.black.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: Icon(
                          Icons.lock_outline,
                          color: Colors.blue.shade700,
                        ),
                        title: const Text("Change Password"),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // TODO: Implement Change Password Navigation
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Change password feature coming soon!",
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  /// Information card widget (Updated with better UI and logic)
  Widget _buildInfoCard({
    required String title,
    required Map<IconData, String> details,
  }) {
    // Filter out empty or "Not Provided" entries
    final validEntries = details.entries
        .where(
          (entry) => entry.value.isNotEmpty && entry.value != 'Not Provided',
        )
        .toList();

    // If there are no valid details to show, don't build the card
    if (validEntries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
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
            const Divider(height: 20, thickness: 1),
            // Build the list of details from the filtered list
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: validEntries.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final entry = validEntries[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(entry.key, color: Colors.grey[600], size: 20),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
