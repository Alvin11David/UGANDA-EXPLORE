import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uganda_explore/screens/places/place_details_screen.dart';
import 'dart:math';

class NearbyAttractionsScreen extends StatefulWidget {
  const NearbyAttractionsScreen({super.key});

  @override
  State<NearbyAttractionsScreen> createState() =>
      _NearbyAttractionsScreenState();
}

class _NearbyAttractionsScreenState extends State<NearbyAttractionsScreen> {
  Position? _userPosition;
  List<Map<String, dynamic>> _nearbySites = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchNearbySites();
  }

  Future<void> _fetchNearbySites() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _loading = false);
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() => _loading = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() => _userPosition = position);

      final query = await FirebaseFirestore.instance
          .collection('tourismsites')
          .get();

      final userLat = position.latitude;
      final userLng = position.longitude;

      // Calculate distance and filter nearby (within 50km)
      List<Map<String, dynamic>> allSites = query.docs
          .map((doc) => doc.data())
          .toList();
      List<Map<String, dynamic>> nearby = allSites.where((site) {
        if (site['latitude'] == null || site['longitude'] == null) return false;
        double lat = site['latitude'] is double
            ? site['latitude']
            : double.tryParse(site['latitude'].toString()) ?? 0.0;
        double lng = site['longitude'] is double
            ? site['longitude']
            : double.tryParse(site['longitude'].toString()) ?? 0.0;
        double distance = _calculateDistance(userLat, userLng, lat, lng);
        site['distance'] = distance;
        return distance < 50; // 50km radius
      }).toList();

      // Sort by distance
      nearby.sort(
        (a, b) => (a['distance'] as double).compareTo(b['distance'] as double),
      );

      setState(() {
        _nearbySites = nearby;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const p = 0.017453292519943295;
    final a =
        0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Attractions Near Me',
          style: TextStyle(
            color: Color(0xFF3B82F6),
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF3B82F6)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe0eafc), Color(0xFFcfdef3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _nearbySites.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sentiment_dissatisfied,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No attractions found nearby.',
                      style: TextStyle(fontSize: 20, color: Colors.black54),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.only(top: 90, bottom: 24),
                itemCount: _nearbySites.length,
                itemBuilder: (context, idx) {
                  final site = _nearbySites[idx];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PlaceDetailsScreen(siteName: site['name']),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.10),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                          border: Border.all(
                            color: const Color(0xFF3B82F6).withOpacity(0.13),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(24),
                                bottomLeft: Radius.circular(24),
                              ),
                              child:
                                  site['images'] != null &&
                                      site['images'] is List &&
                                      site['images'].isNotEmpty
                                  ? Image.network(
                                      site['images'][0],
                                      width: 90,
                                      height: 90,
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) => Container(
                                        width: 90,
                                        height: 90,
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.broken_image,
                                          color: Colors.grey,
                                          size: 36,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      width: 90,
                                      height: 90,
                                      color: Colors.grey[200],
                                      child: const Icon(
                                        Icons.place,
                                        size: 40,
                                        color: Color(0xFF3B82F6),
                                      ),
                                    ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 16,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      site['name'] ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Color(0xFF3B82F6),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      site['location'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          size: 16,
                                          color: Color(0xFF3B82F6),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          "${site['distance']?.toStringAsFixed(1) ?? '--'} km away",
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(right: 16.0),
                              child: Icon(
                                Icons.chevron_right,
                                color: Color(0xFF3B82F6),
                                size: 32,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
