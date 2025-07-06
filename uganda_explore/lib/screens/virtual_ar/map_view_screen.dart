import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapViewScreen extends StatefulWidget {
  final String siteName;
  const MapViewScreen({super.key, required this.siteName});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  LatLng? siteLatLng;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchCoordinates();
  }

  Future<void> fetchCoordinates() async {
    final query = await FirebaseFirestore.instance
        .collection('tourismsites')
        .where('name', isEqualTo: widget.siteName)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      final lat = doc['latitude'];
      final lng = doc['longitude'];
      if (lat != null && lng != null) {
        setState(() {
          siteLatLng = LatLng(lat, lng);
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.siteName)),
      body: siteLatLng != null
          ? GoogleMap(
              initialCameraPosition: CameraPosition(
                target: siteLatLng!,
                zoom: 14,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('site'),
                  position: siteLatLng!,
                  infoWindow: InfoWindow(title: widget.siteName),
                ),
              },
            )
          : Center(
              child: error != null
                  ? Text(error!)
                  : const CircularProgressIndicator(),
            ),
    );
  }
}