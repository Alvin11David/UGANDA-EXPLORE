import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uganda_explore/screens/places/street_view_page.dart';

class VirtualToursListScreen extends StatefulWidget {
  const VirtualToursListScreen({super.key});

  @override
  State<VirtualToursListScreen> createState() => _VirtualToursListScreenState();
}

class _VirtualToursListScreenState extends State<VirtualToursListScreen> {
  bool isGrid = true;

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
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _fetchVirtualTours(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final tours = snapshot.data!;
          if (tours.isEmpty) {
            return const Center(
              child: Text(
                'No virtual tours available.',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(12),
            child: isGrid
                ? GridView.builder(
                    itemCount: tours.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.78,
                    ),
                    itemBuilder: (context, i) => _VirtualTourCard(site: tours[i]),
                  )
                : ListView.separated(
                    itemCount: tours.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, i) => _VirtualTourCard(site: tours[i]),
                  ),
          );
        },
      ),
    );
  }
}

class _VirtualTourCard extends StatelessWidget {
  final Map<String, dynamic> site;
  const _VirtualTourCard({required this.site});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
          borderRadius: BorderRadius.circular(22),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              child: site['images'] != null &&
                      site['images'] is List &&
                      (site['images'] as List).isNotEmpty
                  ? Image.network(
                      site['images'][0],
                      height: 140,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        height: 140,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    )
                  : Container(
                      height: 140,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    site['name'] ?? '',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Color(0xFF1E3A8A),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Color(0xFF3B82F6), size: 18),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          site['location'] ?? '',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.threesixty, color: Color(0xFF3B82F6), size: 18),
                            const SizedBox(width: 4),
                            const Text(
                              'Virtual Tour',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF3B82F6),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (site['category'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1FF813).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            site['category'],
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF1E3A8A),
                              fontWeight: FontWeight.w500,
                            ),
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
    );
  }
}