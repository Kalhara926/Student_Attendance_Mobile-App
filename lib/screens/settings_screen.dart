// lib/screens/settings_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // User data සඳහා State variables
  bool _isLoading = true;
  String _errorMessage = "";
  String _userName = "User";
  String _studentId = "ST-xxxx";
  String _degreeAndYear = "Loading...";
  String? _profilePicUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Firestore එකෙන් user දත්ත ලබාගන්නා function එක
  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = "User not found. Please log in again.";
      });
      return;
    }

    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        if (!mounted) return;
        setState(() {
          _userName = data['name'] ?? 'No Name';
          _studentId = data['studentId'] ?? 'No ID';
          // 'degree' සහ 'yearSem' fields එකතු කර display string එක හදනවා
          final degree = data['degree'] ?? 'Degree';
          final yearSem = data['yearSem'] ?? 'Year';
          _degreeAndYear = "$degree • $yearSem";
          _profilePicUrl = data['profilePicUrl'];
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage = "User profile does not exist.";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to load data: $e";
      });
    }
  }

  // Logout function එක
  Future<void> _signOut() async {
    // පරිශීලකයාගෙන් තහවුරු කිරීමක් ඉල්ලනවා (Good UX)
    final confirmLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // No
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Yes
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    // පරිශීලකයා 'Logout' තේරුවොත් පමණක්
    if (confirmLogout == true) {
      try {
        await FirebaseAuth.instance.signOut();
        // Logout වූ පසු, login screen එකට ගොස්, ඊට පෙර තිබූ සියලුම screens ඉවත් කරනවා
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (Route<dynamic> route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error signing out: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        backgroundColor: Colors.grey[50],
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(
              child: Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            )
          : _buildSettingsList(),
    );
  }

  Widget _buildSettingsList() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      children: [
        _buildUserProfileHeader(),
        const SizedBox(height: 20),
        _buildSectionHeader('Account'),
        _buildSettingsItem(Icons.person_outline, 'Profile', () {
          // TODO: Navigate to Profile Screen
        }),
        _buildSettingsItem(Icons.lock_outline, 'Change Password', () {
          // TODO: Navigate to Change Password Screen
        }),
        const SizedBox(height: 20),
        _buildSectionHeader('Preferences'),
        _buildSettingsItem(
          Icons.notifications_outlined,
          'Notification Settings',
          () {},
        ),
        _buildSettingsItem(Icons.shield_outlined, 'App Permissions', () {}),
        const SizedBox(height: 20),
        _buildSectionHeader('Support'),
        _buildSettingsItem(Icons.help_outline, 'Help & Support', () {}),
        _buildSettingsItem(Icons.description_outlined, 'Privacy Policy', () {}),
        const SizedBox(height: 40),
        _buildLogoutButton(),
        const SizedBox(height: 20),
        _buildFooter(),
        const SizedBox(height: 20),
      ],
    );
  }

  // --- Helper Widgets ---

  Widget _buildUserProfileHeader() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 10),
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Colors.grey[300],
        backgroundImage: _profilePicUrl != null && _profilePicUrl!.isNotEmpty
            ? NetworkImage(_profilePicUrl!)
            : null,
        child: _profilePicUrl == null || _profilePicUrl!.isEmpty
            ? Icon(Icons.person, size: 30, color: Colors.grey[600])
            : null,
      ),
      title: Text(
        _userName,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            'Student ID: $_studentId',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 2),
          Text(_degreeAndYear, style: const TextStyle(color: Colors.blue)),
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // Navigate to profile edit screen
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.grey[600],
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.grey[800]),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutButton() {
    return OutlinedButton.icon(
      icon: const Icon(Icons.logout),
      label: const Text('Logout'),
      onPressed: _signOut,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red,
        side: BorderSide(color: Colors.red.withOpacity(0.3)),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'AttendanceApp v2.1.0',
          style: TextStyle(color: Colors.grey[500], fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          '© 2025 University System',
          style: TextStyle(color: Colors.grey[500], fontSize: 12),
        ),
      ],
    );
  }
}
