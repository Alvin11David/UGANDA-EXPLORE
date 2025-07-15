import 'dart:ui';
import 'package:uganda_explore/screens/virtual_ar/ar_scan_screen.dart';
import 'package:uganda_explore/screens/virtual_ar/map_view_screen.dart';
import 'package:uganda_explore/screens/virtual_ar/virtual_tour_screen.dart';
import 'package:video_player/video_player.dart';
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

  List<VideoPlayerController> _videoControllers = [];
  int _playingIndex = -1;
  int _selectedIndex = 0; 

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    for (var controller in _videoControllers) {
      controller.dispose();
    }
    super.dispose();
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

  Future<List<String>> fetchSiteVideos(String siteName) async {
    final trimmedSiteName = siteName.trim().toLowerCase();
    final query = await FirebaseFirestore.instance
        .collection('tourismsites')
        .get();

    for (var doc in query.docs) {
      final data = doc.data();
      final dbName = (data['name'] ?? '').toString();
      if (dbName.toLowerCase() == trimmedSiteName) {
        final videos = List<String>.from(data['videos'] ?? []);
        return videos.take(3).toList();
      }
    }
    return [];
  }

  void _autoPlayVideos() async {
    for (int i = 0; i < _videoControllers.length; i++) {
      setState(() {
        _playingIndex = i;
      });
      await _videoControllers[i].play();
      await Future.delayed(const Duration(seconds: 2));
      await _videoControllers[i].pause();
      await _videoControllers[i].seekTo(Duration.zero);
    }
    setState(() {
      _playingIndex = -1;
    });
  }

  Future<List<String>> fetchSiteImages(String siteName) async {
    final trimmedSiteName = siteName.trim().toLowerCase();
    final query = await FirebaseFirestore.instance
        .collection('tourismsites')
        .get();

    for (var doc in query.docs) {
      final data = doc.data();
      final dbName = (data['name'] ?? '').toString();
      if (dbName.toLowerCase() == trimmedSiteName) {
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
      if (dbName.toLowerCase() == trimmedSiteName) {
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
      if (dbName.toLowerCase() == trimmedSiteName) {
        return data['location']?.toString();
      }
    }
    return null;
  }

  Future<String?> fetchSiteDescription(String siteName) async {
    final trimmedSiteName = siteName.trim().toLowerCase();
    final query = await FirebaseFirestore.instance
        .collection('tourismsites')
        .get();

    for (var doc in query.docs) {
      final data = doc.data();
      final dbName = (data['name'] ?? '').toString();
      if (dbName.toLowerCase() == trimmedSiteName) {
        return data['description']?.toString();
      }
    }
    return null;
  }

  Future<Map<String, String>> fetchQuickInfo(String siteName) async {
    final trimmedSiteName = siteName.trim().toLowerCase();
    final query = await FirebaseFirestore.instance
        .collection('tourismsites')
        .get();

    for (var doc in query.docs) {
      final data = doc.data();
      final dbName = (data['name'] ?? '').toString();
      if (dbName.toLowerCase() == trimmedSiteName) {
        return {
          'entryfee': data['entryfee']?.toString() ?? '',
          'openingHours': data['openingHours']?.toString() ?? '',
          'closingHours': data['closingHours']?.toString() ?? '',
        };
      }
    }
    return {};
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      setState(() {
        _selectedIndex = index;
      });
      Navigator.pushReplacementNamed(context, '/home');
    } else if (index == 1) {
      setState(() {
        _selectedIndex = index;
      });
      Navigator.pushReplacementNamed(context, '/profile');
    } else if (index == 2) {
      setState(() {
        _selectedIndex = index;
      });
      Navigator.pushReplacementNamed(context, '/settings');
    } else if (index == 3) {
      // Do NOT call setState here, just navigate!
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MapViewScreen(
            siteName: 'Your Current Location',
            showCurrentLocation: true,
          ),
        ),
      );
    }
  }

  Future<Map<String, double>?> fetchLatLng(String siteName) async {
    final trimmedSiteName = siteName.trim().toLowerCase();
    final query = await FirebaseFirestore.instance
        .collection('tourismsites')
        .get();

    for (var doc in query.docs) {
      final data = doc.data();
      final dbName = (data['name'] ?? '').toString();
      if (dbName.toLowerCase() == trimmedSiteName) {
        final lat = data['latitude'];
        final lng = data['longitude'];
        if (lat != null && lng != null) {
          return {
            'lat': (lat as num).toDouble(),
            'lng': (lng as num).toDouble(),
          };
        }
      }
    }
    return null;
  }

  void _showFullscreenVideo(VideoPlayerController controller) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(8),
          child: AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayer(controller),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () {
                      controller.pause();
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
            top: 38,
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
                    width: 50,
                    height: 50,
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
            right: 100,
            child: Row(
              children: [
                // 360° Tour
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        print(
                          '360° Tour button tapped for: ${widget.siteName}',
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VirtualTourScreen(
                              placeName: widget.siteName.trim(),
                            ),
                          ),
                        );
                      },
                      child: ClipOval(
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
                                Icons.threesixty,
                                color: Colors.white,
                                size: 30,
                              ),
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
                    GestureDetector(
                      onTap: () async {
                        print('AR Scan button tapped');
                        final latLng = await fetchLatLng(
                          widget.siteName.trim(),
                        );
                        if (latLng != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ARScanScreen(
                                destinationLat: latLng['lat']!,
                                destinationLng: latLng['lng']!,
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Location not found for this site.',
                              ),
                            ),
                          );
                        }
                      },
                      child: ClipOval(
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
                                Icons.qr_code_scanner,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 1),
                    const Text(
                      "AR Scan",
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
                // Street View
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: ClipOval(
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
                                Icons.streetview,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 1),
                    const Text(
                      "Street View",
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
                // Find this section for the Location circle:
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        print('Location button tapped for: ${widget.siteName}');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                MapViewScreen(siteName: widget.siteName.trim()),
                          ),
                        );
                      },
                      child: ClipOval(
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
                                Icons.location_on,
                                color: Colors.white,
                                size: 30,
                              ),
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
            left: 10,
            right: 10,
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
            left: 10,
            right: 10,
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
            top: 290,
            left: MediaQuery.of(context).size.width / 2 + 85,
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
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(
                  height: 400,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(
                      255,
                      255,
                      255,
                      255,
                    ).withOpacity(0.3),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Video Preview label
                        const Padding(
                          padding: EdgeInsets.only(left: 4, bottom: 8),
                          child: Text(
                            "Video Preview",
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        // Videos row
                        FutureBuilder<List<String>>(
                          future: fetchSiteVideos(widget.siteName),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const SizedBox.shrink();
                            }
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            final videos = snapshot.data!;
                            if (_videoControllers.length != videos.length) {
                              for (var controller in _videoControllers) {
                                controller.dispose();
                              }
                              _videoControllers = videos
                                  .map(
                                    (url) => VideoPlayerController.network(url)
                                      ..setLooping(true)
                                      ..initialize(),
                                  )
                                  .toList();
                              Future.wait(
                                _videoControllers.map((c) => c.initialize()),
                              ).then((_) {
                                if (mounted) _autoPlayVideos();
                              });
                            }
                            return SizedBox(
                              height: 80,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: videos.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 16),
                                itemBuilder: (context, index) {
                                  final controller = _videoControllers[index];
                                  return GestureDetector(
                                    onTap: () async {
                                      for (var c in _videoControllers) {
                                        await c.pause();
                                        await c.seekTo(Duration.zero);
                                      }
                                      setState(() {
                                        _playingIndex = index;
                                      });
                                      await controller.play();
                                      _showFullscreenVideo(
                                        controller,
                                      ); // <-- Show fullscreen dialog
                                    },
                                    child: Container(
                                      width: 100,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 1,
                                        ),
                                      ),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            child:
                                                controller.value.isInitialized
                                                ? SizedBox(
                                                    width: 100,
                                                    height: 80,
                                                    child: FittedBox(
                                                      fit: BoxFit.cover,
                                                      child: SizedBox(
                                                        width: controller
                                                            .value
                                                            .size
                                                            .width,
                                                        height: controller
                                                            .value
                                                            .size
                                                            .height,
                                                        child: VideoPlayer(
                                                          controller,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : Container(
                                                    width: 100,
                                                    height: 80,
                                                    color: Colors.black12,
                                                  ),
                                          ),
                                          if (_playingIndex != index)
                                            const Icon(
                                              Icons.play_circle_outline,
                                              color: Colors.white,
                                              size: 40,
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        // Black line
                        Container(height: 1, color: Colors.black),
                        const SizedBox(height: 12),
                        // Place Description label
                        const Padding(
                          padding: EdgeInsets.only(left: 4, bottom: 8),
                          child: Text(
                            "Place Description",
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        // Place Description text
                        FutureBuilder<String?>(
                          future: fetchSiteDescription(widget.siteName),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const SizedBox.shrink();
                            }
                            if (!snapshot.hasData || snapshot.data == null) {
                              return const SizedBox.shrink();
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  snapshot.data!,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.normal,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 0,
                                  ),
                                  child: Container(
                                    height: 1,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Padding(
                                  padding: EdgeInsets.only(left: 4),
                                  child: Text(
                                    "Quick Information",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                FutureBuilder<Map<String, String>>(
                                  future: fetchQuickInfo(widget.siteName),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const SizedBox.shrink();
                                    }
                                    if (!snapshot.hasData ||
                                        snapshot.data!.isEmpty) {
                                      return const Text(
                                        "No quick information available.",
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontFamily: 'Poppins',
                                          fontSize: 14,
                                        ),
                                      );
                                    }
                                    final info = snapshot.data!;
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.attach_money,
                                              color: Colors.black,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              "Entry Fee: ",
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              info['entryfee'] ?? '',
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.normal,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.access_time,
                                              color: Colors.black,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              "Opening: ",
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              info['openingHours'] ?? '',
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.normal,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.lock_clock,
                                              color: Colors.black,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              "Closing: ",
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              info['closingHours'] ?? '',
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.normal,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Add the custom nav bar at the bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _NavIcon(
                          icon: Icons.home,
                          label: 'Home',
                          selected: _selectedIndex == 0,
                          onTap: () => _onItemTapped(0),
                        ),
                        _NavIcon(
                          icon: Icons.person,
                          label: 'Profile',
                          selected: _selectedIndex == 1,
                          onTap: () => _onItemTapped(1),
                        ),
                        _NavIcon(
                          icon: Icons.settings,
                          label: 'Settings',
                          selected: _selectedIndex == 2,
                          onTap: () => _onItemTapped(2),
                        ),
                        _NavIcon(
                          icon: Icons.map,
                          label: 'Map',
                          selected: _selectedIndex == 3,
                          onTap: () => _onItemTapped(3),
                        ),
                      ],
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

// Add this widget at the bottom of your file if not already present
class _NavIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavIcon({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1FF813) : Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? Colors.white : Colors.black, size: 24),
            if (selected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
