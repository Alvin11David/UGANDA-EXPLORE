import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class StreetViewPage extends StatefulWidget {
  final String siteName;
  final double? latitude;
  final double? longitude;

  const StreetViewPage({
    super.key,
    required this.siteName,
    this.latitude,
    this.longitude,
  });

  @override
  State<StreetViewPage> createState() => _StreetViewPageState();
}

class _StreetViewPageState extends State<StreetViewPage> {
  late WebViewController _webViewController;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  double? _siteLatitude;
  double? _siteLongitude;
  String? _userDistrict;
  double? _userLatitude;
  double? _userLongitude;

  // Your Google Maps API key (same as used in MapViewScreen)
  static const String _apiKey = 'AIzaSyCyqzryof5ULhLPpxqjtMPG22RtpOu7r3w';

  @override
  void initState() {
    super.initState();
    _initializeStreetView();
    _getUserLocation();
  }

  // Segment 2: Fetch site coordinates from Firestore
  Future<void> _initializeStreetView() async {
    if (widget.latitude != null && widget.longitude != null) {
      _siteLatitude = widget.latitude;
      _siteLongitude = widget.longitude;
      _setupWebView();
    } else {
      await _fetchCoordinatesFromFirestore();
    }
  }

  Future<void> _fetchCoordinatesFromFirestore() async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('tourismsites')
          .where('name', isEqualTo: widget.siteName.trim())
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        final lat = doc['latitude'];
        final lng = doc['longitude'];

        double? latitude;
        double? longitude;

        if (lat is double && lng is double) {
          latitude = lat;
          longitude = lng;
        } else if (lat is int && lng is int) {
          latitude = lat.toDouble();
          longitude = lng.toDouble();
        } else if (lat is String && lng is String) {
          latitude = double.tryParse(lat);
          longitude = double.tryParse(lng);
        }

        if (latitude != null && longitude != null) {
          _siteLatitude = latitude;
          _siteLongitude = longitude;
          _setupWebView();
        } else {
          _setError('Invalid coordinates for this location');
        }
      } else {
        _setError('Location not found in database');
      }
    } catch (e) {
      _setError('Error fetching location: \$e');
    }
  }

  void _setError(String message) {
    setState(() {
      _hasError = true;
      _errorMessage = message;
      _isLoading = false;
    });
  }
}
