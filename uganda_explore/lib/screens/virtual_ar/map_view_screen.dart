import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

class MapViewScreen extends StatefulWidget {
  final String siteName;
  final bool showCurrentLocation;
  const MapViewScreen({super.key, required this.siteName, this.showCurrentLocation = false});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  LatLng? siteLatLng;
  LatLng? userLatLng;
  GoogleMapController? mapController;
  String? error;
  String? userDistrict = "Fetching...";
  bool isEditingDestination = false;
  final TextEditingController _destinationController = TextEditingController();
  List<LatLng> routePolyline = [];

  // Add these fields to your _MapViewScreenState class:
  String? walkingDuration;
  String? drivingDuration;
  String? bicyclingDuration;
  String? routeDistance;

  @override
  void initState() {
    super.initState();
    fetchCoordinates();
    fetchUserDistrict();
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
      // If both locations are available, fetch the route
      if (userLatLng != null && siteLatLng != null) {
        fetchAndSetRoute();
      }
    } catch (e) {
      setState(() {
        userDistrict = "Error: $e";
      });
    }
  }

  Future<void> fetchCoordinates({String? customDestination}) async {
    final searchName = customDestination ?? widget.siteName;
    print('Searching for site: "$searchName"');
    try {
      final query = await FirebaseFirestore.instance
          .collection('tourismsites')
          .where('name', isEqualTo: searchName.trim())
          .limit(1)
          .get();

      print('Query docs found: ${query.docs.length}');
      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        print('Doc data: ${doc.data()}');
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
          // If both locations are available, fetch the route
          if (userLatLng != null) {
            fetchAndSetRoute();
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
    // Replace with your actual Google Maps Directions API key
    const apiKey = 'AIzaSyCyqzryof5ULhLPpxqjtMPG22RtpOu7r3w';
    if (userLatLng != null && siteLatLng != null) {
      try {
        final polyline = await fetchRoutePolyline(
          userLatLng!,
          siteLatLng!,
          apiKey,
        );
        setState(() {
          routePolyline = polyline;
        });
      } catch (e) {
        setState(() {
          error = 'Failed to fetch route: $e';
        });
      }
    }
  }

  Future<List<LatLng>> fetchRoutePolyline(
    LatLng origin,
    LatLng destination,
    String apiKey,
  ) async {
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&mode=driving&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final points = data['routes'][0]['overview_polyline']['points'];
      return decodePolyline(points);
    } else {
      throw Exception('Failed to fetch route');
    }
  }

  // Polyline decoder (no external package needed)
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

  // Add this function to fetch durations and distance for all modes:
  Future<void> fetchDurationsAndDistance() async {
    if (userLatLng == null || siteLatLng == null) return;
    const apiKey = 'AIzaSyCyqzryof5ULhLPpxqjtMPG22RtpOu7r3w';
    final modes = ['walking', 'driving', 'bicycling'];
    final results = <String, Map<String, String>>{};

    for (final mode in modes) {
      final url =
          'https://maps.googleapis.com/maps/api/directions/json?origin=${userLatLng!.latitude},${userLatLng!.longitude}&destination=${siteLatLng!.latitude},${siteLatLng!.longitude}&mode=$mode&key=$apiKey';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final leg = data['routes'][0]['legs'][0];
          results[mode] = {
            'duration': leg['duration']['text'],
            'distance': leg['distance']['text'],
          };
        }
      }
    }

    setState(() {
      walkingDuration = results['walking']?['duration'] ?? '-';
      drivingDuration = results['driving']?['duration'] ?? '-';
      bicyclingDuration = results['bicycling']?['duration'] ?? '-';
      // Prefer driving distance, else walking, else bicycling
      routeDistance =
          results['driving']?['distance'] ??
          results['walking']?['distance'] ??
          results['bicycling']?['distance'] ??
          '-';
    });
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
                  ),
                if (userLatLng != null)
                  Marker(
                    markerId: const MarkerId('user'),
                    position: userLatLng!,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueAzure,
                    ),
                  ),
              },
              polylines: {
                if (routePolyline.isNotEmpty)
                  Polyline(
                    polylineId: const PolylineId('route'),
                    points: routePolyline,
                    color: const Color(0xFF1FF813),
                    width: 4,
                  ),
              },
              onMapCreated: (controller) => mapController = controller,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
            )
          else
            const Center(child: CircularProgressIndicator()),
          // Custom back arrow and rectangle in the same row
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
                // Rectangle with blur and border
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                    child: Container(
                      width: 285,
                      height: 105,
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
                              children: const [
                                Icon(
                                  Icons.my_location,
                                  size: 25,
                                  color: Colors.blue,
                                ),
                                Icon(
                                  Icons.more_vert,
                                  size: 25,
                                  color: Colors.black,
                                ),
                                Icon(
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
                                // User's district above the line
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 20,
                                    bottom: 8,
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      userDistrict ?? "Fetching...",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
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
                                // Tourism site location below the line with swap_vert icon or text input
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
          Positioned(
            // Adjust 'top' as needed to position below the rectangle
            top: 555,
            left: 5, // Add left padding of 5
            right: 5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // NEW: Add your custom circle on the left
                GestureDetector(
                  //onTap: () {
                  // TODO: Replace 'Your360Screen' with your actual 360 screen widget/class
                  //Navigator.push(
                  //context,
                  //MaterialPageRoute(
                  //builder: (context) => Your360Screen(siteName: widget.siteName),
                  //),
                  //);
                  //},
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
                // Existing location circle on the right
                GestureDetector(
                  onTap: () {
                    if (userLatLng != null && mapController != null) {
                      mapController!.animateCamera(
                        CameraUpdate.newLatLng(userLatLng!),
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
                    child: const Center(
                      child: Icon(
                        Icons.my_location,
                        color: Colors.black,
                        size: 25,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bottom rectangle
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
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: Stack(
                    children: [
                      // Place name in the top left corner
                      Positioned(
                        top: 16,
                        left: 20,
                        child: Text(
                          widget.siteName,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            fontFamily: 'Poppins',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Durations and distance row
                      Positioned(
                        top: 50,
                        left: 20,
                        right: 20,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // Walking
                            Icon(
                              Icons.directions_walk,
                              color: Colors.black,
                              size: 22,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              walkingDuration ?? '-',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Bicycling
                            Icon(
                              Icons.directions_bike,
                              color: Colors.black,
                              size: 22,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              bicyclingDuration ?? '-',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Car
                            Icon(
                              Icons.directions_car,
                              color: Colors.black,
                              size: 22,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              drivingDuration ?? '-',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Distance
                            Icon(
                              Icons.straighten,
                              color: Colors.black,
                              size: 22,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              routeDistance ?? '-',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        left: 20,
                        right: 20,
                        child: ElevatedButton(
                          onPressed: () async {
                            print('User: $userLatLng, Site: $siteLatLng');
                            // When pressed, fetch and draw the route polyline in green
                            await fetchAndSetRoute();
                            print(
                              'Polyline after fetch: ${routePolyline.length}',
                            );
                            if (routePolyline.isNotEmpty &&
                                mapController != null) {
                              final bounds = LatLngBounds(
                                southwest: LatLng(
                                  routePolyline
                                      .map((p) => p.latitude)
                                      .reduce((a, b) => a < b ? a : b),
                                  routePolyline
                                      .map((p) => p.longitude)
                                      .reduce((a, b) => a < b ? a : b),
                                ),
                                northeast: LatLng(
                                  routePolyline
                                      .map((p) => p.latitude)
                                      .reduce((a, b) => a > b ? a : b),
                                  routePolyline
                                      .map((p) => p.longitude)
                                      .reduce((a, b) => a > b ? a : b),
                                ),
                              );
                              await mapController!.animateCamera(
                                CameraUpdate.newLatLngBounds(bounds, 60),
                              );
                            } else {
                              print('No polyline to show!');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1FF813),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Start',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
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
        ],
      ),
    );
  }
}
