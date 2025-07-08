import 'package:flutter/material.dart';
import 'package:panorama/panorama.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VirtualTourScreen extends StatefulWidget {
  final String placeName;
  const VirtualTourScreen({super.key, required this.placeName});

  @override
  State<VirtualTourScreen> createState() => _VirtualTourScreenState();
}

class _VirtualTourScreenState extends State<VirtualTourScreen> {
  String? panoramaUrl;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchPanoramaUrl();
  }

  Future<void> fetchPanoramaUrl() async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('tourismsites')
          .where('name', isEqualTo: widget.placeName.trim())
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        setState(() {
          panoramaUrl = query.docs.first['panoramaImageUrl'] as String?;
          loading = false;
        });
      } else {
        setState(() {
          error = 'No panorama found for this place.';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Failed to load panorama: $e';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.placeName} 360° Tour')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(
              child: Text(error!, style: const TextStyle(color: Colors.red)),
            )
          : panoramaUrl == null
          ? const Center(child: Text('No panorama image'))
          : Stack(
              children: [
                Panorama(animSpeed: 1.0, child: Image.network(panoramaUrl!)),
                // Arrow controls (show SnackBar hints)
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_left, size: 40),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Swipe to look left!'),
                            ),
                          );
                        },
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_drop_up, size: 40),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Swipe up to look up!'),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 40),
                          IconButton(
                            icon: const Icon(Icons.arrow_drop_down, size: 40),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Swipe down to look down!'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_right, size: 40),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Swipe to look right!'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
