import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:uganda_explore/screens/providers/favorites_provider.dart';
import 'package:uganda_explore/screens/virtual_ar/ar_scan_screen.dart';
import 'package:uganda_explore/screens/virtual_ar/map_view_screen.dart';
import 'package:uganda_explore/screens/virtual_ar/virtual_tour_screen.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uganda_explore/screens/places/street_view_page.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlaceDetailsScreen extends StatefulWidget {
  final String siteName;

  const PlaceDetailsScreen({super.key, required this.siteName});

  @override
  State<PlaceDetailsScreen> createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends State<PlaceDetailsScreen> {
  Map<String, dynamic>? _siteData;
  bool _isLoadingSiteData = true;
  bool _isStarSelected = false;
  final PageController _pageController = PageController();
  final int _currentPage = 0;
  List<String> _images = [];
  bool _autoScrollStarted = false;

  List<VideoPlayerController> _videoControllers = [];
  int _playingIndex = -1;
  int _selectedIndex = 0;

  final ValueNotifier<int> _currentPageNotifier = ValueNotifier<int>(0);

  bool _showNavBar = true;
  double _lastOffset = 0.0;
  final ScrollController _scrollController = ScrollController();

  bool _isFavourite = false;
  bool showThemeNotification = false;
  String themeMessage = '';
  bool get isDarkMode => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _fetchSiteData();
    fetchSiteImages(widget.siteName).then((imgs) {
      if (mounted) {
        setState(() {
          _images = imgs;
        });
        if (_images.length > 1) {
          _startAutoScroll();
        }
      }
    });
    _scrollController.addListener(_handleScroll);
  }

  Future<void> _fetchSiteData() async {
    final query = await FirebaseFirestore.instance
        .collection('tourismsites')
        .where('name', isEqualTo: widget.siteName)
        .get();
    if (query.docs.isNotEmpty) {
      setState(() {
        _siteData = query.docs.first.data();
        _isLoadingSiteData = false;
      });
    } else {
      setState(() {
        _siteData = null;
        _isLoadingSiteData = false;
      });
    }
  }

  void _handleScroll() {
    double offset = _scrollController.offset;
    if (offset > _lastOffset + 10 && _showNavBar) {
      setState(() => _showNavBar = false);
    } else if (offset < _lastOffset - 10 && !_showNavBar) {
      setState(() => _showNavBar = true);
    }
    _lastOffset = offset;
  }

  Future<void> _loadFavouriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList('favouriteSites') ?? [];
    setState(() {
      _isFavourite = favs.contains(widget.siteName);
    });
  }

  Future<void> _toggleFavourite() async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList('favouriteSites') ?? [];
    setState(() {
      if (_isFavourite) {
        favs.remove(widget.siteName);
        _isFavourite = false;
      } else {
        favs.add(widget.siteName);
        _isFavourite = true;
      }
    });
    await prefs.setStringList('favouriteSites', favs);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    for (var controller in _videoControllers) {
      controller.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() async {
    if (_autoScrollStarted) return;
    _autoScrollStarted = true;
    while (mounted && _images.length > 1) {
      await Future.delayed(const Duration(seconds: 3));
      if (_pageController.hasClients) {
        int nextPage = (_currentPageNotifier.value + 1) % _images.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
        _currentPageNotifier.value = nextPage;
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
      Navigator.pushReplacementNamed(context, '/settings');
    } else if (index == 2) {
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
        final lat = data['streetViewLat'] ?? data['latitude'];
        final lng = data['streetViewLng'] ?? data['longitude'];
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

  Future<List<String>> fetchSiteAudios(String siteName) async {
    final trimmedSiteName = siteName.trim().toLowerCase();
    final query = await FirebaseFirestore.instance
        .collection('tourismsites')
        .get();

    for (var doc in query.docs) {
      final data = doc.data();
      final dbName = (data['name'] ?? '').toString();
      if (dbName.toLowerCase() == trimmedSiteName) {
        final audios = List<String>.from(data['audios'] ?? []);
        return audios;
      }
    }
    return [];
  }

  void showTopNotification(BuildContext context, String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 20,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.black87 : Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: isDark ? Colors.white24 : Colors.black12,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 5, right: 10),
                  child: Image.asset(
                    isDark
                        ? 'assets/logo/blacklogo.png'
                        : 'assets/logo/whitelogo.png',
                    width: 32,
                    height: 32,
                  ),
                ),
                Flexible(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 3), () => entry.remove());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E3D4),
      body: Stack(
        children: [
          Positioned(
            top: -170,
            left: MediaQuery.of(context).size.width / 2 - 275,
            child: SizedBox(
              width: 550,
              height: 550,
              child: _images.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ClipOval(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _images.length,
                        onPageChanged: (index) {
                          _currentPageNotifier.value = index;
                        },
                        itemBuilder: (context, index) {
                          return Image.network(
                            _images[index],
                            width: 550,
                            height: 550,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
            ),
          ),
          Positioned(
            top: 350,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<int>(
              valueListenable: _currentPageNotifier,
              builder: (context, currentPage, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_images.length, (index) {
                    final bool isActive = currentPage == index;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: isActive ? 20 : 15,
                        height: isActive ? 20 : 15,
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.transparent
                              : const Color(0xFF3B82F6),
                          shape: BoxShape.circle,
                          border: isActive
                              ? Border.all(
                                  color: const Color(0xFF3B82F6),
                                  width: 3,
                                )
                              : null,
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
          Positioned(
            top: 38,
            left: 8,
            child: GestureDetector(
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
            right: 70,
            child: Row(
              children: [
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
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
                Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final latLng = await fetchLatLng(
                          widget.siteName.trim(),
                        );
                        if (latLng != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StreetViewPage(
                                siteName: widget.siteName.trim(),
                                latitude: latLng['lat'],
                                longitude: latLng['lng'],
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Location coordinates not found for Street View.',
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
                Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
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
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
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
            top: 170,
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
            top: 210,
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
            top: 290,
            left: MediaQuery.of(context).size.width / 2 + 85,
            child: GestureDetector(
              onTap: () async {
                setState(() {
                  _isStarSelected = !_isStarSelected;
                  showThemeNotification = true;
                  themeMessage = "Added to favourites";
                });
                final favoritesProvider = Provider.of<FavoritesProvider>(
                  context,
                  listen: false,
                );

                // Fetch site details from Firestore
                final query = await FirebaseFirestore.instance
                    .collection('tourismsites')
                    .where('name', isEqualTo: widget.siteName)
                    .get();
                if (query.docs.isNotEmpty) {
                  final siteData = query.docs.first.data();
                  if (_isStarSelected) {
                    favoritesProvider.addFavorite(widget.siteName);

                    // Show drop down notification for 3 seconds
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Added to favorites',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        duration: const Duration(seconds: 3),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor:
                            Colors.blue, // You can style as you wish
                        margin: const EdgeInsets.only(
                          top: 60,
                          left: 16,
                          right: 16,
                        ),
                      ),
                    );
                  } else {
                    favoritesProvider.removeFavorite(widget.siteName);
                  }
                }
                Future.delayed(const Duration(seconds: 3), () {
                  if (mounted) {
                    setState(() {
                      showThemeNotification = false;
                    });
                  }
                });
              },
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
                    child: Center(
                      child: Icon(
                        Icons.star_border,
                        color: _isStarSelected ? Colors.yellow : Colors.white,
                        size: 60,
                      ),
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
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        FutureBuilder<List<String>>(
                          future: fetchSiteVideos(widget.siteName),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return SizedBox(
                                height: 80,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: 3,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 16),
                                  itemBuilder: (context, index) => Container(
                                    width: 100,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.black12,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1,
                                      ),
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                ),
                              );
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
                                if (mounted) setState(() {});
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
                                      _showFullscreenVideo(controller);
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
                                                    child: const Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    ),
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
                        Container(height: 1, color: Colors.black),
                        const SizedBox(height: 12),
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
                        (_isLoadingSiteData ||
                                _siteData == null ||
                                _siteData!['description'] == null)
                            ? const SizedBox.shrink()
                            : Text(
                                _siteData!['description'],
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.normal,
                                  fontSize: 16,
                                ),
                              ),
                        FutureBuilder<List<String>>(
                          future: fetchSiteAudios(widget.siteName),
                          builder: (context, audioSnapshot) {
                            if (audioSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const SizedBox.shrink();
                            }
                            final audios = audioSnapshot.data ?? [];
                            if (audios.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return BackgroundAudioPlayer(urls: audios);
                          },
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          child: Container(height: 1, color: Colors.black),
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
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.attach_money,
                                      color: Colors.black,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      "Entry Fee: ",
                                      style: TextStyle(
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
                                    const Text(
                                      "Opening: ",
                                      style: TextStyle(
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
                                    const Text(
                                      "Closing: ",
                                      style: TextStyle(
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
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 300),
              offset: _showNavBar ? Offset.zero : const Offset(0, 1),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A8A),
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.25),
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
                            icon: Icons.settings,
                            label: 'Settings',
                            selected: _selectedIndex == 1,
                            onTap: () => _onItemTapped(1),
                          ),
                          _NavIcon(
                            icon: Icons.map,
                            label: 'Map',
                            selected: _selectedIndex == 2,
                            onTap: () => _onItemTapped(2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Notification overlay
          if (showThemeNotification)
            Positioned(
              top: 30,
              left: 60,
              right: 60,
              child: AnimatedOpacity(
                opacity: showThemeNotification ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, right: 10),
                        child: Image.asset(
                          isDarkMode
                              ? 'assets/logo/whitelogo.png'
                              : 'assets/logo/blacklogo.png',
                          height: 32,
                          width: 32,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          themeMessage,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            showThemeNotification = false;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

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
          color: selected ? const Color(0xFF3B82F6) : Colors.white,
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

class BackgroundAudioPlayer extends StatefulWidget {
  final List<String> urls;
  const BackgroundAudioPlayer({required this.urls, super.key});

  @override
  State<BackgroundAudioPlayer> createState() => _BackgroundAudioPlayerState();
}

class _BackgroundAudioPlayerState extends State<BackgroundAudioPlayer> {
  late AudioPlayer _player;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initPlaylist();
    _player.playerStateStream.listen((state) {
      setState(() {
        _isPlaying = state.playing;
      });
    });
  }

  Future<void> _initPlaylist() async {
    final playlist = ConcatenatingAudioSource(
      children: widget.urls
          .map((url) => AudioSource.uri(Uri.parse(url)))
          .toList(),
    );
    await _player.setAudioSource(playlist);
    await _player.setLoopMode(LoopMode.all);
    _player.play();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            _isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.black,
          ),
          onPressed: () {
            if (_isPlaying) {
              _player.pause();
            } else {
              _player.play();
            }
          },
        ),
        Text(_isPlaying ? "Playing background audio" : "Paused"),
      ],
    );
  }
}
