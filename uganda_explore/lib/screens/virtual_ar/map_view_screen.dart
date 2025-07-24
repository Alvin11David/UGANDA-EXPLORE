import 'dart:convert';
import 'dart:ui';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:uganda_explore/screens/virtual_ar/virtual_tour_screen.dart';

class MapViewScreen extends StatefulWidget {
  final String siteName;
  final bool showCurrentLocation;
  const MapViewScreen({
    super.key,
    required this.siteName,
    this.showCurrentLocation = false,
  });

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen>
    with TickerProviderStateMixin {
  static const String _apiKey =
      'AIzaSyB7H463r_jOW8U9k-LPtmTmrUOoCLVW3Zg';

  LatLng? siteLatLng;
  LatLng? userLatLng;
  LatLng? previousUserLatLng;
  GoogleMapController? mapController;
  String? error;
  String? userDistrict = "Fetching...";
  bool isEditingDestination = false;
  final TextEditingController _destinationController = TextEditingController();
  List<LatLng> routePolyline = [];

  // Motion tracking variables
  double userBearing = 0.0;
  double userSpeed = 0.0; // km/h
  bool isMoving = false;
  Timer? _motionTimer;

  // Enhanced tracking variables
  String? walkingDuration;
  String? drivingDuration;
  String? bicyclingDuration;
  String? routeDistance;
  bool isLoadingRoute = false;
  bool isLoadingDurations = false;

  // Animation controllers for smooth updates
  late AnimationController _bearingController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  StreamSubscription<Position>? _positionStream;

  // Custom marker for user with direction
  BitmapDescriptor? customUserMarker;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    fetchCoordinates();
    fetchUserDistrict();
    _startEnhancedLocationTracking();
  }

  void _initializeAnimations() {
    _bearingController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
  }

  void _startEnhancedLocationTracking() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 10,
    );

    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) {
            _updateUserPosition(position);
          },
        );

    // Start motion detection timer
    _motionTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _detectMotion();
    });
  }

  void _updateUserPosition(Position position) {
    final newLatLng = LatLng(position.latitude, position.longitude);

    setState(() {
      previousUserLatLng = userLatLng;
      userLatLng = newLatLng;

      // Update bearing if we have a previous position
      if (previousUserLatLng != null) {
        userBearing = _calculateBearing(previousUserLatLng!, newLatLng);
      }

      // Update speed
      userSpeed = position.speed * 3.6; // Convert m/s to km/h
      isMoving = userSpeed > 0.5; // Consider moving if speed > 0.5 km/h
    });

    // Update camera to follow user smoothly if moving
    if (isMoving && mapController != null) {
      _smoothCameraFollow();
    }

    // Update route if both locations are available
    if (siteLatLng != null && !isLoadingRoute) {
      _debouncedRouteUpdate();
    }
  }

  Timer? _routeUpdateTimer;
  void _debouncedRouteUpdate() {
    _routeUpdateTimer?.cancel();
    _routeUpdateTimer = Timer(const Duration(seconds: 3), () {
      fetchAndSetRoute();
    });
  }

  void _smoothCameraFollow() {
    if (userLatLng != null && mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: userLatLng!,
            zoom: isMoving ? 17.0 : 15.0,
            bearing: isMoving ? userBearing : 0,
            tilt: isMoving ? 45.0 : 0,
          ),
        ),
      );
    }
  }

  double _calculateBearing(LatLng start, LatLng end) {
    final lat1 = start.latitude * math.pi / 180;
    final lat2 = end.latitude * math.pi / 180;
    final deltaLng = (end.longitude - start.longitude) * math.pi / 180;

    final y = math.sin(deltaLng) * math.cos(lat2);
    final x =
        math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(deltaLng);

    final bearing = math.atan2(y, x) * 180 / math.pi;
    return (bearing + 360) % 360;
  }

  void _detectMotion() {
    if (userLatLng != null && previousUserLatLng != null) {
      final distance = Geolocator.distanceBetween(
        previousUserLatLng!.latitude,
        previousUserLatLng!.longitude,
        userLatLng!.latitude,
        userLatLng!.longitude,
      );

      // If user hasn't moved significantly in 2 seconds, they're stationary
      if (distance < 2.0 && isMoving) {
        setState(() {
          isMoving = false;
          userSpeed = 0.0;
        });
      }
    }
  }

  Future<void> fetchUserDistrict() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          userDistrict = "Location services are disabled.";
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            userDistrict = "Location permission denied.";
          });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          userDistrict = "Location permission permanently denied.";
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      setState(() {
        userLatLng = LatLng(position.latitude, position.longitude);
        userDistrict = placemarks.isNotEmpty
            ? (placemarks.first.subAdministrativeArea ??
                  placemarks.first.locality ??
                  "Unknown District")
            : "District not found";
      });

      if (userLatLng != null && siteLatLng != null) {
        await fetchAndSetRoute();
        await fetchDurationsAndDistance();
      }
    } catch (e) {
      setState(() {
        userDistrict = "Error: $e";
      });
    }
  }

  Future<void> fetchCoordinates({String? customDestination}) async {
    final searchName = customDestination ?? widget.siteName;
    try {
      final query = await FirebaseFirestore.instance
          .collection('tourismsites')
          .where('name', isEqualTo: searchName.trim())
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
          setState(() {
            siteLatLng = LatLng(latitude!, longitude!);
            error = null;
          });

          if (userLatLng != null) {
            await fetchAndSetRoute();
            await fetchDurationsAndDistance();
          }
        } else {
          setState(() {
            error = 'Location not found for this site.';
          });
        }
      } else {
        setState(() {
          error = 'Site not found.';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error finding location: $e';
      });
    }
  }

  Future<void> fetchAndSetRoute() async {
    if (userLatLng == null || siteLatLng == null || isLoadingRoute) return;

    print('Fetching route: userLatLng=$userLatLng, siteLatLng=$siteLatLng');

    setState(() {
      isLoadingRoute = true;
      error = null; // Clear previous errors
    });

    try {
      final polyline = await fetchRoutePolyline(
        userLatLng!,
        siteLatLng!,
        _apiKey,
      );
      setState(() {
        routePolyline = polyline;
        isLoadingRoute = false;
      });
      print('Route fetched successfully with ${polyline.length} points');
    } catch (e) {
      print('Directions API Error: $e');
      setState(() {
        error = 'Failed to fetch route: $e';
        isLoadingRoute = false;
        routePolyline = []; // Clear existing route on error
      });
    }
  }

  Future<List<LatLng>> fetchRoutePolyline(
    LatLng origin,
    LatLng destination,
    String apiKey,
  ) async {
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${origin.latitude},${origin.longitude}&'
        'destination=${destination.latitude},${destination.longitude}&'
        'mode=driving&'
        'key=$apiKey';

    print('Directions API Request: $url');

    final response = await http.get(Uri.parse(url));
    print('Directions API Response: Status=${response.statusCode}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('API Response Status: ${data['status']}');

      if (data['status'] == 'OK' &&
          data['routes'] != null &&
          data['routes'].isNotEmpty) {
        final points = data['routes'][0]['overview_polyline']['points'];
        final decodedPoints = decodePolyline(points);
        print('Decoded ${decodedPoints.length} polyline points');
        return decodedPoints;
      } else {
        final errorMessage = data['error_message'] ?? 'No routes found';
        print('API Error: ${data['status']} - $errorMessage');
        throw Exception('API Error: ${data['status']} - $errorMessage');
      }
    } else {
      print('HTTP Error: ${response.statusCode} - ${response.body}');
      throw Exception('HTTP Error: ${response.statusCode}');
    }
  }

  List<LatLng> decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      poly.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return poly;
  }

  Future<void> fetchDurationsAndDistance() async {
    if (userLatLng == null || siteLatLng == null || isLoadingDurations) return;

    setState(() {
      isLoadingDurations = true;
    });

    final modes = ['walking', 'driving', 'bicycling'];
    final results = <String, Map<String, String>>{};

    try {
      for (final mode in modes) {
        final url =
            'https://maps.googleapis.com/maps/api/directions/json?'
            'origin=${userLatLng!.latitude},${userLatLng!.longitude}&'
            'destination=${siteLatLng!.latitude},${siteLatLng!.longitude}&'
            'mode=$mode&'
            'key=$_apiKey';

        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'OK' &&
              data['routes'] != null &&
              data['routes'].isNotEmpty &&
              data['routes'][0]['legs'] != null &&
              data['routes'][0]['legs'].isNotEmpty) {
            final leg = data['routes'][0]['legs'][0];
            results[mode] = {
              'duration': leg['duration']['text'] ?? '-',
              'distance': leg['distance']['text'] ?? '-',
            };
          }
        }
      }

      setState(() {
        walkingDuration = results['walking']?['duration'] ?? '-';
        drivingDuration = results['driving']?['duration'] ?? '-';
        bicyclingDuration = results['bicycling']?['duration'] ?? '-';
        routeDistance =
            results['driving']?['distance'] ??
            results['walking']?['distance'] ??
            results['bicycling']?['distance'] ??
            '-';
        isLoadingDurations = false;
      });
    } catch (e) {
      print('Error fetching durations: $e');
      setState(() {
        isLoadingDurations = false;
      });
    }
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _motionTimer?.cancel();
    _routeUpdateTimer?.cancel();
    _bearingController.dispose();
    _pulseController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Widget _buildMotionIndicator() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isMoving ? Colors.green : Colors.orange,
            boxShadow: [
              BoxShadow(
                color: (isMoving ? Colors.green : Colors.orange).withOpacity(
                  0.5,
                ),
                blurRadius: 10 * _pulseAnimation.value,
                spreadRadius: 2 * _pulseAnimation.value,
              ),
            ],
          ),
        );
      },
    );
  }

  void _fitMarkersOnScreen() {
    if (mapController == null || userLatLng == null || siteLatLng == null)
      return;

    LatLngBounds bounds;
    if (userLatLng!.latitude > siteLatLng!.latitude) {
      bounds = LatLngBounds(southwest: siteLatLng!, northeast: userLatLng!);
    } else {
      bounds = LatLngBounds(southwest: userLatLng!, northeast: siteLatLng!);
    }

    mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (siteLatLng != null)
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: siteLatLng!,
                zoom: 14,
              ),
              markers: {
                if (siteLatLng != null)
                  Marker(
                    markerId: const MarkerId('site'),
                    position: siteLatLng!,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed,
                    ),
                    infoWindow: InfoWindow(
                      title: widget.siteName,
                      snippet: 'Destination',
                    ),
                  ),
                if (userLatLng != null)
                  Marker(
                    markerId: const MarkerId('user'),
                    position: userLatLng!,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueAzure,
                    ),
                    rotation: userBearing,
                    anchor: const Offset(0.5, 0.5),
                    infoWindow: const InfoWindow(
                      title: 'Your Location',
                      snippet: 'Current position',
                    ),
                  ),
              },
              polylines: {
                if (routePolyline.isNotEmpty)
                  Polyline(
                    polylineId: const PolylineId('route'),
                    points: routePolyline,
                    color: isMoving ? Colors.blue : Colors.green,
                    width: 5,
                    patterns: isMoving
                        ? [PatternItem.dash(20), PatternItem.gap(10)]
                        : [],
                    startCap: Cap.roundCap,
                    endCap: Cap.roundCap,
                    jointType: JointType.round,
                  ),
              },
              onMapCreated: (controller) {
                mapController = controller;
                // Fit both markers on screen if both locations are available
                if (userLatLng != null && siteLatLng != null) {
                  _fitMarkersOnScreen();
                }
              },
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              compassEnabled: true,
              rotateGesturesEnabled: true,
              tiltGesturesEnabled: true,
              mapType: MapType.normal,
              zoomControlsEnabled: false,
            )
          else
            const Center(child: CircularProgressIndicator()),

          // Custom back arrow and rectangle with motion indicator
          Positioned(
            top: 38,
            left: 0,
            right: 0,
            child: Row(
              children: [
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: ClipOval(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.chevron_left,
                            color: Colors.black,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Enhanced rectangle with motion indicator
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                    child: Container(
                      width: 285,
                      height: 125,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 6,
                              top: 10,
                              bottom: 10,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    const Icon(
                                      Icons.my_location,
                                      size: 25,
                                      color: Colors.blue,
                                    ),
                                    Positioned(
                                      right: -5,
                                      top: -5,
                                      child: _buildMotionIndicator(),
                                    ),
                                  ],
                                ),
                                const Icon(
                                  Icons.more_vert,
                                  size: 25,
                                  color: Colors.black,
                                ),
                                const Icon(
                                  Icons.location_on,
                                  size: 25,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // User's district with speed indicator
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 20,
                                    bottom: 8,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userDistrict ?? "Fetching...",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      if (isMoving && userSpeed > 0)
                                        Text(
                                          "${userSpeed.toStringAsFixed(1)} km/h",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.green,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                // Black line
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 30,
                                  ),
                                  child: Container(
                                    height: 1,
                                    color: Colors.black,
                                  ),
                                ),
                                // Tourism site location
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 20,
                                    top: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: isEditingDestination
                                            ? TextField(
                                                controller:
                                                    _destinationController,
                                                autofocus: true,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                ),
                                                decoration:
                                                    const InputDecoration(
                                                      hintText:
                                                          "Enter destination...",
                                                      border: InputBorder.none,
                                                      isDense: true,
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                    ),
                                                onSubmitted: (value) {
                                                  setState(() {
                                                    isEditingDestination =
                                                        false;
                                                  });
                                                  if (value.trim().isNotEmpty) {
                                                    fetchCoordinates(
                                                      customDestination: value
                                                          .trim(),
                                                    );
                                                  }
                                                },
                                              )
                                            : Text(
                                                widget.siteName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                      ),
                                      const SizedBox(width: 1),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            isEditingDestination = true;
                                            _destinationController.clear();
                                          });
                                        },
                                        child: const Icon(
                                          Icons.swap_vert,
                                          size: 28,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Action buttons with loading indicators
          Positioned(
            top: 555,
            left: 5,
            right: 5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // VR Tour button
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            VirtualTourScreen(placeName: widget.siteName),
                      ),
                    );
                  },
                  child: Container(
                    height: 55,
                    width: 55,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 5,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.threesixty,
                        color: Colors.black,
                        size: 25,
                      ),
                    ),
                  ),
                ),

                // Fit markers button
                GestureDetector(
                  onTap: _fitMarkersOnScreen,
                  child: Container(
                    height: 55,
                    width: 55,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 5,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.fit_screen,
                        color: Colors.black,
                        size: 25,
                      ),
                    ),
                  ),
                ),

                // Location button with loading indicator
                GestureDetector(
                  onTap: () {
                    if (userLatLng != null && mapController != null) {
                      mapController!.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: userLatLng!,
                            zoom: 16,
                            bearing: isMoving ? userBearing : 0,
                            tilt: isMoving ? 45 : 0,
                          ),
                        ),
                      );
                    }
                  },
                  child: Container(
                    height: 55,
                    width: 55,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 5,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Icons.my_location,
                          color: Colors.black,
                          size: 25,
                        ),
                        if (isLoadingRoute)
                          const Positioned(
                            bottom: 8,
                            right: 8,
                            child: SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Enhanced bottom rectangle with real-time data
          Positioned(
            left: 4,
            right: 4,
            bottom: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(
                  height: 170,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 18,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Route info row
                      Row(
                        children: [
                          const Icon(
                            Icons.directions_walk,
                            color: Colors.black,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Walking: ',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            isLoadingDurations
                                ? '...'
                                : (walkingDuration ?? '-'),
                            style: const TextStyle(color: Colors.black),
                          ),
                          const SizedBox(width: 18),
                          const Icon(
                            Icons.directions_bike,
                            color: Colors.black,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Biking: ',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            isLoadingDurations
                                ? '...'
                                : (bicyclingDuration ?? '-'),
                            style: const TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.directions_car,
                            color: Colors.black,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Driving: ',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            isLoadingDurations
                                ? '...'
                                : (drivingDuration ?? '-'),
                            style: const TextStyle(color: Colors.black),
                          ),
                          const SizedBox(width: 18),
                          const Icon(
                            Icons.straighten,
                            color: Colors.black,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Distance: ',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            isLoadingDurations ? '...' : (routeDistance ?? '-'),
                            style: const TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (error != null)
                        Text(
                          error!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (isLoadingRoute)
                        const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.blue,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
