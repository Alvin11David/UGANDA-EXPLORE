import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';

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

  @override
  void initState() {
    super.initState();
    print('ARScanScreen: initState called');
    _initCamera();
    _getLocation();
    FlutterCompass.events?.listen((event) {
      setState(() {
        _heading = event.heading;
        print('Compass heading updated: $_heading');
      });
    });
  }

  Future<void> _initCamera() async {
    print('Initializing camera...');
    try {
      final cameras = await availableCameras();
      print('Available cameras: $cameras');
      _controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await _controller!.initialize();
      print('Camera initialized successfully');
      setState(() {});
    } catch (e) {
      print('Camera initialization error: $e');
    }
  }

  Future<void> _getLocation() async {
    print('Requesting location permission...');
    await Geolocator.requestPermission();
    print('Getting current position...');
    _currentPosition = await Geolocator.getCurrentPosition();
    print('Current position: $_currentPosition');
    _updateBearing();
    setState(() {});
  }

  void _updateBearing() {
    if (_currentPosition != null) {
      _bearingToDestination = Geolocator.bearingBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        widget.destinationLat,
        widget.destinationLng,
      );
      print('Bearing to destination: $_bearingToDestination');
    }
  }

  @override
  void dispose() {
    print('Disposing camera controller');
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(
      'Building ARScanScreen. Controller initialized: ${_controller != null && _controller!.value.isInitialized}',
    );
    if (_controller == null || !_controller!.value.isInitialized) {
      print('Camera not ready, showing CircularProgressIndicator');
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    double arrowAngle = 0;
    if (_bearingToDestination != null && _heading != null) {
      arrowAngle = (_bearingToDestination! - _heading!) * (3.1415926535 / 180);
      print('Arrow angle: $arrowAngle (radians)');
    }

    return Scaffold(
      body: Stack(
        children: [
          CameraPreview(_controller!),
          if (_bearingToDestination != null && _heading != null)
            Center(
              child: Transform.rotate(
                angle: arrowAngle,
                child: Icon(Icons.arrow_upward, color: Colors.red, size: 100),
              ),
            ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 32),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
