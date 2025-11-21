// lib/screens/live_tracking_screen.dart

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LiveTrackingScreen extends StatefulWidget {
  final String? studentId;
  const LiveTrackingScreen({super.key, required this.studentId});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  // --- KDU University Coordinates සහ Geofence ---
  final double classroomLat = 6.8213; // KDU Latitude
  final double classroomLng = 79.9015; // KDU Longitude
  final String classroomName = "KDU, Ratmalana";
  final double geofenceRadius = 100.0; // මීටර් 100ක සීමාවක්

  Position? _currentPosition;
  double _distanceInMeters = 0.0;
  bool _isInsideGeofence = false;
  bool _isLoading = true;
  String _statusMessage = "Fetching location...";

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    setState(() {
      _isLoading = true;
      _statusMessage = "Checking permissions...";
    });

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _isLoading = false;
          _statusMessage = "Location permissions are denied.";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _isLoading = false;
        _statusMessage =
            "Permissions are permanently denied. Cannot request permissions.";
      });
      return;
    }

    _refreshLocation();
  }

  void _refreshLocation() async {
    setState(() {
      _isLoading = true;
      _statusMessage = "Fetching your current location...";
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _updateLocation(position);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = "Could not fetch location: ${e.toString()}";
      });
    }
  }

  void _updateLocation(Position position) {
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
      _isLoading = false;
      _statusMessage = _isInsideGeofence
          ? "You are within the university premises."
          : "Your location is not matching with the classroom area.";
    });
  }

  // --- වෙනස්කම්: මෙම function එක Firebase එකට කිසිවක් නොයවා, ಹಿಂದಿನ තිරයට 'true' ලෙස result එකක් යවයි ---
  void _confirmLocationAndGoBack() {
    // Navigator.pop එකෙන් දෙවැනි argument එක ලෙස result එක යැවිය හැකිය.
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
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(_statusMessage),
                ],
              ),
            )
          : _buildTrackingBody(),
    );
  }

  Widget _buildTrackingBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isInsideGeofence
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
            ),
            child: Icon(
              Icons.gps_fixed,
              color: _isInsideGeofence ? Colors.green : Colors.red,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _isInsideGeofence ? "Location Verified" : "Location Mismatch",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _statusMessage,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 40),
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
          // --- Action Buttons (වෙනස් කර ඇත) ---
          if (_isInsideGeofence)
            ElevatedButton(
              onPressed: _confirmLocationAndGoBack, // <-- වෙනස් කළ function එක
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Confirm Location",
                style: TextStyle(fontSize: 16),
              ),
            )
          else
            ElevatedButton(
              onPressed: _refreshLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Reconfirm Location",
                style: TextStyle(fontSize: 16),
              ),
            ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, false), // Cancel කරද්දී 'false' යවනවා
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

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
  }) {
    // මෙම widget එකේ වෙනසක් නැත.
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
