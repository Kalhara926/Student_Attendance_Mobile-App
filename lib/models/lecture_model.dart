// lib/models/lecture_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Lecture {
  final String id;
  final String subjectName;
  final String profName; // 'professorName' වෙනුවට
  final String roomNo; // 'roomNumber' වෙනුවට
  final DateTime startTime; // 'String' වෙනුවට 'DateTime'
  final DateTime endTime; // 'String' වෙනුවට 'DateTime'
  final String status;

  Lecture({
    required this.id,
    required this.subjectName,
    required this.profName,
    required this.roomNo,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  factory Lecture.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Lecture(
      id: doc.id,
      subjectName: data['subjectName'] ?? 'Unknown Subject',
      profName: data['profName'] ?? 'N/A', // field name වෙනස් කළා
      roomNo: data['roomNo'] ?? 'N/A', // field name වෙනස් කළා
      // Firestore Timestamp එක DateTime එකක් බවට පත් කරනවා
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      status: data['status'] ?? '',
    );
  }
}
