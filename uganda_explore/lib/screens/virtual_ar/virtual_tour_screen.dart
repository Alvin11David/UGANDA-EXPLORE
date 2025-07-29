import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Screen for showing a 360° panorama virtual tour of a place
class VirtualTourScreen extends StatefulWidget {
  final String placeName;
  const VirtualTourScreen({super.key, required this.placeName});

  @override
  State<VirtualTourScreen> createState() => _VirtualTourScreenState();
}

class _VirtualTourScreenState extends State<VirtualTourScreen> {
  String? panoramaUrl; // URL of the panorama image
  bool loading = true; // Loading state
  String? error; // Error message

  @override
  void initState() {
    super.initState();
    fetchPanoramaUrl(); // Fetch panorama image when screen loads
  }

  // Fetch panorama image URL from Firestore for the given place
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
          ? const Center(child: CircularProgressIndicator()) // Show loader while fetching
          : error != null
              ? Center(
                  child: Text(error!, style: const TextStyle(color: Colors.red)),
                )
              : panoramaUrl == null
                  ? const Center(child: Text('No panorama image'))
                  : _AutoScrollingImage(imageUrl: panoramaUrl!), // Show panorama image
    );
  }
}

// Widget for auto-scrolling panorama image (simulates 360° view)
class _AutoScrollingImage extends StatefulWidget {
  final String imageUrl;
  const _AutoScrollingImage({required this.imageUrl});

  @override
  State<_AutoScrollingImage> createState() => _AutoScrollingImageState();
}

class _AutoScrollingImageState extends State<_AutoScrollingImage>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController; // Controls horizontal scroll
  late final AnimationController _animationController; // Controls auto-scroll animation
  bool _isAutoScrolling = true; // Whether auto-scroll is active

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20), // Duration for full scroll
    );

    // Start auto-scroll after layout is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  // Start auto-scrolling the panorama image horizontally
  void _startAutoScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    _animationController.repeat(reverse: true);
    _animationController.addListener(() {
      if (_scrollController.hasClients && _isAutoScrolling) {
        final value = _animationController.value;
        _scrollController.jumpTo(value * maxScroll);
      }
    });
  }

  // Scroll left manually
  void _scrollLeft() {
    setState(() => _isAutoScrolling = false);
    if (_scrollController.hasClients) {
      final newOffset = (_scrollController.offset - 100).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );
      _scrollController.animateTo(
        newOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // Scroll right manually
  void _scrollRight() {
    setState(() => _isAutoScrolling = false);
    if (_scrollController.hasClients) {
      final newOffset = (_scrollController.offset + 100).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );
      _scrollController.animateTo(
        newOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Panorama image with horizontal scroll
            GestureDetector(
              onHorizontalDragStart: (_) {
                setState(() => _isAutoScrolling = false); // Stop auto-scroll on user drag
              },
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: constraints.maxWidth * 2, // Make image wider for scrolling
                  height: constraints.maxHeight,
                  child: Image.network(
                    widget.imageUrl,
                    fit: BoxFit.cover,
                    width: constraints.maxWidth * 2,
                    height: constraints.maxHeight,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              ),
            ),
            // Left scroll button
            Positioned(
              left: 16,
              top: constraints.maxHeight / 2 - 24,
              child: FloatingActionButton(
                heroTag: 'left',
                mini: true,
                backgroundColor: Colors.black54,
                onPressed: _scrollLeft,
                child: const Icon(
                  Icons.arrow_left,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
            // Right scroll button
            Positioned(
              right: 16,
              top: constraints.maxHeight / 2 - 24,
              child: FloatingActionButton(
                heroTag: 'right',
                mini: true,
                backgroundColor: Colors.black54,
                onPressed: _scrollRight,
                child: const Icon(
                  Icons.arrow_right,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}


































































































































































































































































