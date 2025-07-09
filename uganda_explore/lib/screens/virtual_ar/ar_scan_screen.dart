import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:shimmer/shimmer.dart';

class ARScanScreen extends StatefulWidget {
  final double destinationLat;
  final double destinationLng;

  const ARScanScreen({
    Key? key,
    required this.destinationLat,
    required this.destinationLng,
  }) : super(key: key);

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

  @override
  void initState() {
    super.initState();
    _initCamera();
    _getLocation();
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

  Future<void> _getLocation() async {
    await Geolocator.requestPermission();
    _currentPosition = await Geolocator.getCurrentPosition();
    _updateBearingAndDistance();
    setState(() {});
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
    // Normalize angle to [-180, 180]
    angle = (angle + 360) % 360;
    if (angle > 180) angle -= 360;
    if (angle.abs() < 15) return "Go Straight";
    if (angle > 150 || angle < -150) return "Go Back";
    if (angle > 0) return "Turn Right";
    return "Turn Left";
  }

  double getArrowRotation(String instruction) {
    switch (instruction) {
      case "Go Straight":
        return 0;
      case "Turn Right":
        return 1.5708; // 90 deg in radians
      case "Turn Left":
        return -1.5708; // -90 deg in radians
      case "Go Back":
        return 3.1416; // 180 deg in radians
      default:
        return 0;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
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
            // Perspective arrows skeleton
            ...List.generate(3, (i) {
              double scale = 1.0 - (i * 0.25);
              double offset = i * 60.0;
              return Positioned(
                bottom: 220 + offset,
                left: MediaQuery.of(context).size.width / 2 - 30 * scale,
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.grey[300],
                    size: 60 * scale,
                  ),
                ),
              );
            }),
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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Instruction skeleton
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 24.0,
                              right: 8.0,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    width: 120,
                                    height: 28,
                                    color: Colors.grey[300],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    width: 100,
                                    height: 16,
                                    color: Colors.grey[300],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    width: 100,
                                    height: 16,
                                    color: Colors.grey[300],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Arrow section skeleton
                        Container(
                          margin: const EdgeInsets.only(right: 24),
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1FF813),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
                            child: Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Close button skeleton
            Positioned(
              top: 40,
              left: 20,
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Icon(Icons.close, color: Colors.white, size: 32),
              ),
            ),
          ],
        ),
      );
    }

    double arrowAngle = 0;
    String instruction = "";
    if (_bearingToDestination != null && _heading != null) {
      arrowAngle = (_bearingToDestination! - _heading!) * (3.1415926535 / 180);
      instruction = getDirectionInstruction(_bearingToDestination! - _heading!);
    }

    // Arrow rotation for column
    double columnArrowRotation = getArrowRotation(instruction);

    // Perspective arrows in a column, peaks touching bases
    List<Widget> columnArrows = [
      Transform.rotate(
        angle: columnArrowRotation,
        child: Icon(
          Icons.play_arrow_rounded,
          color: Color(0xFF1FF813).withOpacity(0.5),
          size: 50, // Smallest
        ),
      ),
      const SizedBox(width: 2),
      Transform.rotate(
        angle: columnArrowRotation,
        child: Icon(
          Icons.play_arrow_rounded,
          color: Color(0xFF1FF813).withOpacity(0.75),
          size: 60, // Medium
        ),
      ),
      const SizedBox(width: 2),
      Transform.rotate(
        angle: columnArrowRotation,
        child: Icon(
          Icons.play_arrow_rounded,
          color: Color(0xFF1FF813),
          size: 90, // Largest
        ),
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Fullscreen camera preview
          SizedBox.expand(child: CameraPreview(_controller!)),
          // Blur rectangle with direction info and arrow at the top
          Positioned(
            left: 4,
            right: 4,
            top: 4,
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
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Instruction text
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 24.0,
                            right: 8.0,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                instruction,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const SizedBox(height: 9),
                              Text(
                                "Total Distance: ${_totalDistance != null ? _totalDistance!.toStringAsFixed(1) : '--'} m",
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Distance Left: ${_distanceToDestination != null ? _distanceToDestination!.toStringAsFixed(1) : '--'} m",
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Arrow section
                      Container(
                        margin: const EdgeInsets.only(right: 24),
                        width: 100,
                        height: 178,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1FF813),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Transform.rotate(
                            angle: columnArrowRotation,
                            child: Icon(
                              Icons.arrow_upward,
                              color: Colors.white,
                              size: 60,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Row of arrows in the center of the screen
          Center(
            child: Row(mainAxisSize: MainAxisSize.min, children: columnArrows),
          ),
          // Close button
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.chevron_left,
                color: Colors.white,
                size: 32,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
