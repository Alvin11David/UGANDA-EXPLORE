import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlaceDetailsScreen extends StatefulWidget {
  final String siteName;

  const PlaceDetailsScreen({super.key, required this.siteName});

  @override
  State<PlaceDetailsScreen> createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends State<PlaceDetailsScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
  }

  void _startAutoScroll() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 3));
      if (_pageController.hasClients) {
        int nextPage = _currentPage + 1;
        if (nextPage >=
            (_pageController.positions.isNotEmpty
                ? _pageController.positions.first.viewportDimension
                : 1)) {
          nextPage = 0;
        }
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
        setState(() {
          _currentPage = nextPage;
        });
      }
    }
  }

  Future<List<String>> fetchSiteImages(String siteName) async {
    final trimmedSiteName = siteName.trim().toLowerCase();
    final query = await FirebaseFirestore.instance
        .collection('tourismsites')
        .get();

    for (var doc in query.docs) {
      final data = doc.data();
      final dbName = (data['name'] ?? '').toString();
      if (dbName.toLowerCase().contains(trimmedSiteName)) {
        final images = List<String>.from(data['images'] ?? []);
        return images.take(3).toList();
      }
    }
    return [];
  }

  Future<String?> fetchSiteName(String siteName) async {
    final trimmedSiteName = siteName.trim().toLowerCase();
    final query = await FirebaseFirestore.instance
        .collection('tourismsites')
        .get();

    for (var doc in query.docs) {
      final data = doc.data();
      final dbName = (data['name'] ?? '').toString();
      if (dbName.toLowerCase().contains(trimmedSiteName)) {
        return dbName;
      }
    }
    return null;
  }

  Future<String?> fetchSiteLocation(String siteName) async {
    final trimmedSiteName = siteName.trim().toLowerCase();
    final query = await FirebaseFirestore.instance
        .collection('tourismsites')
        .get();

    for (var doc in query.docs) {
      final data = doc.data();
      final dbName = (data['name'] ?? '').toString();
      if (dbName.toLowerCase().contains(trimmedSiteName)) {
        return data['location']?.toString();
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E3D4),
      body: Stack(
        children: [
          // Circle at the top
          Positioned(
            top: -170,
            left: MediaQuery.of(context).size.width / 2 - 275,
            child: SizedBox(
              width: 550,
              height: 550,
              child: FutureBuilder<List<String>>(
                future: fetchSiteImages(widget.siteName),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No images found.'));
                  }
                  final images = snapshot.data!;
                  return ClipOval(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: images.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Image.network(
                          images[index],
                          width: 550,
                          height: 550,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: 350,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                final bool isActive = _currentPage == index;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: isActive ? 20 : 15,
                    height: isActive ? 20 : 15,
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.transparent
                          : const Color(0xFF1FF813),
                      shape: BoxShape.circle,
                      border: isActive
                          ? Border.all(color: const Color(0xFF1FF813), width: 3)
                          : null,
                    ),
                  ),
                );
              }),
            ),
          ),
          Positioned(
            top: 15,
            left: 8,
            child: GestureDetector(
              onTap: () {
                Navigator.of(
                  context,
                ).pop(); // Pops back to the previous screen (SearchScreen)
              },
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Container(
                    width: 51,
                    height: 51,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
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
          ),
          Positioned(
            top: 90,
            right: 180,
            child: Row(
              children: [
                // 360° Tour
                Column(
                  children: [
                    ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.threesixty, // 360 arrow icon
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 1),
                    const Text(
                      "360° Tour",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 15),
                // AR View
                Column(
                  children: [
                    ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.qr_code_scanner, // AR scan icon
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 1),
                    const Text(
                      "AR View",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 15),
                // Location
                Column(
                  children: [
                    ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.location_on, // Location icon
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 1),
                    const Text(
                      "Location",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 170, // adjust as needed to appear below the circles
            left: 20,
            right: 20,
            child: FutureBuilder<String?>(
              future: fetchSiteName(widget.siteName),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink();
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return const SizedBox.shrink();
                }
                return Text(
                  snapshot.data!,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    fontFamily: 'Poppins',
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 210, // adjust as needed to appear below the name
            left: 20,
            right: 20,
            child: FutureBuilder<String?>(
              future: fetchSiteLocation(widget.siteName),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink();
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return const SizedBox.shrink();
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 30,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        snapshot.data!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                          fontFamily: 'Poppins',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Positioned(
            // Position at the bottom right border of the big image circle
            top:
                290, 
            left:
                MediaQuery.of(context).size.width / 2 +
                135, 
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.star_border,
                      color: Colors.white,
                      size: 60,
                    ),
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
