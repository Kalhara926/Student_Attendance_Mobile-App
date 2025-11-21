import 'package:flutter/material.dart';
import 'package:student_attendance_app/models/timetable_model.dart';
import 'package:student_attendance_app/models/user_model.dart';
import 'package:student_attendance_app/screens/attendance_detail_screen.dart';
import 'package:student_attendance_app/services/auth_service.dart';
import 'package:student_attendance_app/services/database_service.dart';
import 'package:student_attendance_app/screens/timetable_screen.dart';

// --- අලුතින් import කළ screens ---
import 'attendance_history_screen.dart';

import 'package:student_attendance_app/screens/profile_screen.dart';

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
        // Get user data and live lecture data at the same time
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
          child: _isLoading
              ? _buildLoadingState()
              : _userModel == null
              ? _buildErrorState()
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildLiveLectureCard(),
                      const SizedBox(height: 24),
                      _buildMenuGrid(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Could not load user data. Please check your connection and try again.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _loadAllData, child: const Text("Retry")),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    String firstName = _userModel?.name.split(' ').first ?? 'User';
    if (firstName.isEmpty) firstName = 'User';

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
              'Welcome to Your Portal',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
          },
          child: CircleAvatar(
            radius: 28,
            backgroundColor: Colors.blue.shade100,
            backgroundImage:
                _userModel?.profilePicUrl != null &&
                    _userModel!.profilePicUrl.isNotEmpty
                ? NetworkImage(_userModel!.profilePicUrl)
                : null,
            child:
                _userModel?.profilePicUrl == null ||
                    _userModel!.profilePicUrl.isEmpty
                ? Icon(Icons.person, size: 32, color: Colors.blue.shade700)
                : null,
          ),
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
          MaterialPageRoute(builder: (_) => const AttendanceDetailScreen()),
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
            // ===================================================================
            // ==== වැරදි URL එක වෙනුවට, test කිරීම සඳහා ක්‍රියාත්මක වන URL එකක් යෙදුවා ====
            // ===================================================================
            Image.network(
              'https://picsum.photos/seed/lecture/600/300', // <-- ක්‍රියාත්මක වන URL එකක්
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder:
                  (
                    BuildContext context,
                    Widget child,
                    ImageChunkEvent? loadingProgress,
                  ) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 150,
                      color: Colors.grey[300],
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
              errorBuilder: (context, error, stackTrace) {
                print("Image load error: $error"); // Error එක print කරලා බලන්න
                return Container(
                  height: 150,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: Colors.grey,
                      size: 40,
                    ),
                  ),
                );
              },
            ),
            // ===================================================================
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
                    children: [
                      const Text(
                        "PRESENT", // This should be dynamic
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _calculateRemainingTime(),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _calculateProgress(),
                      minHeight: 6,
                      backgroundColor: const Color(0xFFE0E0E0),
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

  double _calculateProgress() {
    if (_liveLecture == null) return 0.0;
    final now = DateTime.now();
    final totalDuration = _liveLecture!.endTime.difference(
      _liveLecture!.startTime,
    );
    final elapsedDuration = now.difference(_liveLecture!.startTime);

    if (totalDuration.inMilliseconds <= 0) return 1.0;
    double progress =
        elapsedDuration.inMilliseconds / totalDuration.inMilliseconds;
    return progress.clamp(0.0, 1.0);
  }

  String _calculateRemainingTime() {
    if (_liveLecture == null) return "";
    final now = DateTime.now();
    final remaining = _liveLecture!.endTime.difference(now);

    if (remaining.isNegative) {
      return "Finished";
    }
    if (remaining.inHours > 0) {
      return "${remaining.inHours}h ${remaining.inMinutes.remainder(60)}m remaining";
    }
    return "${remaining.inMinutes}m remaining";
  }

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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Grades feature coming soon!")),
            );
          },
        ),
        _buildMenuCard(
          icon: Icons.person_outline,
          title: "My Profile",
          subtitle: "Settings & Info",
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
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
