import 'package:cloud_firestore/cloud_firestore.dart';

class LocationLog {
  final bool insideGeofence;
  final DateTime loggedAt;
  final String subjectName;
  final String roomNo;

  LocationLog({
    required this.insideGeofence,
    required this.loggedAt,
    required this.subjectName,
    required this.roomNo,
  });

  factory LocationLog.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return LocationLog(
      insideGeofence: data['inside_geofence'] ?? false,
      loggedAt: (data['loggedAt'] as Timestamp).toDate(),
      subjectName: data['subjectName'] ?? 'Unknown Subject',
      roomNo: data['roomNo'] ?? 'N/A',
    );
  }
}
