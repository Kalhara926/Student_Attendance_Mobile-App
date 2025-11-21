// lib/screens/live_tracking_screen.dart

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

// --- ස්ථානය තහවුරු කිරීම සඳහා වන Screen එක ---
class LiveTrackingScreen extends StatefulWidget {
  final String? studentId; // ශිෂ්‍යයාගේ ID එක ලබාගැනීම සඳහා
  const LiveTrackingScreen({super.key, required this.studentId});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  // --- KDU විශ්වවිද්‍යාලයේ ඛණ්ඩාංක සහ Geofence (සීමාව) ---
  final double classroomLat = 6.8213; // KDU Latitude
  final double classroomLng = 79.9015; // KDU Longitude
  final String classroomName = "KDU, Ratmalana";
  final double geofenceRadius = 100.0; // මීටර් 100ක සීමාවක්

  // --- පරීක්ෂා කිරීම සඳහා යොදාගත් ශිෂ්‍යයාගේ පිහිටීම ---
  // මෙය geofence එක තුළ පිහිටන ලෙස සකසා ඇත.
  final double hardcodedStudentLat = 6.8210;
  final double hardcodedStudentLng = 79.9018;

  // --- Screen එකේ තත්ත්වයන් පාලනය කරන Variables ---
  Position? _currentPosition; // ශිෂ්‍යයාගේ වත්මන් පිහිටීම
  double _distanceInMeters = 0.0; // පන්ති කාමරයේ සිට දුර
  bool _isInsideGeofence = false; // Geofence එක තුළ සිටීද?
  bool _isLoading = true; // දත්ත load වන විට පෙන්වීමට
  String _statusMessage =
      "Verifying your location..."; // පරිශීලකයාට පෙන්වන පණිවිඩය

  // --- Confirm Button එක enable/disable කිරීම පාලනය කිරීමට ---
  bool _canConfirm = false;

  @override
  void initState() {
    super.initState();
    // Screen එක පූරණය වූ විගස hardcoded පිහිටීම භාවිතා කර ක්‍රියාවලිය ආරම්භ කරයි
    _useHardcodedPosition();
  }

  // --- Hardcoded පිහිටීම භාවිතා කර ස්ථානය තහවුරු කරන function එක ---
  void _useHardcodedPosition() {
    // ක්‍රියාවලිය ආරම්භ කිරීමට පෙර සියලු states නැවත සකසයි
    setState(() {
      _isLoading = true;
      _canConfirm = false; // Button එක disable කරයි
      _statusMessage = "Verifying your location...";
    });

    // Loading indicator එක පෙන්වීමට තත්පර 1ක ප්‍රමාදයක් යොදයි
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return; // Widget එක තිරයෙන් ඉවත් කර ඇත්නම්, ඉදිරියට නොයයි

      // ව්‍යාජ Position object එකක් සාදයි
      final fakePosition = Position(
        latitude: hardcodedStudentLat,
        longitude: hardcodedStudentLng,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );
      // ලැබුණු පිහිටීම සමඟ UI එක update කරයි
      _updateLocation(fakePosition);
    });
  }

  // --- පිහිටීම ලැබුණු පසු UI එක සහ අනෙකුත් දත්ත update කරන function එක ---
  void _updateLocation(Position position) {
    // ශිෂ්‍යයාගේ සහ පන්ති කාමරයේ පිහිටීම් අතර දුර ගණනය කරයි
    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      classroomLat,
      classroomLng,
    );

    setState(() {
      _currentPosition = position;
      _distanceInMeters = distance;
      _isInsideGeofence = _distanceInMeters <= geofenceRadius;
      _isLoading = false; // Loading අවසන්

      // Geofence එක තුළ නම් සහ නැතිනම් පෙන්වන පණිවිඩය වෙනස් කරයි
      _statusMessage = _isInsideGeofence
          ? "You are within the university premises."
          : "Your location is not matching with the classroom area.";
    });

    // --- වැදගත්ම කොටස ---
    // ශිෂ්‍යයා Geofence එක තුළ සිටී නම්...
    if (_isInsideGeofence) {
      // තත්පරයක ප්‍රමාදයකින් පසු "Confirm" button එක enable කරයි
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _canConfirm = true;
          });
        }
      });
    }
  }

  // --- 'Confirm' කළ පසු, ಹಿಂದಿನ තිරයට 'true' ලෙස result එකක් යැවීම ---
  void _confirmLocationAndGoBack() {
    // මෙමගින් `AttendanceDetailScreen` එකට `true` යන අගය ආපසු යවයි.
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Location Verification"),
        backgroundColor: Colors.grey[100],
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      // _isLoading true නම් loading UI එකත්, නැතිනම් tracking UI එකත් පෙන්වයි
      body: _isLoading ? _buildLoadingState() : _buildTrackingBody(),
    );
  }

  // --- Loading වන විට පෙන්වන UI එක ---
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(
            _statusMessage,
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  // --- පිහිටීම ලැබුණු පසු පෙන්වන UI එක ---
  Widget _buildTrackingBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          // Icon එක
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isInsideGeofence
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
            ),
            child: Icon(
              _isInsideGeofence ? Icons.location_on : Icons.location_off,
              color: _isInsideGeofence ? Colors.green : Colors.red,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),

          // ප්‍රධාන தலைப்பு
          Text(
            _isInsideGeofence ? "Location Matched!" : "Location Mismatch",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // තත්ත්වය පිළිබඳ පණිවිඩය
          Text(
            _statusMessage,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 40),

          // තොරතුරු Cards
          _buildInfoCard(
            icon: Icons.my_location,
            title: "Your Current Location",
            subtitle: _currentPosition != null
                ? "Distance: ${_distanceInMeters.toStringAsFixed(0)}m from center"
                : "Unknown",
            iconColor: Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            icon: Icons.school,
            title: "Expected Classroom",
            subtitle: classroomName,
            iconColor: Colors.deepPurple,
          ),
          const Spacer(flex: 2),

          // --- Buttons ---
          // ශිෂ්‍යයා geofence එක තුළ සිටී නම්...
          if (_isInsideGeofence)
            ElevatedButton(
              // `_canConfirm` true නම් පමණක් `_confirmLocationAndGoBack` call කරයි.
              // නැතිනම් `null` යෙදීමෙන් button එක disable (අක්‍රිය) වේ.
              onPressed: _canConfirm ? _confirmLocationAndGoBack : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                // disable වූ විට පෙන්වන style එක
                disabledBackgroundColor: Colors.grey.shade400,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Confirm Location",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            )
          // ශිෂ්‍යයා geofence එකෙන් පිටත සිටී නම්...
          else
            ElevatedButton(
              onPressed: _useHardcodedPosition, // නැවත පිහිටීම පරීක්ෂා කිරීමට
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Reconfirm Location",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          const SizedBox(height: 12),
          TextButton(
            // `false` අගය සමඟ ආපසු යයි
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.grey[700], fontSize: 16),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  // --- තොරතුරු card එක සෑදීමට යොදාගන්නා helper widget එක ---
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
