import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ResultsScreen extends StatefulWidget {
  final String selectedText;
  const ResultsScreen({super.key, required this.selectedText});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  Future<List<Map<String, String>>> fetchSiteImages() async {
    final query = await FirebaseFirestore.instance
        .collection('tourismsites')
        .get();
    // Get the first image and name from each document (if available)
    return query.docs
        .map((doc) {
          final images = doc['images'];
          final name = doc['name']?.toString() ?? '';
          if (images is List && images.isNotEmpty) {
            return {'image': images.first.toString(), 'name': name};
          }
          return null;
        })
        .whereType<Map<String, String>>()
        .take(6)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E3D4),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 16),
                Center(
                  child: Image.asset(
                    'assets/logo/blackugandaexplore.png',
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  widget.selectedText,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
            Positioned(
              top: 50,
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
              left: 4,
              right: 4,
              bottom: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Container(
                    height: 600,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 4.0,
                        right: 4.0,
                        top: 32.0,
                        bottom: 0,
                      ),
                      child: FutureBuilder<List<Map<String, String>>>(
                        future: fetchSiteImages(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final items = snapshot.data ?? [];
                          return GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 30,
                                  crossAxisSpacing: 30,
                                  childAspectRatio: 0.9,
                                ),
                            itemCount: 6,
                            itemBuilder: (context, index) {
                              return Container(
                                width: 100,
                                height: 260,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.25),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: items.length > index &&
                                        widget.selectedText == "Game Parks"
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                          left: 3,
                                          top: 3,
                                          right: 3,
                                        ),
                                        child: Column(
                                          children: [
                                            Stack(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator.pushNamed(
                                                      context,
                                                      '/place_details',
                                                      arguments: items[index]['name'],
                                                    );
                                                  },
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(30),
                                                    child: Image.network(
                                                      items[index]['image'] ?? '',
                                                      width: 150,
                                                      height: 125,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 6,
                                                  right: 6,
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      Navigator.pushNamed(
                                                        context,
                                                        '/place_details',
                                                        arguments: items[index]['name'],
                                                      );
                                                    },
                                                    child: ClipOval(
                                                      child: BackdropFilter(
                                                        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                                                        child: Container(
                                                          width: 35,
                                                          height: 35,
                                                          decoration: BoxDecoration(
                                                            color: Colors.white.withOpacity(0.3),
                                                            shape: BoxShape.circle,
                                                            border: Border.all(color: Colors.white, width: 1),
                                                          ),
                                                          child: Center(
                                                            child: Transform.rotate(
                                                              angle: 0.785398, // -45 degrees in radians (north east)
                                                              child: const Icon(
                                                                Icons.arrow_upward,
                                                                color: Colors.black,
                                                                size: 22,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              items[index]['name'] ?? '',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              );
                            },
                          );
                        },
                      ),
                    ),
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