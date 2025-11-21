// lib/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    as auth; // Alias to avoid name clash

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String studentId;
  final String profilePicUrl;
  final String degree;
  final String yearSem;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.studentId,
    required this.profilePicUrl,
    required this.degree,
    required this.yearSem,
    required String phone,
    required String dob,
  });

  // --- දෝෂය නිරාකරණය කරන fromFirestore constructor එක ---
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? 'No Name',
      email: data['email'] ?? 'No Email',
      studentId: data['studentId'] ?? 'N/A',
      profilePicUrl: data['profilePicUrl'] ?? '',
      degree: data['degree'] ?? 'N/A',
      yearSem: data['yearSem'] ?? 'N/A',
      phone: '',
      dob: '',
    );
  }

  get phone => null;

  get dob => null;

  // Auth User object එකකින් Firestore document එකක් සඳහා Map එකක් සාදන function එක
  Map<String, dynamic> toMap(auth.User user) {
    return {
      'uid': user.uid,
      'name': name, // 'name' is passed to constructor during registration
      'email': user.email,
      'studentId': studentId, // 'studentId' is passed to constructor
      'profilePicUrl': '', // Initially empty
      'degree': degree,
      'yearSem': yearSem,
    };
  }
}
