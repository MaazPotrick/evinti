import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminVenueManagement extends StatefulWidget {
  const AdminVenueManagement({Key? key}) : super(key: key);

  @override
  _AdminVenueManagementState createState() => _AdminVenueManagementState();
}

class _AdminVenueManagementState extends State<AdminVenueManagement> {
  final TextEditingController _venueController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Venues',
          style: TextStyle(
            fontFamily: 'FredokaOne',
            fontSize: 24,
          ),
        ),
        backgroundColor: const Color(0xFF801e15),
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg4.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Text field to add a new venue
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _venueController,
                          decoration: InputDecoration(
                            labelText: 'Add New Venue',
                            labelStyle: const TextStyle(
                              fontFamily: 'FredokaOne',
                              fontSize: 16,
                              color: Color(0xFF801e15),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF801e15),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _addVenue, // Add venue to the database
                        child: const Text(
                          'Add',
                          style: TextStyle(
                            fontFamily: 'FredokaOne',
                            fontSize: 16,
                            color: Color(0xFFe8c9ab),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Available Venues',
                    style: TextStyle(
                      fontFamily: 'FredokaOne',
                      fontSize: 20,
                      color: Color(0xFF801e15),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // List of existing venues
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('venues')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Center(child: Text('Error loading venues.'));
                        }
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final venues = snapshot.data?.docs ?? [];
                        if (venues.isEmpty) {
                          return const Center(child: Text('No venues available.'));
                        }

                        return ListView.builder(
                          itemCount: venues.length,
                          itemBuilder: (context, index) {
                            final venue = venues[index];
                            final venueName = venue['name'] ?? 'Unnamed Venue';

                            return ListTile(
                              title: Text(
                                venueName,
                                style: const TextStyle(
                                  fontFamily: 'FredokaOne',
                                  fontSize: 18,
                                  color: Color(0xFF470b06),
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _editVenueDialog(venue.id, venueName), // Edit venue name
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteVenue(venue.id), // Delete venue from the database
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to add a venue to Firestore
  Future<void> _addVenue() async {
    final venueName = _venueController.text.trim();

    if (venueName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a venue name.')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('venues').add({
        'name': venueName,
      });

      _venueController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Venue added successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add venue: $e')),
      );
    }
  }

  // Function to delete a venue from Firestore
  Future<void> _deleteVenue(String venueId) async {
    try {
      await FirebaseFirestore.instance.collection('venues').doc(venueId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Venue deleted successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete venue: $e')),
      );
    }
  }

  // Function to show edit venue dialog
  void _editVenueDialog(String venueId, String currentName) {
    final TextEditingController editController = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Venue Name'),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(
              labelText: 'Venue Name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _updateVenueName(venueId, editController.text.trim());
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Function to update the venue name in Firestore
  Future<void> _updateVenueName(String venueId, String newName) async {
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Venue name cannot be empty.')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('venues').doc(venueId).update({
        'name': newName,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Venue name updated successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update venue: $e')),
      );
    }
  }
}