import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uganda_explore/screens/home/results_screen.dart';
import 'package:uganda_explore/screens/home/search_screen.dart';
import 'package:uganda_explore/screens/virtual_ar/map_view_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showNavBar = true;
  String _district = 'Kampala';
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();

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
                                  if (checked[i])
                                    selectedCategories.add(categories[i]);
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

                                Navigator.pop(
                                  context,
                                );

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
    super.dispose();
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

    return Scaffold(
      backgroundColor: const Color(0xFF101624),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  SizedBox(
                    height: 155,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(30),
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.10),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.25),
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 35,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Image.asset(
                              'assets/logo/blackugandaexplore.png',
                              height: 60,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 95,
                          left: 4,
                          child: Row(
                            children: [
                              Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.location_on,
                                    color: Color(0xFF3B82F6),
                                    size: 28,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Location',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Text(
                                        _district,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 95,
                          right: 4,
                          child: Row(
                            children: [
                              Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.sunny,
                                    color: Color(0xFFF59E0B),
                                    size: 28,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Weather',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    '20° C',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: SizedBox(
                          width: 240,
                          child: ValueListenableBuilder<bool>(
                            valueListenable: isSearchFocused,
                            builder: (context, focused, child) {
                              return Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: focused
                                        ? const Color(0xFF1FF813)
                                        : Colors.transparent,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 16),
                                    const Icon(
                                      Icons.search,
                                      color: Colors.black,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextField(
                                        focusNode: searchFocusNode,
                                        controller: _searchController,
                                        decoration: const InputDecoration(
                                          hintText: 'Search Your Place',
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding:
                                              EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                        ),
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 16,
                                        ),
                                        onSubmitted: _onSearch,
                                        textInputAction: TextInputAction.search,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.arrow_forward, color: Colors.black),
                                      onPressed: () => _onSearch(_searchController.text),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 0),
                      GestureDetector(
                        onTap: () {
                          print('filter clicked');
                          _showFilterSheet(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          child: ValueListenableBuilder<bool>(
                            valueListenable: isFilterFocused,
                            builder: (context, focused, child) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 30,
                                    sigmaY: 30,
                                  ),
                                  child: Container(
                                    height: 50,
                                    width: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.18),
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: focused
                                            ? const Color(0xFF3B82F6)
                                            : Colors.white.withOpacity(0.25),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Focus(
                                      focusNode: filterFocusNode,
                                      child: const Center(
                                        child: Icon(
                                          Icons.filter_alt,
                                          color: Color(0xFF3B82F6),
                                          size: 26,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Padding(
                    padding: EdgeInsets.only(left: 18),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Popular Place Category',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Example: National Parks
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SearchScreen(),
                              ),
                            );
                          },
                          child: Container(
                            height: 50,
                            width: 200,
                            margin: const EdgeInsets.only(left: 15, right: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: const Color(0xFF3B82F6),
                                width: 1,
                              ),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                                stops: [0.0, 0.47],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 20),
                                const Icon(
                                  Icons.park,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  "National Parks",
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Example: Waterbodies
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SearchScreen(),
                              ),
                            );
                          },
                          child: Container(
                            height: 50,
                            width: 200,
                            margin: const EdgeInsets.only(left: 15, right: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: const Color(0xFF3B82F6),
                                width: 1,
                              ),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                                stops: [0.0, 0.47],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 20),
                                const Icon(
                                  Icons.water,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  "Waterbodies",
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Example: Mountains
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SearchScreen(),
                              ),
                            );
                          },
                          child: Container(
                            height: 50,
                            width: 200,
                            margin: const EdgeInsets.only(left: 15, right: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: const Color(0xFF3B82F6),
                                width: 1,
                              ),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                                stops: [0.0, 0.47],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 20),
                                const Icon(
                                  Icons.terrain,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  "Mountains",
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  Padding(
                    padding: EdgeInsets.only(left: 18),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "The Most Relevant Places",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Example: Bwindi Impenetrable N.P
                        Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SearchScreen(),
                                ),
                              );
                            },
                            child: Container(
                              height: 250,
                              width: 220,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 5,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: Stack(
                                  children: [
                                    Image.asset(
                                      'assets/images/baboon.png',
                                      height: 250,
                                      width: 220,
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      left: 0,
                                      right: 0,
                                      bottom: 0,
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(25),
                                          bottomRight: Radius.circular(25),
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                        ),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                            sigmaX: 30,
                                            sigmaY: 30,
                                          ),
                                          child: Container(
                                            height: 80,
                                            width: 220,
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(
                                                0.45,
                                              ),
                                              border: Border.all(
                                                color: Colors.white.withOpacity(
                                                  0.25,
                                                ),
                                                width: 1,
                                              ),
                                              borderRadius:
                                                  const BorderRadius.only(
                                                bottomLeft: Radius.circular(
                                                  25,
                                                ),
                                                bottomRight:
                                                    Radius.circular(25),
                                              ),
                                            ),
                                            child: Align(
                                              alignment: Alignment.topLeft,
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                  left: 5,
                                                  top: 12,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Text(
                                                      "Bwindi Impenetrable N.P",
                                                      style: TextStyle(
                                                        fontFamily: 'Poppins',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 15,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Row(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                            left: 1,
                                                            top: 1,
                                                          ),
                                                          child: Icon(
                                                            Icons.location_on,
                                                            color: Color(
                                                              0xFF3B82F6,
                                                            ),
                                                            size: 20,
                                                          ),
                                                        ),
                                                        Text(
                                                          "90km Kanungu District",
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Poppins',
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 15,
                                                            color: Colors.white,
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
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Example: Kazinga Channel
                        Padding(
                          padding: EdgeInsets.only(left: 30),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SearchScreen(),
                                ),
                              );
                            },
                            child: Container(
                              height: 250,
                              width: 220,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 5,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: Stack(
                                  children: [
                                    Image.asset(
                                      'assets/images/hippopotamus.png',
                                      height: 250,
                                      width: 220,
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      left: 0,
                                      right: 0,
                                      bottom: 0,
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(25),
                                          bottomRight: Radius.circular(25),
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                        ),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                            sigmaX: 30,
                                            sigmaY: 30,
                                          ),
                                          child: Container(
                                            height: 80,
                                            width: 220,
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(
                                                0.45,
                                              ),
                                              border: Border.all(
                                                color: Colors.white.withOpacity(
                                                  0.25,
                                                ),
                                                width: 1,
                                              ),
                                              borderRadius:
                                                  const BorderRadius.only(
                                                bottomLeft: Radius.circular(
                                                  25,
                                                ),
                                                bottomRight:
                                                    Radius.circular(25),
                                              ),
                                            ),
                                            child: Align(
                                              alignment: Alignment.topLeft,
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                  left: 5,
                                                  top: 12,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Text(
                                                      "Kazinga Channel",
                                                      style: TextStyle(
                                                        fontFamily: 'Poppins',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 15,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Row(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                            left: 1,
                                                            top: 1,
                                                          ),
                                                          child: Icon(
                                                            Icons.location_on,
                                                            color: Color(
                                                              0xFF3B82F6,
                                                            ),
                                                            size: 20,
                                                          ),
                                                        ),
                                                        Text(
                                                          "120km Kasese District",
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Poppins',
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 15,
                                                            color: Colors.white,
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
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Example: Mountain Elgon
                        Padding(
                          padding: EdgeInsets.only(left: 30),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SearchScreen(),
                                ),
                              );
                            },
                            child: Container(
                              height: 250,
                              width: 220,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 5,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: Stack(
                                  children: [
                                    Image.asset(
                                      'assets/images/mount.png',
                                      height: 250,
                                      width: 220,
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      left: 0,
                                      right: 0,
                                      bottom: 0,
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(25),
                                          bottomRight: Radius.circular(25),
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                        ),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                            sigmaX: 30,
                                            sigmaY: 30,
                                          ),
                                          child: Container(
                                            height: 80,
                                            width: 220,
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(
                                                0.45,
                                              ),
                                              border: Border.all(
                                                color: Colors.white.withOpacity(
                                                  0.25,
                                                ),
                                                width: 1,
                                              ),
                                              borderRadius:
                                                  const BorderRadius.only(
                                                bottomLeft: Radius.circular(
                                                  25,
                                                ),
                                                bottomRight:
                                                    Radius.circular(25),
                                              ),
                                            ),
                                            child: Align(
                                              alignment: Alignment.topLeft,
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                  left: 5,
                                                  top: 12,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Text(
                                                      "Mountain Elgon",
                                                      style: TextStyle(
                                                        fontFamily: 'Poppins',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 15,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Row(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                            left: 1,
                                                            top: 1,
                                                          ),
                                                          child: Icon(
                                                            Icons.location_on,
                                                            color: Color(
                                                              0xFF3B82F6,
                                                            ),
                                                            size: 20,
                                                          ),
                                                        ),
                                                        Text(
                                                          "320km Mbale District",
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Poppins',
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 15,
                                                            color: Colors.white,
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
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: GestureDetector(
                          onTap: () {
                            print('Location icon tapped');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MapViewScreen(
                                  siteName: 'Your Current Location',
                                  showCurrentLocation: true,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            height: 55,
                            width: 55,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
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
                                color: Color(0xFF3B82F6),
                                size: 25,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
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