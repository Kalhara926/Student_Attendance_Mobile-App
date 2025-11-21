// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:student_attendance_app/models/timetable_model.dart';
import 'package:student_attendance_app/models/user_model.dart';
import 'package:student_attendance_app/screens/attendance_detail_screen.dart';
import 'package:student_attendance_app/services/auth_service.dart';
import 'package:student_attendance_app/services/database_service.dart';
import 'package:student_attendance_app/screens/timetable_screen.dart';

// --- අලුතින් import කළ screens ---
import 'package:student_attendance_app/screens/attendance_history_screen.dart';
import 'package:student_attendance_app/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();

  UserModel? _userModel;
  TimeSlot? _liveLecture;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    final user = _authService.getCurrentUser();
    if (user != null) {
      try {
        final results = await Future.wait([
          _dbService.getUserFromDb(user.uid),
          _dbService.getCurrentLiveLecture(user.uid),
        ]);

        if (mounted) {
          setState(() {
            _userModel = results[0] as UserModel?;
            _liveLecture = results[1] as TimeSlot?;
          });
        }
      } catch (e) {
        print("Error loading data on home screen: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Failed to load data. Please try again."),
            ),
          );
        }
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadAllData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: _isLoading
                ? _buildLoadingState()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildLiveLectureCard(),
                      const SizedBox(height: 24),
                      _buildMenuGrid(), // <-- වෙනස්කම් ඇතුළත් function එක
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(heightFactor: 5, child: CircularProgressIndicator());
  }

  Widget _buildHeader() {
    String firstName = _userModel?.name.split(' ').first ?? 'User';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, $firstName',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Welcome to your dashboard',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
        CircleAvatar(
          radius: 24,
          backgroundImage:
              _userModel?.profilePicUrl != null &&
                  _userModel!.profilePicUrl.isNotEmpty
              ? NetworkImage(_userModel!.profilePicUrl)
              : null,
          child:
              _userModel?.profilePicUrl == null ||
                  _userModel!.profilePicUrl.isEmpty
              ? const Icon(Icons.person, size: 28)
              : null,
        ),
      ],
    );
  }

  Widget _buildLiveLectureCard() {
    if (_liveLecture == null) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 2,
        child: Container(
          padding: const EdgeInsets.all(24),
          width: double.infinity,
          child: Column(
            children: const [
              Icon(Icons.info_outline, color: Colors.blue, size: 32),
              SizedBox(height: 10),
              Text(
                "No live lectures at the moment.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            // AttendanceDetailScreen එකට තවදුරටත් lecture object එකක් pass කිරීම අවශ්‍ය නැත.
            // එය තමන්ට අවශ්‍ය දත්ත load කරගනී.
            builder: (_) => const AttendanceDetailScreen(),
          ),
        );
      },
      borderRadius: BorderRadius.circular(15),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/images/assets/images/Auditorium_cam01-02-1440x960.webp',
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 150,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.grey,
                      size: 40,
                    ),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Today's Live Lecture",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "${_liveLecture!.subjectName} (${_liveLecture!.code})",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text("${_liveLecture!.time} | ${_liveLecture!.room}"),
                  const SizedBox(height: 12),
                  Row(
                    children: const [
                      Text(
                        "PRESENT", // This needs to be dynamic based on actual status
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      Text(
                        "45 mins remaining", // This needs to be calculated
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: const LinearProgressIndicator(
                      value: 0.5, // This needs to be calculated
                      minHeight: 6,
                      backgroundColor: Color(0xFFE0E0E0),
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- යාවත්කාලීන කළ Menu Grid Widget එක ---
  Widget _buildMenuGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.25,
      children: [
        _buildMenuCard(
          icon: Icons.history_edu_outlined,
          title: "Attendance History",
          subtitle: "View past records",
          onTap: () {
            // Student ID එකක් තිබේදැයි පරීක්ෂා කරනවා
            if (_userModel?.studentId != null) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      AttendanceHistoryScreen(studentId: _userModel!.studentId),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Cannot open history. Student data not found."),
                ),
              );
            }
          },
        ),
        _buildMenuCard(
          icon: Icons.calendar_view_week_outlined,
          title: "My Timetable",
          subtitle: "Your weekly schedule",
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MyTimetableScreen()),
            );
          },
        ),
        _buildMenuCard(
          icon: Icons.bar_chart_outlined,
          title: "Academic Grades",
          subtitle: "Check your results",
          onTap: () {
            // TODO: Navigate to Grades Screen
          },
        ),
        _buildMenuCard(
          icon: Icons.settings_outlined,
          title: "Settings & Help",
          subtitle: "App preferences",
          onTap: () {
            // Settings Screen එකට navigate කරනවා
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
          },
        ),
      ],
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(icon, color: Colors.blue, size: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
