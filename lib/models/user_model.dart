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
  // --- වෙනස්කම් 1: phone සහ dob fields ලෙස එකතු කිරීම ---
  final String phone;
  final String dob;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.studentId,
    required this.profilePicUrl,
    required this.degree,
    required this.yearSem,
    // --- වෙනස්කම් 2: Constructor එකට මේවා required ලෙස එකතු කිරීම ---
    required this.phone,
    required this.dob,
  });

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
      // --- වෙනස්කම් 3: Firestore එකෙන් phone සහ dob කියවීම ---
      // Firestore එකේ මේ fields නැත්නම්, default අගයක් දෙනවා.
      phone: data['phone'] ?? 'Not Provided',
      dob: data['dob'] ?? 'Not Provided',
    );
  }

  // --- වෙනස්කම් 4: වැරදි getters දෙක ඉවත් කිරීම ---
  // get phone => null; <--- ඉවත් කළා
  // get dob => null; <--- ඉවත් කළා

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'studentId': studentId,
      'profilePicUrl': profilePicUrl,
      'degree': degree,
      'yearSem': yearSem,
      'phone': phone, // toMap එකටත් එකතු කළා
      'dob': dob, // toMap එකටත් එකතු කළා
    };
  }
}
