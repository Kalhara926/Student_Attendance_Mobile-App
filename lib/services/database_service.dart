// lib/services/database_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_attendance_app/models/timetable_model.dart';
import 'package:student_attendance_app/models/user_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// --- 'createUserInDb' function එක (යාවත්කාලීන කරන ලදී) ---
  /// Register වන user ගේ විස්තර 'users' collection එකේ document එකක් ලෙස සාදයි.
  Future<void> createUserInDb(UserModel userModel) async {
    try {
      // UserModel object එක Map එකක් බවට පත් කර Firestore එකට යවයි.
      // මෙහිදී user ගේ auth uid එක document ID එක ලෙස භාවිතා කරයි.
      await _db.collection('users').doc(userModel.uid).set({
        'uid': userModel.uid,
        'name': userModel.name,
        'email': userModel.email,
        'studentId': userModel.studentId,
        'profilePicUrl': userModel.profilePicUrl,
        'degree': userModel.degree,
        'yearSem': userModel.yearSem,
        // --- අලුතින් phone සහ dob එකතු කිරීම ---
        'phone': userModel.phone, // Register වෙද්දී දෙන අගය
        'dob': userModel.dob, // Register වෙද්දී දෙන අගය
      });
    } catch (e) {
      print("Error creating user in DB: $e");
      // Re-throw the error to be handled by the UI
      rethrow;
    }
  }

  /// Firestore එකෙන් user ගේ UID එකට අදාළව user profile දත්ත ලබා ගනී.
  Future<UserModel?> getUserFromDb(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
    } catch (e) {
      print("Error getting user from DB: $e");
    }
    return null;
  }

  /// 'lectures' collection එකෙන් 'status' එක 'live' වන දේශනය සොයා ගනී.
  Future<TimeSlot?> getCurrentLiveLecture(String uid) async {
    try {
      // Note: A real-world app might need to filter lectures by student's year/sem
      final querySnapshot = await _db
          .collection('lectures')
          .where('status', isEqualTo: 'live')
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return TimeSlot.fromFirestore(querySnapshot.docs.first);
      }
    } catch (e) {
      print("Error getting live lecture: $e");
    }
    return null;
  }

  /// --- 'getTimetable' function එක ---
  /// 'lectures' collection එකේ ඇති සියලුම දේශන ලබා ගනී.
  /// (මෙම function එකේ logic එකේ ගැටළුවක් තිබේ. එයද නිරාකරණය කර ඇත)
  Future<Map<String, List<TimeSlot>>> getTimetable(String uid) async {
    Map<String, List<TimeSlot>> timetable = {
      'Monday': [],
      'Tuesday': [],
      'Wednesday': [],
      'Thursday': [],
      'Friday': [],
      'Saturday': [],
      'Sunday': [],
    };

    // weekday property (1=Monday, 7=Sunday) එකට අදාළව key එක ලබාගැනීමට map එකක්
    const Map<int, String> dayMap = {
      1: 'Monday',
      2: 'Tuesday',
      3: 'Wednesday',
      4: 'Thursday',
      5: 'Friday',
      6: 'Saturday',
      7: 'Sunday',
    };

    try {
      // Firestore එකේ 'lectures' collection එකෙන් සියලුම documents ලබාගන්නවා
      // Note: A real-world app would filter this by student's course/year/sem
      final querySnapshot = await _db.collection('lectures').get();

      for (var doc in querySnapshot.docs) {
        try {
          final timeSlot = TimeSlot.fromFirestore(
            doc,
          ); // Use the correct factory

          // startTime එකෙන් සතියේ දිනය (1-7) ලබාගන්නවා
          int dayOfWeek = timeSlot.startTime.weekday;

          // අපේ dayMap එකේ අදාළ දිනයට අදාළ key එක ලබාගන්නවා
          String? dayKey = dayMap[dayOfWeek];

          if (dayKey != null) {
            timetable[dayKey]?.add(timeSlot);
          }
        } catch (e) {
          // A single corrupted document should not stop the whole process
          print("Error parsing a lecture document (${doc.id}): $e");
        }
      }

      // Sort lectures by start time within each day
      timetable.forEach((day, lectures) {
        lectures.sort((a, b) => a.startTime.compareTo(b.startTime));
      });
    } catch (e) {
      print("Error getting timetable: $e");
    }
    return timetable;
  }
}
