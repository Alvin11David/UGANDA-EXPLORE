import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:uganda_explore/screens/home/results_screen.dart';
import 'package:uganda_explore/screens/places/place_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<String> recentKeywords = [];
  final TextEditingController searchController = TextEditingController();

  final FocusNode searchFocusNode = FocusNode();
  bool isSearchFocused = false;
  bool isBackFocused = false;
  bool isFilterFocused = false;

  @override
  void initState() {
    super.initState();
    searchFocusNode.addListener(() {
      setState(() {
        isSearchFocused = searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E3D4),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Center(
              child: Image.asset(
                'assets/logo/blackugandaexplore.png',
                height: 60,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/home');
                    // Or, if you use MaterialPageRoute:
                    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
                  },
                  onTapDown: (_) => setState(() => isBackFocused = true),
                  onTapUp: (_) => setState(() => isBackFocused = false),
                  onTapCancel: () => setState(() => isBackFocused = false),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          height: 51,
                          width: 51,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isBackFocused
                                  ? Color(0xFF1FF813)
                                  : Colors.white,
                              width: 1,
                            ),
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
                const SizedBox(width: 1),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                      child: Container(
                        height: 51,
                        width: 220,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: isSearchFocused
                                ? const Color(0xFF1FF813)
                                : Colors.white,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 8,
                              color: Colors.black.withOpacity(0.15),
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 15),
                            const Icon(
                              Icons.search,
                              color: Colors.black,
                              size: 30,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                focusNode: searchFocusNode,
                                decoration: const InputDecoration(
                                  hintText: 'Search Your Place',
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                ),
                                onSubmitted: (value) {
                                  final trimmed = value.trim();
                                  if (trimmed.isNotEmpty &&
                                      !recentKeywords.contains(trimmed)) {
                                    setState(() {
                                      recentKeywords.insert(0, trimmed);
                                    });
                                  }
                                  if (trimmed.isNotEmpty) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PlaceDetailsScreen(
                                              siteName: trimmed,
                                            ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 1),
                GestureDetector(
                  onTap: () {
                    _showFilterSheet(context);
                  },
                  onTapDown: (_) => setState(() => isFilterFocused = true),
                  onTapUp: (_) => setState(() => isFilterFocused = false),
                  onTapCancel: () => setState(() => isFilterFocused = false),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          height: 51,
                          width: 51,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isFilterFocused
                                  ? const Color(0xFF1FF813)
                                  : Colors.white,
                              width: 1,
                            ),
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
                              Icons.filter_alt,
                              color: Colors.black,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    "Your Search History",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10, top: 5),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        recentKeywords.clear();
                      });
                    },
                    child: Text(
                      "Clear All",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: recentKeywords
                      .map((keyword) => _buildKeywordChip(keyword))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    "Popular Searches",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ResultsScreen(selectedText: "Waterfall"),
                        ),
                      );
                    },
                    child: Container(
                      height: 50,
                      width: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/waterfall1.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 25),
                            child: Icon(
                              Icons.waterfall_chart,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Waterfall",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  blurRadius: 5,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ResultsScreen(selectedText: "Historical Site"),
                        ),
                      );
                    },
                    child: Container(
                      height: 50,
                      width: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/culturalsites.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 18),
                            child: Icon(
                              Icons.museum,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Cultural",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  blurRadius: 5,
                                  offset: Offset(0, 2),
                                ),
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
            const SizedBox(height: 25),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ResultsScreen(selectedText: "National Park"),
                        ),
                      );
                    },
                    child: Container(
                      height: 50,
                      width: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/gameparks.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 5),
                            child: Icon(
                              Icons.nature,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "GameParks",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  blurRadius: 5,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ResultsScreen(selectedText: "Forest"),
                        ),
                      );
                    },
                    child: Container(
                      height: 50,
                      width: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/forest.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 25),
                            child: Icon(
                              Icons.forest,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Forests",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  blurRadius: 5,
                                  offset: Offset(0, 2),
                                ),
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
            const SizedBox(height: 25),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ResultsScreen(selectedText: "Lakes"),
                        ),
                      );
                    },
                    child: Container(
                      height: 50,
                      width: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/lakes.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 25),
                            child: Icon(
                              Icons.water,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Lakes",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  blurRadius: 5,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ResultsScreen(selectedText: "Mountain"),
                        ),
                      );
                    },
                    child: Container(
                      height: 50,
                      width: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/wildlife.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 15),
                            child: Icon(
                              Icons.terrain,
                              color: Color.fromARGB(255, 255, 255, 255),
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Mountains",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  blurRadius: 5,
                                  offset: Offset(0, 2),
                                ),
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
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        // State for checkboxes and dropdown
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
                        // Title
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
                        // Categories
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
                        // Dropdown
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
                        // Apply Filter Button
                        SizedBox(
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: ElevatedButton(
                              onPressed: () {
                                // Get all checked categories
                                final selectedCategories = <String>[];
                                for (int i = 0; i < categories.length; i++) {
                                  if (checked[i]) {
                                    selectedCategories.add(categories[i]);
                                  }
                                }

                                if (selectedCategories.isEmpty) {
                                  // Show a message if nothing is selected
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please select at least one category.',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                // For now, just use the first checked category
                                final selectedCategory =
                                    selectedCategories.first;

                                Navigator.pop(
                                  context,
                                ); // Close the filter sheet

                                // Navigate to ResultsScreen for the selected category
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
}

Widget _buildKeywordChip(String keyword) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.3),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: Colors.white, width: 1),
    ),
    child: Text(
      keyword,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 15,
        color: Colors.black,
      ),
    ),
  );
}

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            width: 400,
            height: 61,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              border: Border.all(color: Colors.white, width: 1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Container(
                    height: 48,
                    width: 90,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1FF813),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 6, right: 6),
                          child: Icon(
                            Icons.home,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const Text(
                          "Home",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  height: 48,
                  width: 48,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.person, color: Colors.black, size: 30),
                  ),
                ),
                const Spacer(),
                Container(
                  height: 48,
                  width: 48,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.settings, color: Colors.black, size: 30),
                  ),
                ),
                const Spacer(),
                Container(
                  height: 48,
                  width: 48,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.map, color: Colors.black, size: 30),
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
