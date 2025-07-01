import 'dart:ui';

import 'package:flutter/material.dart';

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
      body: Column(
        children: [
          const SizedBox(height: 10),
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
              const SizedBox(width: 5),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                    child: Container(
                      height: 51,
                      width: 360,
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
                                if (value.trim().isNotEmpty &&
                                    !recentKeywords.contains(value.trim())) {
                                  setState(() {
                                    recentKeywords.insert(0, value.trim());
                                  });
                                  searchController.clear();
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
              const SizedBox(width: 5),
              GestureDetector(
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
                padding: const EdgeInsets.only(right: 10, top: 15),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      recentKeywords.clear();
                    });
                  },
                  child: Text(
                    "Clear all",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w300,
                      fontSize: 13,
                      color: Colors.black,
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
        ],
      ),
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

