import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:math';
import 'dart:async';

// ARScanScreen displays AR navigation with camera, compass, and geolocation
class ARScanScreen extends StatefulWidget {
  final double destinationLat;
  final double destinationLng;

  const ARScanScreen({
    super.key,
    required this.destinationLat,
    required this.destinationLng,
  });

  @override
  State<ARScanScreen> createState() => _ARScanScreenState();
}

class _ARScanScreenState extends State<ARScanScreen> {
  CameraController? _controller; // Camera preview controller
  Position? _currentPosition; // User's current GPS position
  double? _bearingToDestination; // Bearing to next waypoint/destination
  double? _heading; // Device compass heading
  double? _distanceToDestination; // Distance to next waypoint/destination
  double? _totalDistance; // Total route distance
  double? _speed; // User speed
  double? _altitude; // Altitude
  double? _accuracy; // GPS accuracy
  StreamSubscription<Position>? _positionStream; // Location stream

  List<LatLng> _waypoints = []; // Route waypoints
  int _currentWaypointIndex = 0; // Current waypoint index

  @override
  void initState() {
    super.initState();
    _initCamera(); // Start camera preview

    // Listen for location updates
    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
            distanceFilter: 1,
          ),
        ).listen((pos) {
          setState(() {
            _currentPosition = pos;
            _speed = pos.speed;
            _altitude = pos.altitude;
            _accuracy = pos.accuracy;
            _updateBearingAndDistance(); // Update navigation info
          });
        });

    // Listen for compass heading updates
    FlutterCompass.events?.listen((event) {
      setState(() {
        _heading = event.heading;
      });
    });

    // Example waypoints (replace with your route logic)
    _waypoints = [
      LatLng(37.3318, -122.0312), // start point
      LatLng(37.3328, -122.0322), // waypoint 1
      LatLng(widget.destinationLat, widget.destinationLng), // destination
    ];
  }

  // Initialize camera preview
  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      _controller = CameraController(
        cameras.first,
        ResolutionPreset.max,
        enableAudio: false,
      );
      await _controller!.initialize();
      setState(() {});
    } catch (e) {
      print('Camera initialization error: $e');
    }
  }

  // Update bearing and distance to next waypoint/destination
  void _updateBearingAndDistance() {
    if (_currentPosition != null && _waypoints.isNotEmpty) {
      // Move to next waypoint if close enough
      while (_currentWaypointIndex < _waypoints.length - 1) {
        double dist = Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          _waypoints[_currentWaypointIndex].lat,
          _waypoints[_currentWaypointIndex].lng,
        );
        if (dist < 20) {
          _currentWaypointIndex++;
        } else {
          break;
        }
      }
      LatLng target = _waypoints[_currentWaypointIndex];
      _bearingToDestination = Geolocator.bearingBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        target.lat,
        target.lng,
      );
      _distanceToDestination = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        target.lat,
        target.lng,
      );
      // Calculate total route distance once
      _totalDistance ??= _calculateTotalRouteDistance();
    }
  }

  // Calculate total route distance by summing segments
  double _calculateTotalRouteDistance() {
    double total = 0.0;
    for (int i = 0; i < _waypoints.length - 1; i++) {
      total += Geolocator.distanceBetween(
        _waypoints[i].lat,
        _waypoints[i].lng,
        _waypoints[i + 1].lat,
        _waypoints[i + 1].lng,
      );
    }
    return total;
  }

  // Get navigation instruction based on angle difference
  String getDirectionInstruction(double angle) {
    angle = (angle + 360) % 360;
    if (angle > 180) angle -= 360;
    if (angle.abs() < 15) return "Go Straight";
    if (angle > 150 || angle < -150) return "Go Back";
    if (angle > 0) return "Turn Right";
    return "Turn Left";
  }

  // Convert angle to radians for arrow rotation
  double getArrowRotation(double angle) {
    // Arrow points in the direction the user needs to turn
    return angle * pi / 180;
  }

  // Select arrow icon based on instruction
  IconData getDirectionArrow(String instruction) {
    switch (instruction) {
      case "Go Straight":
        return Icons.arrow_upward;
      case "Go Back":
        return Icons.arrow_downward;
      case "Turn Right":
        return Icons.arrow_forward;
      case "Turn Left":
        return Icons.arrow_back;
      default:
        return Icons.navigation;
    }
  }

  @override
  void dispose() {
    _controller?.dispose(); // Dispose camera
    _positionStream?.cancel(); // Cancel location stream
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show shimmer skeleton while camera is loading
    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(
        body: Stack(
          children: [
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.white,
              ),
            ),
            Positioned(
              left: 4,
              right: 4,
              bottom: 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Calculate arrow angle and instruction
    double arrowAngle = 0;
    String instruction = "";
    if (_bearingToDestination != null && _heading != null) {
      double angle = _bearingToDestination! - _heading!;
      arrowAngle = getArrowRotation(angle);
      instruction = getDirectionInstruction(angle);
    }

    // Animated arrow in the center
    Widget animatedArrow = Center(
      child: AnimatedScale(
        scale: 1.1,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        child: Icon(
          getDirectionArrow(instruction),
          color: Colors.white,
          size: 120,
        ),
      ),
    );

    // Metrics panel at bottom left
    Widget metricsPanel = Positioned(
      left: 4,
      bottom: 80,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Speed: ${_speed != null ? (_speed! * 3.6).toStringAsFixed(1) : '--'} km/h",
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Altitude: ${_altitude?.toStringAsFixed(1) ?? '--'} m",
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  "Accuracy: ${_accuracy?.toStringAsFixed(1) ?? '--'} m",
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  "Heading: ${_heading?.toStringAsFixed(1) ?? '--'}°",
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Motivational quote panel (currently empty)
    Widget quotePanel = Positioned(
      bottom: 24,
      left: MediaQuery.of(context).size.width * 0.25,
      right: MediaQuery.of(context).size.width * 0.25,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );

    // Direction info panel at top
    Widget directionPanel = Positioned(
      left: 4,
      right: 4,
      top: 40,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: Colors.white, width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Instruction text and metrics
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24.0, right: 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              getDirectionArrow(instruction),
                              color: Colors.black87,
                              size: 36,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              instruction,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 9),
                        Text(
                          "Total Distance: ${_totalDistance != null ? _totalDistance!.toStringAsFixed(1) : '--'} m",
                          style: const TextStyle(
                            fontSize: 17,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Distance Left: ${_distanceToDestination != null ? _distanceToDestination!.toStringAsFixed(1) : '--'} m",
                          style: const TextStyle(
                            fontSize: 17,
                            color: Colors.black,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Animated arrow section
                Container(
                  margin: const EdgeInsets.only(right: 24),
                  width: 100,
                  height: 140,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1FF813),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Icon(
                      getDirectionArrow(instruction),
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Close button to exit AR screen
    Widget closeButton = Positioned(
      top: 40,
      left: 1,
      child: IconButton(
        icon: const Icon(Icons.chevron_left, color: Colors.white, size: 32),
        onPressed: () => Navigator.pop(context),
      ),
    );

    // Calculate progress to destination
    double progress = 0.0;
    if (_totalDistance != null &&
        _distanceToDestination != null &&
        _totalDistance! > 0) {
      progress = 1.0 - (_distanceToDestination! / _totalDistance!);
      progress = progress.clamp(0.0, 1.0);
    }

    // Progress bar widget
    Widget progressBar = Positioned(
      bottom: 11,
      left: 5,
      right: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Progress to Destination",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1FF813)),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "${(progress * 100).toStringAsFixed(1)}% completed",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );

    // Main AR navigation UI
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(child: CameraPreview(_controller!)), // Camera background
          directionPanel, // Top navigation info
          animatedArrow, // Center arrow
          metricsPanel, // Bottom left metrics
          progressBar, // Progress bar
          closeButton, // Exit button
        ],
      ),
    );
  }
}

// Helper class for lat/lng points
class LatLng {
  final double lat;
  final double lng;
  LatLng(this.lat, this.lng);
}