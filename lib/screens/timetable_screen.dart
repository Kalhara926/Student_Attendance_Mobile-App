import 'package:flutter/material.dart';
import 'package:student_attendance_app/models/timetable_model.dart';
import 'package:student_attendance_app/services/auth_service.dart';
import 'package:student_attendance_app/services/database_service.dart';

class MyTimetableScreen extends StatefulWidget {
  const MyTimetableScreen({super.key});

  @override
  State<MyTimetableScreen> createState() => _MyTimetableScreenState();
}

class _MyTimetableScreenState extends State<MyTimetableScreen> {
  final DatabaseService _dbService = DatabaseService();
  final AuthService _authService = AuthService();

  // State variables
  bool _isLoading = true;
  String _errorMessage = "";
  // Timetable දත්ත තබාගැනීමට Map එකක්
  Map<String, List<TimeSlot>> _timetable = {};

  // TabBar එක සඳහා දවස් ලැයිස්තුව
  final List<String> _days = const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    _fetchTimetable();
  }

  // Firestore එකෙන් Timetable එක ලබාගන්නා function එක
  Future<void> _fetchTimetable() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    final user = _authService.getCurrentUser();
    if (user == null) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = "User not logged in.";
      });
      return;
    }

    try {
      // DatabaseService එකේ getTimetable function එක call කරනවා
      final data = await _dbService.getTimetable(user.uid);
      if (!mounted) return;
      setState(() {
        _timetable = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to load timetable. Please try again.";
      });
      print("Error fetching timetable: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // අද දවසට අදාළ tab එක default ලෙස select කිරීමට
    int initialTabIndex = DateTime.now().weekday - 1;
    if (initialTabIndex < 0 || initialTabIndex > 6) {
      initialTabIndex = 0; // Failsafe
    }

    return DefaultTabController(
      length: _days.length,
      initialIndex: initialTabIndex,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Timetable'),
          bottom: TabBar(
            isScrollable: true,
            tabs: _days.map((day) => Tab(text: day)).toList(),
          ),
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
            : TabBarView(
                children: _days.map((day) {
                  // අදාළ දවසේ දේශන ලැයිස්තුව ලබාගන්නවා
                  final slotsForDay = _timetable[day] ?? [];
                  return _buildDaySchedule(slotsForDay);
                }).toList(),
              ),
      ),
    );
  }

  // දවසකට අදාළ දේශන ලැයිස්තුව පෙන්වන Widget එක
  Widget _buildDaySchedule(List<TimeSlot> slots) {
    if (slots.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 50, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No classes scheduled for this day.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];
        return _buildLectureCard(slot);
      },
    );
  }

  // එක දේශනයක විස්තර පෙන්වන card එක
  Widget _buildLectureCard(TimeSlot slot) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // වේලාව පෙන්වන කොටස
            Column(
              children: [
                Text(
                  slot.time.split('-')[0].trim(), // "9:00 AM"
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Text('-', style: TextStyle(color: Colors.grey)),
                Text(
                  slot.time.split('-')[1].trim(), // "10:30 AM"
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
            // සිරස් ඉර
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                height: 60, // Adjust height as needed
                child: VerticalDivider(thickness: 2, color: Colors.blue),
              ),
            ),
            // දේශනයේ විස්තර
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slot.subjectName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Room: ${slot.room}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 2),
                  if (slot.code != 'N/A')
                    Text(
                      'Code: ${slot.code}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
