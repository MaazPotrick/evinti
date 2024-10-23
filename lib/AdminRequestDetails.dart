import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore to fetch event details

class AdminRequestDetails extends StatelessWidget {
  final String eventId;  // Event ID passed from AdminVenueRequests

  const AdminRequestDetails({Key? key, required this.eventId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  // Back Button
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context); // Go back to AdminVenueRequests
                        },
                        icon: Image.asset('assets/images/back2.png'),
                        iconSize: 40,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Page Title
                  const Text(
                    'Venue Request Details',
                    style: TextStyle(
                      fontFamily: 'FredokaOne',
                      fontSize: 36,
                      color: Color(0xFF801e15),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Fetch event details dynamically
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('events').doc(eventId).get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator(); // Show loading spinner while data is loading
                      }
                      if (!snapshot.hasData || snapshot.hasError) {
                        return const Text('Error loading event details');
                      }

                      final eventData = snapshot.data!.data() as Map<String, dynamic>;
                      final eventName = eventData['eventName'] ?? 'Unnamed Event';
                      final venue = eventData['venue'] ?? 'Unknown Venue';
                      final startTime = eventData['startTime'] ?? 'N/A';
                      final endTime = eventData['endTime'] ?? 'N/A';

                      return Column(
                        children: [
                          // Event Details
                          Text(
                            'Event: $eventName\nVenue: $venue\nTime: $startTime - $endTime',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'FredokaOne',
                              fontSize: 16,
                              color: Color(0xFF801e15),
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Approve and Reject Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF56100A),
                                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () async {
                                  await _approveVenue(context);
                                },
                                child: const Text(
                                  'Approve',
                                  style: TextStyle(
                                    fontFamily: 'FredokaOne',
                                    fontSize: 18,
                                    color: Color(0xFFe8c9ab),
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFab2d22),
                                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () async {
                                  await _rejectVenue(context);
                                },
                                child: const Text(
                                  'Reject',
                                  style: TextStyle(
                                    fontFamily: 'FredokaOne',
                                    fontSize: 18,
                                    color: Color(0xFFe8c9ab),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
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

  // Approve venue request
  Future<void> _approveVenue(BuildContext context) async {
    try {
      // Update Firestore to set isVenueApproved to true
      await FirebaseFirestore.instance.collection('events').doc(eventId).update({
        'isVenueApproved': true,
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Venue approved successfully!')),
      );

      // Navigate back to previous screen
      Navigator.pop(context); // Return to AdminVenueRequests page
    } catch (e) {
      // Handle errors if approval fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to approve venue: $e')),
      );
    }
  }

  // Reject venue request (currently just deleting the event)
  Future<void> _rejectVenue(BuildContext context) async {
    try {
      // Here, rejection can either mean deletion or another action.
      // For now, we'll delete the event if rejected (this can be changed).
      await FirebaseFirestore.instance.collection('events').doc(eventId).delete();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Venue request rejected and event deleted.')),
      );

      // Navigate back to previous screen
      Navigator.pop(context); // Return to AdminVenueRequests page
    } catch (e) {
      // Handle errors if rejection fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reject venue: $e')),
      );
    }
  }
}