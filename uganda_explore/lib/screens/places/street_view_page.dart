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
}
