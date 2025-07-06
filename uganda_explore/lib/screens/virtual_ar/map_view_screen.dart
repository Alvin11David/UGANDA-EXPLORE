import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class MapViewScreen extends StatefulWidget {
  final String siteName;
  const MapViewScreen({super.key, required this.siteName});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  latlng.LatLng? siteLatLng;
  latlng.LatLng? userLatLng;
  String? error;
  String? userDistrict = "Fetching...";
  bool isEditingDestination = false;
  final TextEditingController _destinationController = TextEditingController();

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
        userLatLng = latlng.LatLng(position.latitude, position.longitude);
        userDistrict = placemarks.isNotEmpty
            ? (placemarks.first.subAdministrativeArea ??
                  placemarks.first.locality ??
                  "Unknown District")
            : "District not found";
      });
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
            siteLatLng = latlng.LatLng(latitude!, longitude!);
            error = null;
          });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          siteLatLng != null
              ? FlutterMap(
                  options: MapOptions(center: siteLatLng, zoom: 14),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    // Draw the line between user and site
                    PolylineLayer(
                      polylines: [
                        if (userLatLng != null && siteLatLng != null)
                          Polyline(
                            points: [userLatLng!, siteLatLng!],
                            color: const Color(0xFF1FF813),
                            strokeWidth: 4,
                          ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        if (siteLatLng != null)
                          Marker(
                            width: 40,
                            height: 40,
                            point: siteLatLng!,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        if (userLatLng != null)
                          Marker(
                            width: 40,
                            height: 40,
                            point: userLatLng!,
                            child: const Icon(
                              Icons.my_location,
                              color: Colors.blue,
                              size: 30,
                            ),
                          ),
                      ],
                    ),
                  ],
                )
              : Center(
                  child: error != null
                      ? Text(error!)
                      : const CircularProgressIndicator(),
                ),
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
            right: 5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
