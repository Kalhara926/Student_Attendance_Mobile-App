// lib/models/timetable_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TimeSlot {
  final String subjectName;
  final String code; // subjectCode එකක් නැති නිසා default අගයක් යොදමු
  final String room;
  final String time;
  final DateTime startTime; // ගණනය කිරීම් සඳහා DateTime object එකක් ලෙස
  final DateTime endTime; // ගණනය කිරීම් සඳහා DateTime object එකක් ලෙස

  TimeSlot({
    required this.subjectName,
    required this.code,
    required this.room,
    required this.time,
    required this.startTime,
    required this.endTime,
  });

  // Firestore document එකකින් TimeSlot object එකක් සාදන factory method එක
  factory TimeSlot.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Firestore Timestamp objects, Dart DateTime objects බවට පත් කරනවා
    final DateTime startTimeDt = (data['startTime'] as Timestamp).toDate();
    final DateTime endTimeDt = (data['endTime'] as Timestamp).toDate();

    // වේලාව "7:00 AM - 12:00 PM" වැනි string එකක් ලෙස format කරනවා
    final timeFormatter = DateFormat('h:mm a');
    final formattedTime =
        '${timeFormatter.format(startTimeDt)} - ${timeFormatter.format(endTimeDt)}';

    return TimeSlot(
      subjectName: data['subjectName'] ?? 'Unknown Subject',
      code:
          data['subjectCode'] ??
          'N/A', // Firestore එකේ 'subjectCode' නැති නිසා 'N/A' යොදනවා
      room: data['roomNo'] ?? 'N/A', // Firestore එකේ field නම 'roomNo'
      time: formattedTime, // UI එකේ පෙන්වීමට format කළ වේලාව
      startTime: startTimeDt,
      endTime: endTimeDt,
    );
  }

  static fromTimetable(QueryDocumentSnapshot<Map<String, dynamic>> doc) {}
}
