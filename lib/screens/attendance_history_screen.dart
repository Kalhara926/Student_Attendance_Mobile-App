import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:student_attendance_app/models/attendance_record_model.dart';
import 'package:student_attendance_app/models/subject_summary_model.dart';
// --- අලුතින් import කළ model එක ---
import 'package:student_attendance_app/models/location_log_model.dart';

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
  // --- Location logs ගබඩා කිරීමට අලුත් list එකක් ---
  List<LocationLog> _locationLogs = [];

  @override
  void initState() {
    super.initState();
    _fetchAndProcessHistory();
  }

  Future<void> _fetchAndProcessHistory() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      // Fetching attendance records and location logs in parallel
      final results = await Future.wait([
        FirebaseFirestore.instance
            .collection('student_attendance')
            .doc(widget.studentId)
            .collection('lectures')
            .orderBy('confirmedAt', descending: true)
            .get(),
        // --- Location logs fetch කරන query එක ---
        FirebaseFirestore.instance
            .collection('location_logs') // යෝජිත collection නම
            .doc(widget.studentId)
            .collection('logs')
            .orderBy('loggedAt', descending: true)
            .limit(5) // අන්තිම logs 5 පමණක් ගනිමු
            .get(),
      ]);

      // --- Process Attendance Records ---
      final attendanceSnapshot = results[0] as QuerySnapshot;
      if (attendanceSnapshot.docs.isEmpty) {
        // Handle case where no attendance records are found
      } else {
        List<AttendanceRecord> allRecords = attendanceSnapshot.docs
            .map((doc) => AttendanceRecord.fromFirestore(doc))
            .toList();

        int presentCount = 0;
        Map<String, SubjectSummary> subjectSummaryMap = {};
        Map<String, List<AttendanceRecord>> dailyLogsMap = {};

        for (var record in allRecords) {
          if (record.status.toLowerCase() == 'present') presentCount++;
          if (!subjectSummaryMap.containsKey(record.subjectName)) {
            subjectSummaryMap[record.subjectName] = SubjectSummary(
              subjectName: record.subjectName,
            );
          }
          subjectSummaryMap[record.subjectName]!.totalClasses++;
          if (record.status.toLowerCase() == 'present') {
            subjectSummaryMap[record.subjectName]!.presentCount++;
          }
          String dateKey = _formatDateForGrouping(record.confirmedAt);
          if (!dailyLogsMap.containsKey(dateKey)) dailyLogsMap[dateKey] = [];
          dailyLogsMap[dateKey]!.add(record);
        }

        _overallPresent = presentCount;
        _overallTotal = allRecords.length;
        _subjectSummaries = subjectSummaryMap.values.toList();
        _dailyLogs = dailyLogsMap;
      }

      // --- Process Location Logs ---
      final locationSnapshot = results[1] as QuerySnapshot;
      if (locationSnapshot.docs.isNotEmpty) {
        _locationLogs = locationSnapshot.docs
            .map((doc) => LocationLog.fromFirestore(doc))
            .toList();
      }

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        if (attendanceSnapshot.docs.isEmpty && locationSnapshot.docs.isEmpty) {
          _errorMessage = "No history records found.";
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to load history: $e";
        print("Error fetching history: $e");
      });
    }
  }

  String _formatDateForGrouping(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final recordDate = DateTime(date.year, date.month, date.day);

    if (recordDate == today)
      return 'Today, ${DateFormat('MMM d').format(date)}';
    if (recordDate == yesterday)
      return 'Yesterday, ${DateFormat('MMM d').format(date)}';
    return DateFormat('EEEE, MMM d').format(date);
  }

  @override
  Widget build(BuildContext context) {
    // ... (build method එකේ වෙනසක් නෑ, ඒක එහෙමම තියන්න)
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text('Attendance History'),
        backgroundColor: const Color(0xFFF7F8FC),
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchAndProcessHistory,
              child: _buildHistoryList(),
            ),
    );
  }

  Widget _buildHistoryList() {
    // ... (_buildHistoryList method එකේ වෙනසක් නෑ, ඒක එහෙමම තියන්න)
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      children: [
        const SizedBox(height: 10),
        _buildOverallSummary(),
        const SizedBox(height: 24),
        _buildSubjectSummary(),
        const SizedBox(height: 24),
        _buildDailyTimeline(),
        const SizedBox(height: 24),
        _buildRandomVerificationHistory(),
        const SizedBox(height: 24),
      ],
    );
  }

  // --- පහත ඇති _buildRandomVerificationHistory සහ ඊට අදාළ widgets පමණක් වෙනස් කරන්න ---

  // --- 4. Random Verification History කොටස (Placeholder UI) ---
  Widget _buildRandomVerificationHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Random Verification History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.info_outline, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Face Verification Logs (මෙය දැනට placeholder ලෙසම තබමු)
        _buildVerificationCard(
          title: 'Face Verification Logs',
          icon: Icons.face_retouching_natural_outlined,
          iconBgColor: Colors.blue[50]!,
          iconColor: Colors.blue[600]!,
          child: Column(
            children: [
              _verificationItem(
                'Mathematics Class',
                'Dec 15, 9:15 AM',
                'Verified',
                isPlaceholder: true,
              ),
              _verificationItem(
                'Physics Class',
                'Dec 15, 11:45 AM',
                'Verified',
                isPlaceholder: true,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // --- Location Verification (මෙම කොටස live data වලින් සාදමු) ---
        _buildVerificationCard(
          title: 'Location Verification',
          icon: Icons.location_on_outlined,
          iconBgColor: Colors.green[50]!,
          iconColor: Colors.green[700]!,
          child: _locationLogs.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(child: Text("No location logs found.")),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _locationLogs.length,
                  itemBuilder: (context, index) {
                    final log = _locationLogs[index];
                    final status = log.insideGeofence ? 'Valid' : 'Suspect';
                    final title = '${log.roomNo} - ${log.subjectName}';
                    final subtitle = DateFormat(
                      'MMM d, h:mm a',
                    ).format(log.loggedAt);

                    return _verificationItem(title, subtitle, status);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildVerificationCard({
    required String title,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          child, // <-- items list එක වෙනුවට child එකක් යෙදුවා
        ],
      ),
    );
  }

  Widget _verificationItem(
    String title,
    String subtitle,
    String status, {
    bool isPlaceholder = false,
  }) {
    Color statusColor;
    Color statusBgColor;

    switch (status.toLowerCase()) {
      case 'verified':
      case 'valid':
        statusColor = const Color(0xFF00BFA5);
        statusBgColor = const Color(0xFFE0F2F1);
        break;
      case 'suspect':
        statusColor = const Color(0xFFFB8C00);
        statusBgColor = const Color(0xFFFFF3E0);
        break;
      default:
        statusColor = Colors.grey;
        statusBgColor = Colors.grey[200]!;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          _buildStatusChip(
            text: status,
            bgColor: statusBgColor,
            textColor: statusColor,
          ),
        ],
      ),
    );
  }

  // --- පහත ඇති අනෙකුත් widgets වල වෙනසක් නැත ---
  // ... _buildStatusChip, _buildOverallSummary, _buildSubjectSummary etc.
  // ඒවා ඔබගේ ගොනුවේ ඇති ආකාරයටම තබන්න.
  // මෙහි සම්පූර්ණත්වය සඳහා ඒවා නැවත paste කරමි.

  Widget _buildStatusChip({
    required String text,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // --- 1. My Attendance කොටස ---
  Widget _buildOverallSummary() {
    double overallPercentage = _overallTotal == 0
        ? 0.0
        : (_overallPresent / _overallTotal) * 100;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: const LinearGradient(
              colors: [Color(0xFF4835DD), Color(0xFF9431E4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
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
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Current Semester',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Overall Attendance',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      Text(
                        '${overallPercentage.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Present Days',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      Text(
                        '$_overallPresent/$_overallTotal',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
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
              child: _buildSummaryCard(
                icon: Icons.check_circle_outline,
                title: 'Present',
                count: '$_overallPresent',
                iconColor: const Color(0xFF00BFA5),
                backgroundColor: const Color(0xFFE0F2F1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                icon: Icons.highlight_off,
                title: 'Absent',
                count: '${_overallTotal - _overallPresent}',
                iconColor: const Color(0xFFEF5350),
                backgroundColor: const Color(0xFFFFEBEE),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String count,
    required Color iconColor,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              Text(
                count,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 2. Subject-wise Summary කොටස ---
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
            TextButton(
              onPressed: () {},
              child: const Text(
                'View All',
                style: TextStyle(color: Color(0xFF4835DD)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _subjectSummaries.length,
            padding: EdgeInsets.zero,
            separatorBuilder: (context, index) =>
                const Divider(height: 1, indent: 16, endIndent: 16),
            itemBuilder: (context, index) {
              final summary = _subjectSummaries[index];
              Color progressColor = summary.percentage >= 80
                  ? const Color(0xFF00C853) // Green
                  : (summary.percentage >= 50
                        ? const Color(0xFFFB8C00) // Orange
                        : const Color(0xFFE53935)); // Red

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          summary.subjectName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
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
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '${summary.totalClasses - summary.presentCount} absents',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: summary.percentage / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progressColor,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- 3. Daily Log Timeline කොටස ---
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
            TextButton(
              onPressed: () {},
              child: const Text(
                'Filter',
                style: TextStyle(color: Color(0xFF4835DD)),
              ),
            ),
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

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 16.0,
                    bottom: 8.0,
                    left: 4.0,
                  ),
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
                      if (recordsForDate.any(
                        (r) => r.status.toLowerCase() == 'present',
                      ))
                        _buildStatusChip(
                          text: 'Present',
                          bgColor: const Color(0xFFE0F2F1),
                          textColor: const Color(0xFF00BFA5),
                        ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: recordsForDate.length,
                    separatorBuilder: (context, i) =>
                        const Divider(height: 1, indent: 50, endIndent: 16),
                    itemBuilder: (context, i) {
                      final record = recordsForDate[i];
                      bool isPresent = record.status.toLowerCase() == 'present';
                      final time = DateFormat(
                        'h:mm a',
                      ).format(record.confirmedAt);

                      // Verification methods string එක හදනවා
                      List<String> methods = [];
                      if (record.verificationMethods['fingerprint'] == true) {
                        methods.add('Fingerprint');
                      }
                      if (record.verificationMethods['face'] == true) {
                        methods.add('Face');
                      }
                      if (record.verificationMethods['location'] == true) {
                        methods.add('Location');
                      }

                      String verificationString;
                      if (methods.isEmpty && isPresent) {
                        verificationString = 'Verified';
                      } else if (methods.isEmpty && !isPresent) {
                        verificationString = 'Absent';
                      } else {
                        verificationString = methods.join(' + ') + ' verified';
                      }

                      return ListTile(
                        leading: Icon(
                          Icons.circle,
                          color: isPresent ? Colors.green : Colors.red,
                          size: 12,
                        ),
                        title: Text(
                          record.subjectName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '$time - $verificationString',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                        trailing: Icon(
                          isPresent ? Icons.check_circle : Icons.cancel,
                          color: isPresent ? Colors.green : Colors.red,
                          size: 20,
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
}
