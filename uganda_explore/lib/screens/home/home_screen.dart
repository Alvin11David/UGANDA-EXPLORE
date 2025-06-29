import 'dart:ui';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

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
      backgroundColor: const Color(0xFFE5E3D4),
      body: Column(
        children: [
          // Header section with Stack
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
                        color: Colors.white.withOpacity(0.15),
                        border: Border.all(
                          color: Colors.white.withOpacity(1),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                // Logo
                Positioned(
                  top: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Image.asset(
                      'logo/blackugandaexplore.png',
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                // Location
                Positioned(
                  top: 80,
                  left: 4,
                  child: Row(
                    children: [
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
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
                            color: Colors.black87,
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
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: const [
                              Text(
                                'Kampala',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 20,
                                color: Colors.black87,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Weather
                Positioned(
                  top: 80,
                  right: 4,
                  child: Row(
                    children: [
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
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
                            color: Colors.amber,
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
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            '20° C',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.black87,
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

          // Search bar
          const SizedBox(height: 20),
          // Replace your current search bar Padding widget with the following:

Padding(
  padding: const EdgeInsets.symmetric(horizontal: 15),
  child: Align(
    alignment: Alignment.centerLeft,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 400, 
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
                    color: focused ? const Color(0xFF1FF813) : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    const Icon(Icons.search, color: Colors.black, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        focusNode: searchFocusNode,
                        decoration: const InputDecoration(
                          hintText: 'Search Your Place',
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        
        ValueListenableBuilder<bool>(
          valueListenable: isFilterFocused,
          builder: (context, focused, child) {
            return GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(filterFocusNode);
              },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(
                  height: 50,
                  width: 70,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: focused ? const Color(0xFF1FF813) : Colors.white,
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
                      color: Colors.black,
                      size: 26,
                ),
              ),
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
),
        ],
      ),
    );
  }
}
