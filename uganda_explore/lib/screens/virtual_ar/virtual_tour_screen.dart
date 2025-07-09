<<<<<<< Updated upstream
=======
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
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
          : _AutoScrollingImage(imageUrl: panoramaUrl!),
    );
  }
}

class _AutoScrollingImage extends StatefulWidget {
  final String imageUrl;
  const _AutoScrollingImage({required this.imageUrl});

  @override
  State<_AutoScrollingImage> createState() => _AutoScrollingImageState();
}

class _AutoScrollingImageState extends State<_AutoScrollingImage>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _animationController;
  bool _isAutoScrolling = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

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
            GestureDetector(
              onHorizontalDragStart: (_) {
                setState(() => _isAutoScrolling = false);
              },
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: constraints.maxWidth * 2,
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
            // Left button
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
            // Right button
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
>>>>>>> Stashed changes
