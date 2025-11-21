import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/lecture_model.dart';
import 'live_tracking_screen.dart';

class AttendanceDetailScreen extends StatefulWidget {
  const AttendanceDetailScreen({super.key});

  @override
  State<AttendanceDetailScreen> createState() => _AttendanceDetailScreenState();
}

class _AttendanceDetailScreenState extends State<AttendanceDetailScreen> {
  // --- UI State Variables ---
  bool isLocationVerified = false; // UI එකේ තත්ත්වය පාලනය කරයි
  bool isFingerprintVerified = false;
  bool isFaceVerified = false;
  String fingerprintTime = "";

  // --- Data Loading and Submission State ---
  bool _isLoading = true;
  String _errorMessage = "";
  bool _isConfirming = false; // "Confirm Attendance" button එකට loading state

  // --- User and Lecture Data ---
  String? _studentId;
  String _studentName = "Student";
  Lecture? _liveLecture;
  bool _isFetchingLecture = true;

  // --- Firebase Subscriptions ---
  StreamSubscription<DatabaseEvent>? _attendanceSubscription;
  StreamSubscription<DatabaseEvent>? _faceSubscription;

  @override
  void initState() {
    super.initState();
    _loadStudentDataAndSetupListeners();
  }

  @override
  void dispose() {
    _attendanceSubscription?.cancel();
    _faceSubscription?.cancel();
    super.dispose();
  }

  // --- Data Fetching and Listener Setup ---
  Future<void> _loadStudentDataAndSetupListeners() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = "User not logged in.";
      });
      return;
    }

    try {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists && mounted) {
        final userData = docSnapshot.data()!;
        if (userData['studentId'] != null) {
          setState(() {
            _studentId = userData['studentId'];
            _studentName = userData['name'] ?? "Student";
            _isLoading = false;
          });
          // Setup listeners after student ID is confirmed
          _listenToFingerprint();
          _listenToFaceDetection();
          _fetchLiveLecture();
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = "Student ID not found in your profile.";
          });
        }
      } else {
        if (mounted)
          setState(() {
            _isLoading = false;
            _errorMessage = "User profile not found.";
          });
      }
    } catch (e) {
      if (mounted)
        setState(() {
          _isLoading = false;
          _errorMessage = "Error loading data: ${e.toString()}";
        });
    }
  }

  Future<void> _fetchLiveLecture() async {
    setState(() => _isFetchingLecture = true);
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('lectures')
          .where('status', isEqualTo: 'live')
          .limit(1)
          .get();

      if (mounted) {
        setState(() {
          if (querySnapshot.docs.isNotEmpty) {
            _liveLecture = Lecture.fromFirestore(querySnapshot.docs.first);
          }
          _isFetchingLecture = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isFetchingLecture = false);
      print("Error fetching live lecture: $e");
    }
  }

  void _listenToFingerprint() {
    if (_studentId == null) return;
    final attendanceRef = FirebaseDatabase.instance.ref(
      'attendance/$_studentId',
    );
    _attendanceSubscription = attendanceRef.onValue.listen((event) {
      if (!mounted) return;
      bool fpVerified = false;
      String fpTime = "";
      if (event.snapshot.exists && event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        if (data['present'] == true && data['source'] == 'fingerprint') {
          fpVerified = true;
          try {
            fpTime =
                "Verified at ${TimeOfDay.fromDateTime(DateTime.parse(data['timestamp'])).format(context)}";
          } catch (_) {
            fpTime = "Verified";
          }
        }
      }
      setState(() {
        isFingerprintVerified = fpVerified;
        fingerprintTime = fpTime;
      });
    });
  }

  void _listenToFaceDetection() {
    if (_studentId == null) return;
    final faceRef = FirebaseDatabase.instance.ref('face_detection/$_studentId');
    _faceSubscription = faceRef.onValue.listen((event) {
      if (!mounted) return;
      bool faceVerified = false;
      if (event.snapshot.exists && event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        if (data['confidence'] != null && data['confidence'] > 0.4) {
          faceVerified = true;
        }
      }
      setState(() => isFaceVerified = faceVerified);
    });
  }

  // --- Navigation and Data Submission ---
  void _navigateToLiveTracking() async {
    if (_studentId == null) return;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => LiveTrackingScreen(studentId: _studentId),
      ),
    );

    if (result == true && mounted) {
      setState(() {
        isLocationVerified = true;
      });
    }
  }

  Future<void> _confirmFinalAttendance() async {
    if (_studentId == null || _liveLecture == null) return;
    setState(() => _isConfirming = true);

    try {
      final WriteBatch batch = FirebaseFirestore.instance.batch();

      // 1. Create Attendance Record
      final attendanceRecordRef = FirebaseFirestore.instance
          .collection('student_attendance')
          .doc(_studentId)
          .collection('lectures')
          .doc(_liveLecture!.id);

      batch.set(attendanceRecordRef, {
        'studentId': _studentId,
        'lectureId': _liveLecture!.id,
        'subjectName': _liveLecture!.subjectName,
        'status': 'Present',
        'confirmedAt': FieldValue.serverTimestamp(),
        'verificationMethods': {
          'location': isLocationVerified,
          'fingerprint': isFingerprintVerified,
          'face': isFaceVerified,
        },
      });

      // 2. Create Location Log
      final locationLogRef = FirebaseFirestore.instance
          .collection('location_logs')
          .doc(_studentId)
          .collection('logs')
          .doc(); // Auto-ID

      batch.set(locationLogRef, {
        'inside_geofence': isLocationVerified,
        'subjectName': _liveLecture!.subjectName,
        'roomNo': _liveLecture!.roomNo,
        'loggedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Attendance Confirmed & Logged!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to confirm attendance: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isConfirming = false);
    }
  }

  // --- Build Methods ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Attendance"),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : _buildMainContent(),
    );
  }

  Widget _buildMainContent() {
    bool allVerified =
        isLocationVerified && isFingerprintVerified && isFaceVerified;

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Today's Classes",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _isFetchingLecture
                    ? const Center(child: CircularProgressIndicator())
                    : _liveLecture != null
                    ? _buildLiveClassCard(allVerified: allVerified)
                    : const Card(
                        child: ListTile(
                          leading: Icon(Icons.info_outline),
                          title: Text("No live class at the moment."),
                          subtitle: Text("Please check back later or refresh."),
                        ),
                      ),
                const SizedBox(height: 30),
                const Text(
                  "Live Tracking Status",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildStatusCard(
                  title: "Location Tracking",
                  subtitle: isLocationVerified
                      ? "Location confirmed"
                      : "Tap to verify your location",
                  icon: Icons.location_on,
                  isVerified: isLocationVerified,
                  statusText: isLocationVerified ? "VERIFIED" : null,
                  onTap: _navigateToLiveTracking,
                ),
                _buildStatusCard(
                  title: "Fingerprint",
                  subtitle: isFingerprintVerified
                      ? fingerprintTime
                      : "Awaiting verification...",
                  icon: Icons.fingerprint,
                  isVerified: isFingerprintVerified,
                ),
                _buildStatusCard(
                  title: "Face Recognition",
                  subtitle: isFaceVerified
                      ? "Verification successful"
                      : "Random verification pending",
                  icon: Icons.face_retouching_natural,
                  isVerified: isFaceVerified,
                  isSpecial: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      color: Colors.deepPurple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Good Morning, $_studentName",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Today's Attendance",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "85%",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Text(
                      "This Week",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "4/5 Classes",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveClassCard({required bool allVerified}) {
    final timeFormatter = DateFormat('h:mm a');
    final startTime = timeFormatter.format(_liveLecture!.startTime);
    final endTime = timeFormatter.format(_liveLecture!.endTime);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  "LIVE",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                Text("$startTime - $endTime"),
                const Spacer(),
                Icon(
                  Icons.check_circle,
                  color: allVerified ? Colors.green : Colors.grey[300],
                ),
                const SizedBox(width: 5),
                Text(
                  allVerified ? "Present" : "Pending",
                  style: TextStyle(
                    color: allVerified ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              _liveLecture!.subjectName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Text(
                  "${_liveLecture!.profName} • ${_liveLecture!.roomNo}",
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const Spacer(),
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: isLocationVerified ? Colors.green : Colors.grey,
                ),
                Text(
                  isLocationVerified ? " In-Class" : " Away",
                  style: TextStyle(
                    color: isLocationVerified ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
            if (isFingerprintVerified) ...[
              const SizedBox(height: 10),
              Row(
                children: const [
                  Icon(Icons.fingerprint, size: 16, color: Colors.green),
                  Text(
                    " Fingerprint Confirmed",
                    style: TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: allVerified && !_isConfirming
                  ? _confirmFinalAttendance
                  : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: _isConfirming
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Confirm Attendance",
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isVerified,
    String? statusText,
    bool isSpecial = false,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: isVerified ? Colors.green[50] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: isVerified ? Colors.green : Colors.grey[300]!),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: isVerified
              ? Colors.green
              : (isSpecial ? Colors.blue : Colors.grey),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
        trailing: isSpecial
            ? const Icon(Icons.shield, color: Colors.blue)
            : (statusText != null
                  ? Text(
                      statusText,
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : (isVerified
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : (onTap != null
                              ? const Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey,
                                )
                              : null))),
      ),
    );
  }
}
