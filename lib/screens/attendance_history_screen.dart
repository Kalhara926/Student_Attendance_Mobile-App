// lib/screens/attendance_history_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// ඔබගේ project එකේ නම නිවැරදිව යොදන්න
import 'package:student_attendance_app/models/attendance_record_model.dart';
import 'package:student_attendance_app/models/subject_summary_model.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  final String studentId;
  const AttendanceHistoryScreen({super.key, required this.studentId});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  bool _isLoading = true;
  String _errorMessage = "";

  // Processed data variables
  int _overallPresent = 0;
  int _overallTotal = 0;
  List<SubjectSummary> _subjectSummaries = [];
  Map<String, List<AttendanceRecord>> _dailyLogs = {};

  @override
  void initState() {
    super.initState();
    _fetchAndProcessHistory();
  }

  Future<void> _fetchAndProcessHistory() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('student_attendance')
          .doc(widget.studentId)
          .collection('lectures')
          .orderBy('confirmedAt', descending: true)
          .get();

      if (querySnapshot.docs.isEmpty) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage = "No attendance records found.";
        });
        return;
      }

      // --- Data Processing Logic ---
      List<AttendanceRecord> allRecords = querySnapshot.docs
          .map((doc) => AttendanceRecord.fromFirestore(doc))
          .toList();

      int presentCount = 0;
      Map<String, SubjectSummary> subjectSummaryMap = {};
      Map<String, List<AttendanceRecord>> dailyLogsMap = {};

      for (var record in allRecords) {
        // Overall count
        if (record.status == 'Present') {
          presentCount++;
        }

        // Subject-wise summary
        if (!subjectSummaryMap.containsKey(record.subjectName)) {
          subjectSummaryMap[record.subjectName] = SubjectSummary(
            subjectName: record.subjectName,
          );
        }
        subjectSummaryMap[record.subjectName]!.totalClasses++;
        if (record.status == 'Present') {
          subjectSummaryMap[record.subjectName]!.presentCount++;
        }

        // Daily log timeline
        String dateKey = _formatDateForGrouping(record.confirmedAt);
        if (!dailyLogsMap.containsKey(dateKey)) {
          dailyLogsMap[dateKey] = [];
        }
        dailyLogsMap[dateKey]!.add(record);
      }
      // --- End of Data Processing ---

      if (!mounted) return;
      setState(() {
        _overallPresent = presentCount;
        _overallTotal = allRecords.length;
        _subjectSummaries = subjectSummaryMap.values.toList();
        _dailyLogs = dailyLogsMap;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to load history: $e";
      });
    }
  }

  String _formatDateForGrouping(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final recordDate = DateTime(date.year, date.month, date.day);

    if (recordDate == today) {
      return 'Today, ${DateFormat('MMM d').format(date)}';
    } else if (recordDate == yesterday) {
      return 'Yesterday, ${DateFormat('MMM d').format(date)}';
    } else {
      return DateFormat('EEEE, MMM d').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Attendance History'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
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
          : _buildHistoryList(),
    );
  }

  Widget _buildHistoryList() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildOverallSummary(),
        const SizedBox(height: 24),
        _buildSubjectSummary(),
        const SizedBox(height: 24),
        _buildDailyTimeline(),
        const SizedBox(height: 24),
        _buildRandomVerificationHistory(), // Placeholder
      ],
    );
  }

  // --- Helper Widgets for each section ---

  Widget _buildOverallSummary() {
    double overallPercentage = _overallTotal == 0
        ? 0.0
        : (_overallPresent / _overallTotal) * 100;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: const LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Attendance',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Current Semester',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${overallPercentage.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Present Days',
                        style: TextStyle(color: Colors.white70),
                      ),
                      Text(
                        '$_overallPresent/$_overallTotal',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Card(
                elevation: 0,
                color: Colors.green[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green[700]),
                          const SizedBox(width: 8),
                          const Text('Present'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$_overallPresent',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Card(
                elevation: 0,
                color: Colors.red[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.cancel, color: Colors.red[700]),
                          const SizedBox(width: 8),
                          const Text('Absent'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_overallTotal - _overallPresent}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubjectSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Subject-wise Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(onPressed: () {}, child: const Text('View All')),
          ],
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _subjectSummaries.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final summary = _subjectSummaries[index];
            Color progressColor = summary.percentage >= 80
                ? Colors.green
                : (summary.percentage >= 50 ? Colors.orange : Colors.red);
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey[200]!),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          summary.subjectName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${summary.percentage.toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: progressColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${summary.presentCount}/${summary.totalClasses} classes',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        Text(
                          '${summary.totalClasses - summary.presentCount} absents',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: summary.percentage / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                      minHeight: 6,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDailyTimeline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Daily Log Timeline',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(onPressed: () {}, child: const Text('Filter')),
          ],
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _dailyLogs.keys.length,
          itemBuilder: (context, index) {
            String dateKey = _dailyLogs.keys.elementAt(index);
            List<AttendanceRecord> recordsForDate = _dailyLogs[dateKey]!;
            bool isAllPresent = !recordsForDate.any(
              (r) => r.status != 'Present',
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    children: [
                      Text(
                        dateKey,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const Spacer(),
                      if (isAllPresent)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Present',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey[200]!),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recordsForDate.length,
                    separatorBuilder: (context, i) =>
                        const Divider(height: 1, indent: 16, endIndent: 16),
                    itemBuilder: (context, i) {
                      final record = recordsForDate[i];
                      bool isPresent = record.status == 'Present';
                      final time = DateFormat(
                        'h:mm a',
                      ).format(record.confirmedAt);

                      // Build verification string
                      List<String> methods = [];
                      if (record.verificationMethods['fingerprint'] == true)
                        methods.add('Fingerprint');
                      if (record.verificationMethods['location'] == true)
                        methods.add('Location');
                      if (record.verificationMethods['face'] == true)
                        methods.add('Face');
                      String verificationString = methods.isEmpty
                          ? 'Verification failed'
                          : methods.join(' + ') + ' verified';

                      return ListTile(
                        leading: Icon(
                          Icons.circle,
                          color: isPresent ? Colors.green : Colors.red,
                          size: 14,
                        ),
                        title: Text(
                          record.subjectName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '$time - $verificationString',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        trailing: Icon(
                          Icons.circle,
                          color: isPresent ? Colors.green : Colors.red,
                          size: 14,
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildRandomVerificationHistory() {
    // This is a placeholder as the data structure for this is not defined yet.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Random Verification History',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[200]!),
          ),
          child: const ListTile(
            leading: Icon(Icons.history_toggle_off),
            title: Text('More detailed logs coming soon'),
          ),
        ),
      ],
    );
  }
}
