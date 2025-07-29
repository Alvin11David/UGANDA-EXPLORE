import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uganda_explore/screens/places/street_view_page.dart';

// Screen for listing available virtual tours
class VirtualToursListScreen extends StatefulWidget {
  const VirtualToursListScreen({super.key});

  @override
  State<VirtualToursListScreen> createState() => _VirtualToursListScreenState();
}

class _VirtualToursListScreenState extends State<VirtualToursListScreen> {
  bool isGrid = true; // Toggle between grid and list view

  // Fetch virtual tours from Firestore where streetViewLat exists
  Stream<List<Map<String, dynamic>>> _fetchVirtualTours() {
    return FirebaseFirestore.instance
        .collection('tourismsites')
        .where('streetViewLat', isGreaterThan: 0)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suggested Virtual Tours'),
        actions: [
          // Toggle button for grid/list view
          IconButton(
            icon: Icon(isGrid ? Icons.view_list : Icons.grid_view),
            tooltip: isGrid ? 'Switch to List View' : 'Switch to Grid View',
            onPressed: () => setState(() => isGrid = !isGrid),
          ),
        ],
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      // StreamBuilder listens for updates from Firestore
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _fetchVirtualTours(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            // Show loading indicator while fetching data
            return const Center(child: CircularProgressIndicator());
          }
          final tours = snapshot.data!;
          if (tours.isEmpty) {
            // Show message if no tours are available
            return const Center(
              child: Text(
                'No virtual tours available.',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            );
          }
          // Display tours in grid or list view
          return Padding(
            padding: const EdgeInsets.all(12),
            child: isGrid
                ? GridView.builder(
                    itemCount: tours.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.78,
                        ),
                    itemBuilder: (context, i) =>
                        _VirtualTourCard(site: tours[i]),
                  )
                : ListView.separated(
                    itemCount: tours.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, i) =>
                        _VirtualTourCard(site: tours[i]),
                  ),
          );
        },
      ),
    );
  }
}

// Card widget for each virtual tour
class _VirtualTourCard extends StatelessWidget {
  final Map<String, dynamic> site;
  const _VirtualTourCard({required this.site});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Navigate to StreetViewPage when tapped
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
          borderRadius: BorderRadius.circular(16), // Card corners
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 7,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tour image or fallback icon
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child:
                  site['images'] != null &&
                      site['images'] is List &&
                      (site['images'] as List).isNotEmpty
                  ? Image.network(
                      site['images'][0],
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        height: 90,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                          size: 32,
                        ),
                      ),
                    )
                  : Container(
                      height: 90,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.broken_image,
                        color: Colors.grey,
                        size: 32,
                      ),
                    ),
            ),
            // Tour details
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tour name
                  Text(
                    site['name'] ?? '',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF1E3A8A),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  // Location row
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Color(0xFF3B82F6),
                        size: 14,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          site['location'] ?? '',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Tags row (Virtual Tour, Category)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Virtual Tour tag
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.threesixty,
                                color: Color(0xFF3B82F6),
                                size: 13,
                              ),
                              const SizedBox(width: 2),
                              const Text(
                                'Virtual Tour',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF3B82F6),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 5),
                        // Category tag if available
                        if (site['category'] != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1FF813).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              site['category'],
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF1E3A8A),
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}






























































































































































































































