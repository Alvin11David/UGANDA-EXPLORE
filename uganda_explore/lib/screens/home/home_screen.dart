import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:uganda_explore/screens/home/chat_screen_dart.dart';
import 'package:uganda_explore/screens/home/results_screen.dart';
import 'package:uganda_explore/screens/providers/favorites_provider.dart';
import 'package:uganda_explore/screens/virtual_ar/map_view_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uganda_explore/screens/places/place_details_screen.dart';
import 'package:uganda_explore/screens/places/street_view_page.dart';
import 'package:uganda_explore/screens/virtual_ar/virtual_tour_list_screen.dart.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class ImageCard extends StatelessWidget {
  final Map<String, dynamic> site;

  const ImageCard({super.key, required this.site});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Image.asset(
              site['image'],
              height: 120,
              width: 120,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(
                height: 120,
                width: 120,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
            if (site['streetViewLat'] != null && site['streetViewLng'] != null)
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StreetViewPage(
                          latitude: site['streetViewLat'],
                          longitude: site['streetViewLng'],
                          siteName: site['name'] ?? '',
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.threesixty,
                      color: Color(0xFF1FF813),
                      size: 26,
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          site['name'],
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1FF813),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Explore',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: Colors.black,
                          ),
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
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showNavBar = true;
  String _district = 'Kampala';
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  OverlayEntry? _suggestionsOverlay;
  List<Map<String, dynamic>> _suggestions = [];
  bool _isLoadingSuggestions = false;
  String _selectedCategory = '';
  final LayerLink _searchBarLink = LayerLink();

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
      setState(() {
        _selectedIndex = index;
      });
      Navigator.push(
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

  void _onSearch(String query) {
    if (query.trim().isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultsScreen(selectedText: query.trim()),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_showNavBar) setState(() => _showNavBar = false);
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!_showNavBar) setState(() => _showNavBar = true);
      }
    });
    _getCurrentDistrict();
  }

  Future<void> _getCurrentDistrict() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        setState(() {
          _district =
              placemarks.first.subAdministrativeArea ??
              placemarks.first.locality ??
              "Unknown";
        });
      }
    } catch (e) {
      print("Location error: $e");
    }
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        List<String> categories = [
          "National Parks",
          "Lakes",
          "Cultural Sites",
          "Adventure Activities",
          "Historical Landmarks",
        ];
        List<bool> checked = List.filled(categories.length, false);
        String selectedRegion = "Central";
        List<String> regions = [
          "Central",
          "Western",
          "Eastern",
          "Northern Uganda",
        ];

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    padding: const EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 24,
                      bottom: 0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Center(
                          child: Text(
                            "Filter screen",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Categories:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Column(
                          children: List.generate(categories.length, (i) {
                            return CheckboxListTile(
                              value: checked[i],
                              onChanged: (val) {
                                setModalState(() => checked[i] = val ?? false);
                              },
                              title: Text(
                                categories[i],
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                              activeColor: const Color(0xFF1FF813),
                              contentPadding: EdgeInsets.zero,
                            );
                          }),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Region:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                          child: DropdownButton<String>(
                            value: selectedRegion,
                            isExpanded: true,
                            underline: const SizedBox(),
                            icon: const Icon(Icons.keyboard_arrow_down_rounded),
                            items: regions.map((region) {
                              return DropdownMenuItem<String>(
                                value: region,
                                child: Text(region),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setModalState(
                                () => selectedRegion = val ?? "Central",
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: ElevatedButton(
                              onPressed: () {
                                final selectedCategories = <String>[];
                                for (int i = 0; i < categories.length; i++) {
                                  if (checked[i]) {
                                    selectedCategories.add(categories[i]);
                                  }
                                }

                                if (selectedCategories.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please select at least one category.',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                final selectedCategory =
                                    selectedCategories.first;

                                Navigator.pop(context);

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ResultsScreen(
                                      selectedText: selectedCategory,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 0,
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF000000),
                                      Color(0xFF1FF813),
                                    ],
                                    stops: [0.0, 0.47],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Container(
                                  alignment: Alignment.center,
                                  constraints: const BoxConstraints(
                                    minHeight: 50,
                                  ),
                                  child: const Text(
                                    "Apply Filter",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
              );
            },
          );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _removeSuggestionsOverlay();
    super.dispose();
  }

  void _removeSuggestionsOverlay() {
    _suggestionsOverlay?.remove();
    _suggestionsOverlay = null;
  }

  Future<void> _showSuggestionsOverlay(BuildContext context) async {
    _removeSuggestionsOverlay();
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset position = box.localToGlobal(Offset.zero);

    _suggestionsOverlay = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: position.dx + 15,
          top: position.dy + 70,
          width: 240,
          child: Material(
            color: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 220),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    border: Border.all(color: Colors.white.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: _isLoadingSuggestions
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : (_suggestions.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  'No matches found.',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                itemCount: _suggestions.length,
                                separatorBuilder: (_, __) => const Divider(
                                  height: 1,
                                  color: Colors.white24,
                                ),
                                itemBuilder: (context, index) {
                                  final site = _suggestions[index];
                                  return ListTile(
                                    tileColor: Colors.transparent,
                                    title: Text(
                                      site['name'] ?? '',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    onTap: () {
                                      _removeSuggestionsOverlay();
                                      FocusScope.of(context).unfocus();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => PlaceDetailsScreen(
                                            siteName: site['name'],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              )),
                ),
              ),
            ),
          ),
        );
      },
    );
    Overlay.of(context, rootOverlay: true).insert(_suggestionsOverlay!);
  }

  Future<void> _fetchSuggestions(String keyword) async {
    if (keyword.trim().isEmpty) {
      setState(() => _suggestions = []);
      _removeSuggestionsOverlay();
      return;
    }
    setState(() => _isLoadingSuggestions = true);
    final query = await FirebaseFirestore.instance
        .collection('tourismsites')
        .where('name', isGreaterThanOrEqualTo: keyword)
        .where('name', isLessThanOrEqualTo: '$keyword\uf8ff')
        .limit(6)
        .get();
    setState(() {
      _suggestions = query.docs.map((doc) => doc.data()).toList();
      _isLoadingSuggestions = false;
    });
    if (_searchFocusNode.hasFocus && _suggestions.isNotEmpty) {
      _showSuggestionsOverlay(context);
    } else {
      _removeSuggestionsOverlay();
    }
  }

  Future<void> _fetchSuggestionsDropdown(
    String keyword,
    BuildContext context,
  ) async {
    if (keyword.trim().isEmpty) {
      setState(() => _suggestions = []);
      _removeSuggestionsOverlay();
      return;
    }
    setState(() => _isLoadingSuggestions = true);
    final query = await FirebaseFirestore.instance
        .collection('tourismsites')
        .where('name', isGreaterThanOrEqualTo: keyword)
        .where('name', isLessThanOrEqualTo: '$keyword\uf8ff')
        .limit(6)
        .get();
    setState(() {
      _suggestions = query.docs.map((doc) => doc.data()).toList();
      _isLoadingSuggestions = false;
    });
    if (_searchFocusNode.hasFocus && _suggestions.isNotEmpty) {
      _showSuggestionsOverlay(context);
    } else {
      _removeSuggestionsOverlay();
    }
  }

  Stream<List<Map<String, dynamic>>> _fetchSites(String category) {
    return FirebaseFirestore.instance
        .collection('tourismsites')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  @override
  Widget build(BuildContext context) {
    final FocusNode searchFocusNode = FocusNode();
    final FocusNode filterFocusNode = FocusNode();
    ValueNotifier<bool> isSearchFocused = ValueNotifier(false);
    ValueNotifier<bool> isFilterFocused = ValueNotifier(false);

    searchFocusNode.addListener(() {
      isSearchFocused.value = searchFocusNode.hasFocus;
    });

    filterFocusNode.addListener(() {
      isFilterFocused.value = filterFocusNode.hasFocus;
    });

    final favoriteSites = Provider.of<FavoritesProvider>(context).favorites;

    return Scaffold(
      backgroundColor: const Color(0xFF101624),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  // ...existing widgets...

                  // Popular Place Category, Category Buttons, etc.

                  if (_selectedCategory.isNotEmpty)
                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _fetchSites(_selectedCategory),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final sites = snapshot.data!;
                        if (sites.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'No sites found for this category.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                              ),
                            ),
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Images Row
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  for (final site in sites)
                                    if (site['images'] != null &&
                                        site['images'] is List &&
                                        (site['images'] as List).isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 4),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    PlaceDetailsScreen(
                                                      siteName:
                                                          site['name'] ?? '',
                                                    ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            height: 250,
                                            width: 220,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.5),
                                                  blurRadius: 5,
                                                  offset: const Offset(0, 8),
                                                ),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              child: Stack(
                                                children: [
                                                  Image.network(
                                                    site['images'][0],
                                                    height: 250,
                                                    width: 220,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (c, e, s) =>
                                                        Container(
                                                          height: 250,
                                                          width: 220,
                                                          color:
                                                              Colors.grey[300],
                                                          child: const Icon(
                                                            Icons.broken_image,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                  ),
                                                  // 360° icon button in the top right corner if Street View is available
                                                  if (site['streetViewLat'] !=
                                                          null &&
                                                      site['streetViewLng'] !=
                                                          null)
                                                    Positioned(
                                                      top: 10,
                                                      right: 10,
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          // TODO: Implement StreetViewScreen navigation
                                                        },
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                      0.55,
                                                                    ),
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                          padding:
                                                              const EdgeInsets.all(
                                                                8,
                                                              ),
                                                          child: const Icon(
                                                            Icons.threesixty,
                                                            color: Color(
                                                              0xFF1FF813,
                                                            ),
                                                            size: 26,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  Positioned(
                                                    left: 0,
                                                    right: 0,
                                                    bottom: 0,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius.only(
                                                            bottomLeft:
                                                                Radius.circular(
                                                                  30,
                                                                ),
                                                            bottomRight:
                                                                Radius.circular(
                                                                  30,
                                                                ),
                                                          ),
                                                      child: BackdropFilter(
                                                        filter:
                                                            ImageFilter.blur(
                                                              sigmaX: 30,
                                                              sigmaY: 30,
                                                            ),
                                                        child: Container(
                                                          height: 80,
                                                          width: 219,
                                                          decoration: BoxDecoration(
                                                            color: Colors.white
                                                                .withOpacity(
                                                                  0.18,
                                                                ),
                                                            border: Border.all(
                                                              color:
                                                                  Colors.white,
                                                              width: 1,
                                                            ),
                                                            borderRadius:
                                                                const BorderRadius.only(
                                                                  bottomLeft:
                                                                      Radius.circular(
                                                                        30,
                                                                      ),
                                                                  bottomRight:
                                                                      Radius.circular(
                                                                        30,
                                                                      ),
                                                                ),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets.only(
                                                                  left: 3,
                                                                  top: 10,
                                                                  right: 8,
                                                                ),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  site['name'] ??
                                                                      '',
                                                                  style: const TextStyle(
                                                                    fontFamily:
                                                                        'Poppins',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        13,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 8,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    const Padding(
                                                                      padding:
                                                                          EdgeInsets.only(
                                                                            left:
                                                                                4,
                                                                          ),
                                                                      child: Icon(
                                                                        Icons
                                                                            .location_on,
                                                                        color: Color(
                                                                          0xFF3B82F6,
                                                                        ),
                                                                        size:
                                                                            20,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 6,
                                                                    ),
                                                                    Expanded(
                                                                      child: Text(
                                                                        site['location'] ??
                                                                            '',
                                                                        style: const TextStyle(
                                                                          fontFamily:
                                                                              'Poppins',
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          fontSize:
                                                                              13,
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                      ),
                                                                    ),
                                                                  ],
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
                                            ),
                                          ),
                                        ),
                                      ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),
                            Padding(
                              padding: const EdgeInsets.only(left: 18, bottom: 8),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'FAVORITES',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  for (final siteName in favoriteSites)
                                    FutureBuilder<DocumentSnapshot>(
                                      future: FirebaseFirestore.instance
                                          .collection('tourismsites')
                                          .where('name', isEqualTo: siteName)
                                          .limit(1)
                                          .get()
                                          .then((snapshot) {
                                            if (snapshot.docs.isNotEmpty) {
                                              return snapshot.docs.first;
                                            } else {
                                              throw Exception('No document found');
                                            }
                                          }),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData || snapshot.data == null) {
                                          return SizedBox.shrink();
                                        }
                                        final siteData = snapshot.data!.data() as Map<String, dynamic>;
                                        return Padding(
                                          padding: const EdgeInsets.only(left: 4),
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => PlaceDetailsScreen(
                                                    siteName: siteName,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              height: 250,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(30),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.5),
                                                    blurRadius: 5,
                                                    offset: const Offset(0, 8),
                                                  ),
                                                ],
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(30),
                                                child: Stack(
                                                  children: [
                                                    Image.network(
                                                      siteData['images'][0],
                                                      height: 250,
                                                      fit: BoxFit.cover,
                                                    ),
                                                    // 360° icon button in the top right corner if Street View is available
                                                    if (siteData['streetViewLat'] != null && siteData['streetViewLng'] != null)
                                                      Positioned(
                                                        top: 10,
                                                        right: 10,
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (_) => StreetViewPage(
                                                                  latitude: siteData['streetViewLat'],
                                                                  longitude: siteData['streetViewLng'],
                                                                  siteName: siteData['name'] ?? '',
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                              color: Colors.black.withOpacity(0.55),
                                                              shape: BoxShape.circle,
                                                            ),
                                                            padding: const EdgeInsets.all(8),
                                                            child: const Icon(
                                                              Icons.threesixty,
                                                              color: Color(0xFF1FF813),
                                                              size: 26,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    Positioned(
                                                      left: 0,
                                                      right: 0,
                                                      bottom: 0,
                                                      child: ClipRRect(
                                                        borderRadius: const BorderRadius.only(
                                                          bottomLeft: Radius.circular(30),
                                                          bottomRight: Radius.circular(30),
                                                        ),
                                                        child: BackdropFilter(
                                                          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                                                          child: Container(
                                                            height: 80,
                                                            width: 219,
                                                            decoration: BoxDecoration(
                                                              color: Colors.white.withOpacity(0.18),
                                                              border: Border.all(color: Colors.white, width: 1),
                                                              borderRadius: const BorderRadius.only(
                                                                bottomLeft: Radius.circular(30),
                                                                bottomRight: Radius.circular(30),
                                                              ),
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets.only(left: 3, top: 10, right: 8),
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Text(
                                                                    siteData['name'] ?? '',
                                                                    style: const TextStyle(
                                                                      fontFamily: 'Poppins',
                                                                      fontWeight: FontWeight.bold,
                                                                      fontSize: 13,
                                                                      color: Colors.white,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(height: 8),
                                                                  Row(
                                                                    children: [
                                                                      const Padding(
                                                                        padding: EdgeInsets.only(left: 4),
                                                                        child: Icon(
                                                                          Icons.location_on,
                                                                          color: Color(0xFF3B82F6),
                                                                          size: 20,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(width: 6),
                                                                      Expanded(
                                                                        child: Text(
                                                                          siteData['location'] ?? '',
                                                                          style: const TextStyle(
                                                                            fontFamily: 'Poppins',
                                                                            fontWeight: FontWeight.w500,
                                                                            fontSize: 13,
                                                                            color: Colors.white,
                                                                          ),
                                                                          overflow: TextOverflow.ellipsis,
                                                                        ),
                                                                      ),
                                                                    ],
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
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
          // ...existing bottom navigation and floating action button...
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF3B82F6),
          child: const Icon(Icons.smart_toy_outlined, color: Colors.white),
          tooltip: 'Virtual Guide',
          onPressed: () {
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              builder: (context) => Container(
                padding: const EdgeInsets.all(20),
                height: 380,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.chat_bubble, color: Color(0xFF3B82F6)),
                        const SizedBox(width: 10),
                        const Text(
                          'Virtual Guide',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 10),
                    const Text(
                      "Hi! I'm your virtual guide. How can I help you explore Uganda?",
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.threesixty, color: Colors.black),
                      label: const Text(
                        'Show me a virtual tour',
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const VirtualToursListScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.map, color: Colors.black),
                      label: const Text(
                        'Find attractions near me',
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        // Add your navigation logic here
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.chat_bubble_outline, color: Colors.black),
                      label: const Text(
                        'Chat with AI',
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ChatScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
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

// Category Button Widget
class _CategoryButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  IconData get icon {
    switch (label) {
      case "National Parks":
        return Icons.park;
      case "Waterbodies":
        return Icons.water;
      case "Mountains":
        return Icons.terrain;
      default:
        return Icons.place;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 50,
        width: 200,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF3B82F6) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? const Color(0xFF3B82F6) : Colors.white,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : const Color(0xFF3B82F6),
              size: 26,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: selected ? Colors.white : const Color(0xFF3B82F6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Image Card Widget for static images in popular searches
class SiteImageCard extends StatelessWidget {
  final Map<String, dynamic> site;

  const SiteImageCard({super.key, required this.site});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Image.asset(
              site['image'],
              height: 120,
              width: 120,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(
                height: 120,
                width: 120,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
            if (site['streetViewLat'] != null && site['streetViewLng'] != null)
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StreetViewPage(
                          latitude: site['streetViewLat'],
                          longitude: site['streetViewLng'],
                          siteName: site['name'] ?? '',
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.threesixty,
                      color: Color(0xFF1FF813),
                      size: 26,
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          site['name'],
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1FF813),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Explore',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: Colors.black,
                          ),
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
    );
  }
}