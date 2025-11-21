// lib/models/attendance_record_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceRecord {
  final String subjectName;
  final String status;
  final DateTime confirmedAt;
  final Map<String, dynamic> verificationMethods;

  AttendanceRecord({
    required this.subjectName,
    required this.status,
    required this.confirmedAt,
    required this.verificationMethods,
  });

  factory AttendanceRecord.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AttendanceRecord(
      subjectName: data['subjectName'] ?? 'Unknown Subject',
      status: data['status'] ?? 'Absent',
      confirmedAt: (data['confirmedAt'] as Timestamp).toDate(),
      verificationMethods: data['verificationMethods'] ?? {},
    );
  }
}
