import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final CollectionReference sites = FirebaseFirestore.instance.collection('tourismsites');

  void _showEditFieldDialog(String docId, String field, dynamic value) async {
    final controller = TextEditingController(text: value?.toString() ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.85),
        title: Text('Edit $field'),
        content: TextField(controller: controller, maxLines: field == 'description' ? 4 : 1),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null) {
      await sites.doc(docId).update({field: result});
    }
  }

  void _showAddFieldDialog(String docId) async {
    final fieldController = TextEditingController();
    final valueController = TextEditingController();
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.85),
        title: const Text('Add Field'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: fieldController, decoration: const InputDecoration(labelText: 'Field Name')),
            TextField(controller: valueController, decoration: const InputDecoration(labelText: 'Value')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, {
              'field': fieldController.text,
              'value': valueController.text,
            }),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (result != null && result['field']!.isNotEmpty) {
      await sites.doc(docId).update({result['field']!: result['value']});
    }
  }

  void _showAddDocumentDialog() async {
    final nameController = TextEditingController();
    final categoryController = TextEditingController();
    final locationController = TextEditingController();
    final descriptionController = TextEditingController();
    final openingController = TextEditingController();
    final closingController = TextEditingController();
    final entryFeeController = TextEditingController();
    final latitudeController = TextEditingController();
    final longitudeController = TextEditingController();
    final panoramaController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.85),
        title: const Text('Add New Site'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'Category')),
              TextField(controller: locationController, decoration: const InputDecoration(labelText: 'Location')),
              TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description')),
              TextField(controller: openingController, decoration: const InputDecoration(labelText: 'Opening Hours')),
              TextField(controller: closingController, decoration: const InputDecoration(labelText: 'Closing Hours')),
              TextField(controller: entryFeeController, decoration: const InputDecoration(labelText: 'Entry Fee')),
              TextField(controller: latitudeController, decoration: const InputDecoration(labelText: 'Latitude')),
              TextField(controller: longitudeController, decoration: const InputDecoration(labelText: 'Longitude')),
              TextField(controller: panoramaController, decoration: const InputDecoration(labelText: 'Panorama Image URL')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (result == true) {
      await sites.add({
        'name': nameController.text,
        'category': categoryController.text,
        'location': locationController.text,
        'description': descriptionController.text,
        'openingHours': openingController.text,
        'closingHours': closingController.text,
        'entryfee': entryFeeController.text,
        'latitude': double.tryParse(latitudeController.text) ?? 0.0,
        'longitude': double.tryParse(longitudeController.text) ?? 0.0,
        'panoramaImageUrl': panoramaController.text,
        'images': [],
        'videos': [],
      });
    }
  }

  void _deleteDocument(String docId) async {
    await sites.doc(docId).delete();
  }

  void _deleteField(String docId, String field) async {
    await sites.doc(docId).update({field: FieldValue.delete()});
  }

  @override
  Widget build(BuildContext context) {
    final glassColor = Colors.white.withOpacity(0.18);
    final glassBorder = Border.all(color: Colors.white.withOpacity(0.25), width: 1.5);

    return Scaffold(
      backgroundColor: const Color(0xFF101624),
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.white.withOpacity(0.10),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_rounded, color: Color(0xFF3B82F6)),
            tooltip: 'Add New Site',
            onPressed: _showAddDocumentDialog,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: sites.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'No sites found.',
                style: TextStyle(color: Colors.white70, fontSize: 20),
              ),
            );
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              return GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 600,
                  mainAxisSpacing: 24,
                  crossAxisSpacing: 24,
                  childAspectRatio: constraints.maxWidth < 800 ? 0.85 : 1.3,
                ),
                itemCount: docs.length,
                itemBuilder: (context, i) {
                  final data = docs[i].data() as Map<String, dynamic>;
                  final docId = docs[i].id;
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        decoration: BoxDecoration(
                          color: glassColor,
                          borderRadius: BorderRadius.circular(24),
                          border: glassBorder,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(18),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      data['name'] ?? 'No Name',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Color(0xFFEF4444)),
                                    tooltip: 'Delete Document',
                                    onPressed: () => _deleteDocument(docId),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add, color: Color(0xFF3B82F6)),
                                    tooltip: 'Add Field',
                                    onPressed: () => _showAddFieldDialog(docId),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (data['images'] != null && data['images'] is List && data['images'].isNotEmpty)
                                SizedBox(
                                  height: 120,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: data['images'].length,
                                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                                    itemBuilder: (context, idx) => ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        data['images'][idx],
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => Container(
                                          width: 120,
                                          height: 120,
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.broken_image, color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 10),
                              ...data.entries.where((e) => e.key != 'images').map((entry) {
                                return Card(
                                  color: Colors.white.withOpacity(0.12),
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  child: ListTile(
                                    title: Text(
                                      entry.key,
                                      style: const TextStyle(
                                        color: Color(0xFF3B82F6),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: entry.value is List
                                        ? Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              ...List.generate(
                                                (entry.value as List).length,
                                                (idx) => Padding(
                                                  padding: const EdgeInsets.only(bottom: 2.0),
                                                  child: Text(
                                                    '${entry.value[idx]}',
                                                    style: const TextStyle(color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        : Text(
                                            '${entry.value}',
                                            style: const TextStyle(color: Colors.white),
                                          ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Color(0xFF1E3A8A)),
                                          tooltip: 'Edit Field',
                                          onPressed: () => _showEditFieldDialog(docId, entry.key, entry.value),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
                                          tooltip: 'Delete Field',
                                          onPressed: () => _deleteField(docId, entry.key),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
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
        },
      ),
    );
  }
}