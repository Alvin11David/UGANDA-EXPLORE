import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

class MapViewScreen extends StatefulWidget {
  final String siteName;
  final bool showCurrentLocation;

  const MapViewScreen({
    Key? key,
    required this.siteName,
    this.showCurrentLocation = false,
  }) : super(key: key);

  @override
  _MapViewScreenState createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> with TickerProviderStateMixin {
  static const String _apiKey = 'AIzaSyB7H463r_jOW8U9k-LPtmTmrUOoCLVW3Zg';

  LatLng? siteLatLng;
  LatLng? userLatLng;
  LatLng? previousUserLatLng;
  GoogleMapController? mapController;
  String? error;
  String userDistrict = "Fetching...";
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

  // Mode selection
  String selectedMode = 'driving';

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
      duration: const Duration(milliseconds: 1000),
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
    _motionTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _detectMotion();
    });
  }

  void _updateUserPosition(Position position) {
    final newLatLng = LatLng(position.latitude, position.longitude);
    setState(() {
      previousUserLatLng = userLatLng;
      userLatLng = newLatLng;
      if (previousUserLatLng != null) {
        userBearing = _calculateBearing(previousUserLatLng!, newLatLng);
      }
      userSpeed = position.speed * 3.6; // Convert m/s to km/h
      isMoving = userSpeed > 0.5;
    });
    if (isMoving && mapController != null) {
      _smoothCameraFollow();
    }
    if (siteLatLng != null && !isLoadingRoute) {
      _debouncedRouteUpdate();
    }
  }

  Timer? _routeUpdateTimer;

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
      
      // Handle different data types from Firestore
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
      
      // Check if both values are valid before creating LatLng
      if (latitude != null && longitude != null) {
        setState(() {
          siteLatLng = LatLng(latitude!, longitude!); // Use ! operator since we verified they're not null
          error = null;
        });
        
        // Fetch route and durations if user location is available
        if (userLatLng != null) {
          await fetchAndSetRoute();
          await fetchDurationsAndDistance();
        }
      } else {
        setState(() {
          error = 'Invalid coordinates for this site.';
          siteLatLng = null;
        });
      }
    } else {
      setState(() {
        error = 'Site not found in database.';
        siteLatLng = null;
      });
    }
  } catch (e) {
    setState(() {
      error = 'Error finding location: $e';
      siteLatLng = null;
    });
  }
}


  Future<void> fetchAndSetRoute() async {
    if (userLatLng == null || siteLatLng == null || isLoadingRoute) return;
    setState(() {
      isLoadingRoute = true;
      error = null;
    });
    try {
      final optimalRoute = await fetchRouteWithFallback(
        userLatLng!,
        siteLatLng!,
        _apiKey,
        mode: selectedMode,
      );
      setState(() {
        routePolyline = optimalRoute;
        isLoadingRoute = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to fetch optimal route: $e';
        isLoadingRoute = false;
        routePolyline = [];
      });
    }
  }

  Future<List<LatLng>> fetchRouteWithFallback(
    LatLng origin,
    LatLng destination,
    String apiKey, {
    String mode = 'driving',
  }) async {
    try {
      return await _fetchDirectRoute(origin, destination, apiKey, mode: mode);
    } catch (e) {
      print('Direct route failed: $e');
    }

    final distance = calculateDistance(origin, destination);

    if (distance <= 200) {
      try {
        return await fetchBestAlternativeRoute(origin, destination, apiKey, mode: mode);
      } catch (e) {
        print('Alternative route failed: $e');
      }
    } else {
      try {
        return await fetchOptimalRouteWithMinimalWaypoints(origin, destination, apiKey, mode: mode);
      } catch (e) {
        print('Optimal route with waypoints failed: $e');
      }
    }

    return [origin, destination];
  }

  Future<List<LatLng>> _fetchDirectRoute(
    LatLng origin,
    LatLng destination,
    String apiKey, {
    String mode = 'driving',
  }) async {
    final url = 'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${origin.latitude},${origin.longitude}&'
        'destination=${destination.latitude},${destination.longitude}&'
        'mode=$mode&'
        'avoid=tolls&'
        'optimize_waypoints=false&'
        'overview=full&'
        'key=$apiKey';

    final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
        final steps = data['routes'][0]['legs'][0]['steps'] as List;
        final decodedPoints = steps.expand((step) {
          final encoded = step['polyline']['points'];
          return decodePolyline(encoded);
        }).toList();

        if (_validateRoute(decodedPoints)) {
          return decodedPoints;
        } else {
          throw Exception('Route validation failed - too many off-road segments');
        }
      } else {
        throw Exception('API returned: ${data['status']} - ${data['error_message'] ?? 'Unknown error'}');
      }
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  Future<List<LatLng>> fetchOptimalRouteWithMinimalWaypoints(
    LatLng origin,
    LatLng destination,
    String apiKey, {
    String mode = 'driving',
  }) async {
    final distance = calculateDistance(origin, destination);
    List<LatLng> waypoints = [];

    int waypointCount = 0;
    if (distance > 100) {
      waypointCount = (((distance - 1) ~/ 100) * 2).clamp(2, 10);
    }

    for (int i = 1; i <= waypointCount; i++) {
      final fraction = i / (waypointCount + 1);
      final lat = origin.latitude + (destination.latitude - origin.latitude) * fraction;
      final lng = origin.longitude + (destination.longitude - origin.longitude) * fraction;
      waypoints.add(LatLng(lat, lng));
    }

    String waypointsString = '';
    if (waypoints.isNotEmpty) {
      waypointsString = '&waypoints=' +
          waypoints.map((point) => '${point.latitude},${point.longitude}').join('|');
    }

    final url = 'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${origin.latitude},${origin.longitude}&'
        'destination=${destination.latitude},${destination.longitude}&'
        'mode=$mode&'
        'avoid=tolls&'
        'optimize_waypoints=false&'
        '$waypointsString&'
        'overview=full&'
        'key=$apiKey';

    final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
        final steps = data['routes'][0]['legs'][0]['steps'] as List;
        final decodedPoints = steps.expand((step) {
          final encoded = step['polyline']['points'];
          return decodePolyline(encoded);
        }).toList();

        if (_validateRoute(decodedPoints)) {
          return decodedPoints;
        } else {
          return await _fetchDirectRoute(origin, destination, apiKey, mode: mode);
        }
      } else {
        throw Exception('Waypoint API returned: ${data['status']} - ${data['error_message'] ?? 'Unknown error'}');
      }
    } else {
      throw Exception('HTTP ${response.statusCode}');
    }
  }

  bool _validateRoute(List<LatLng> route) {
    if (route.length < 2) return false;

    for (int i = 1; i < route.length; i++) {
      final distance = calculateDistance(route[i - 1], route[i]);
      if (distance > 50) {
        return false;
      }
    }
    return true;
  }

  Future<List<LatLng>> fetchBestAlternativeRoute(
    LatLng origin,
    LatLng destination,
    String apiKey, {
    String mode = 'driving',
  }) async {
    final url = 'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${origin.latitude},${origin.longitude}&'
        'destination=${destination.latitude},${destination.longitude}&'
        'alternatives=true&'
        'mode=$mode&'
        'avoid=tolls&'
        'overview=full&'
        'key=$apiKey';

    final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
        final routes = data['routes'] as List;

        var bestRoute;
        double bestScore = double.infinity;

        for (var route in routes) {
          final steps = route['legs'][0]['steps'] as List;
          final allPoints = steps.expand((step) {
            return decodePolyline(step['polyline']['points']);
          }).toList();

          if (_validateRoute(allPoints)) {
            final score = allPoints.length.toDouble();
            if (score < bestScore) {
              bestScore = score;
              bestRoute = route;
            }
          }
        }

        if (bestRoute != null) {
          final steps = bestRoute['legs'][0]['steps'] as List;
          final allPoints = steps.expand((step) {
            return decodePolyline(step['polyline']['points']);
          }).toList();
          return allPoints;
        }
      }
    }

    throw Exception('No valid alternative routes found');
  }

  void _debouncedRouteUpdate() {
    _routeUpdateTimer?.cancel();
    _routeUpdateTimer = Timer(const Duration(seconds: 20), () {
      fetchAndSetRoute();
    });
  }

  double calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371;
    final lat1Rad = point1.latitude * math.pi / 180;
    final lat2Rad = point2.latitude * math.pi / 180;
    final deltaLatRad = (point2.latitude - point1.latitude) * math.pi / 180;
    final deltaLngRad = (point2.longitude - point1.longitude) * math.pi / 180;
    final a =
        math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
            math.cos(lat1Rad) *
                math.cos(lat2Rad) *
                math.sin(deltaLngRad / 2) *
                math.sin(deltaLngRad / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
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
            results[selectedMode]?['distance'] ??
            results['driving']?['distance'] ??
            results['walking']?['distance'] ??
            results['bicycling']?['distance'] ??
            '-';
        isLoadingDurations = false;
      });
    } catch (e) {
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
                color: (isMoving ? Colors.green : Colors.orange).withOpacity(0.5),
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
    if (mapController == null || userLatLng == null || siteLatLng == null) {
      return;
    }
    LatLngBounds bounds;
    if (userLatLng!.latitude > siteLatLng!.latitude) {
      bounds = LatLngBounds(southwest: siteLatLng!, northeast: userLatLng!);
    } else {
      bounds = LatLngBounds(southwest: userLatLng!, northeast: siteLatLng!);
    }
    mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  void _showDestinationDialog() {
    _destinationController.text = widget.siteName;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Destination'),
          content: TextField(
            controller: _destinationController,
            decoration: const InputDecoration(
              hintText: 'Enter destination name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final newDestination = _destinationController.text.trim();
                if (newDestination.isNotEmpty) {
                  await fetchCoordinates(customDestination: newDestination);
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildModeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ChoiceChip(
            label: const Text('Drive'),
            selected: selectedMode == 'driving',
            onSelected: (_) => _onModeChanged('driving'),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Bike'),
            selected: selectedMode == 'bicycling',
            onSelected: (_) => _onModeChanged('bicycling'),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Walk'),
            selected: selectedMode == 'walking',
            onSelected: (_) => _onModeChanged('walking'),
          ),
        ],
      ),
    );
  }

  void _onModeChanged(String mode) async {
    setState(() {
      selectedMode = mode;
      isLoadingRoute = true;
    });
    await fetchAndSetRoute();
    await fetchDurationsAndDistance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.siteName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_location_alt),
            onPressed: _showDestinationDialog,
            tooltip: 'Change Destination',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildModeSelector(),
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: siteLatLng ?? const LatLng(0, 0),
                    zoom: 14,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  polylines: routePolyline.isNotEmpty
                      ? {
                          Polyline(
                            polylineId: const PolylineId('route'),
                            color: Colors.blue,
                            width: 5,
                            points: routePolyline,
                          ),
                        }
                      : {},
                  markers: {
                    if (siteLatLng != null)
                      Marker(
                        markerId: const MarkerId('site'),
                        position: siteLatLng!,
                        infoWindow: InfoWindow(title: widget.siteName),
                        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                      ),
                    if (userLatLng != null)
                      Marker(
                        markerId: const MarkerId('user'),
                        position: userLatLng!,
                        infoWindow: const InfoWindow(title: 'You'),
                        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                      ),
                  },
                  onMapCreated: (controller) {
                    mapController = controller;
                    if (userLatLng != null && siteLatLng != null) {
                      _fitMarkersOnScreen();
                    }
                  },
                ),
                if (isLoadingRoute || isLoadingDurations)
                  const Positioned(
                    top: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                if (error != null)
                  Positioned(
                    top: 80,
                    left: 20,
                    right: 20,
                    child: Material(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          error!,
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Card(
                    margin: const EdgeInsets.all(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('District: $userDistrict'),
                              _buildMotionIndicator(),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  const Icon(Icons.directions_walk, color: Colors.green),
                                  Text('Walk: ${walkingDuration ?? '-'}'),
                                ],
                              ),
                              Column(
                                children: [
                                  const Icon(Icons.directions_bike, color: Colors.orange),
                                  Text('Bike: ${bicyclingDuration ?? '-'}'),
                                ],
                              ),
                              Column(
                                children: [
                                  const Icon(Icons.directions_car, color: Colors.blue),
                                  Text('Drive: ${drivingDuration ?? '-'}'),
                                ],
                              ),
                              Column(
                                children: [
                                  const Icon(Icons.straighten, color: Colors.black),
                                  Text('Distance: ${routeDistance ?? '-'}'),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}