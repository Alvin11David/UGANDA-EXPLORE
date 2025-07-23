import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:math';
import 'dart:async';

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
  CameraController? _controller;
  Position? _currentPosition;
  double? _bearingToDestination;
  double? _heading;
  double? _distanceToDestination;
  double? _totalDistance;
  double? _speed;
  double? _altitude;
  double? _accuracy;
  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _initCamera();
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
            _updateBearingAndDistance();
          });
        });
    FlutterCompass.events?.listen((event) {
      setState(() {
        _heading = event.heading;
      });
    });
  }

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

  void _updateBearingAndDistance() {
    if (_currentPosition != null) {
      _bearingToDestination = Geolocator.bearingBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        widget.destinationLat,
        widget.destinationLng,
      );
      _distanceToDestination = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        widget.destinationLat,
        widget.destinationLng,
      );
      _totalDistance ??= _distanceToDestination;
    }
  }

  String getDirectionInstruction(double angle) {
    angle = (angle + 360) % 360;
    if (angle > 180) angle -= 360;
    if (angle.abs() < 15) return "Go Straight";
    if (angle > 150 || angle < -150) return "Go Back";
    if (angle > 0) return "Turn Right";
    return "Turn Left";
  }

  double getArrowRotation(double angle) {
    // Arrow points in the direction the user needs to turn
    return angle * pi / 180;
  }

  // Helper to select arrow icon based on instruction
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
    _controller?.dispose();
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      // Skeleton shimmer for loading state
      return Scaffold(
        body: Stack(
          children: [
            // Camera skeleton
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.white,
              ),
            ),
            // Blur rectangle skeleton
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

    double arrowAngle = 0;
    String instruction = "";
    if (_bearingToDestination != null && _heading != null) {
      double angle = _bearingToDestination! - _heading!;
      arrowAngle = getArrowRotation(angle);
      instruction = getDirectionInstruction(angle);
    }

    // Animated arrow in the center, using direction icon
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

    // Motivational quote at bottom center
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
                // Instruction text
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

    // Close button
    Widget closeButton = Positioned(
      top: 40,
      left: 1,
      child: IconButton(
        icon: const Icon(Icons.chevron_left, color: Colors.white, size: 32),
        onPressed: () => Navigator.pop(context),
      ),
    );

    // Calculate progress (0.0 to 1.0)
    double progress = 0.0;
    if (_totalDistance != null &&
        _distanceToDestination != null &&
        _totalDistance! > 0) {
      progress = 1.0 - (_distanceToDestination! / _totalDistance!);
      progress = progress.clamp(0.0, 1.0);
    }

    // Progress bar widget
    Widget progressBar = Positioned(
      bottom: 10,
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

    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(child: CameraPreview(_controller!)),
          directionPanel,
          animatedArrow,
          metricsPanel,
          progressBar, 
          closeButton,
        ],
      ),
    );
  }
}
