// lib/services/database_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth; // Alias
import 'package:student_attendance_app/models/timetable_model.dart';
import 'package:student_attendance_app/models/user_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// --- 'createUserInDb' function එක ---
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
        'profilePicUrl': userModel.profilePicUrl, // Should be empty initially
        'degree': userModel.degree,
        'yearSem': userModel.yearSem,
      });
    } catch (e) {
      print("Error creating user in DB: $e");
      // Re-throw the error to be handled by the UI
      throw e;
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
  Future<Map<String, List<TimeSlot>>> getTimetable(String uid) async {
    // uid is unused for now, but can be used for filtering later
    Map<String, List<TimeSlot>> timetable = {
      'Monday': [],
      'Tuesday': [],
      'Wednesday': [],
      'Thursday': [],
      'Friday': [],
      'Saturday': [],
      'Sunday': [],
    };
    List<String> dayKeys = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    try {
      // Firestore එකේ 'lectures' collection එකෙන් සියලුම documents ලබාගන්නවා
      final querySnapshot = await _db.collection('lectures').get();

      for (var doc in querySnapshot.docs) {
        final lecture = TimeSlot.fromTimetable(
          doc,
        ); // Using a different factory
        if (lecture.dayOfWeek >= 1 && lecture.dayOfWeek <= 7) {
          String day = dayKeys[lecture.dayOfWeek - 1];
          timetable[day]?.add(lecture);
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
