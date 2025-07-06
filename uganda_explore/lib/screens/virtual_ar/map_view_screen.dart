import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;

class MapViewScreen extends StatefulWidget {
  final String siteName;
  const MapViewScreen({super.key, required this.siteName});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  latlng.LatLng? siteLatLng;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchCoordinates();
  }

  Future<void> fetchCoordinates() async {
    print('Searching for site: "${widget.siteName}"');
    try {
      final query = await FirebaseFirestore.instance
          .collection('tourismsites')
          .where('name', isEqualTo: widget.siteName.trim())
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
      appBar: AppBar(title: Text(widget.siteName)),
      body: siteLatLng != null
          ? FlutterMap(
              options: MapOptions(center: siteLatLng, zoom: 14),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
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
                  ],
                ),
              ],
            )
          : Center(
              child: error != null
                  ? Text(error!)
                  : const CircularProgressIndicator(),
            ),
    );
  }
}
