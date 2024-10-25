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
                      final venues = eventData['venues'] ?? [];

                      // Handle venues as a list of strings
                      final venueNames = venues is List
                          ? (venues as List).cast<String>().join(', ')
                          : 'Unknown Venue';

                      final startTime = eventData['startTime'] ?? 'N/A';
                      final endTime = eventData['endTime'] ?? 'N/A';

                      return Column(
                        children: [
                          // Event Details
                          Text(
                            'Event: $eventName\nVenues: $venueNames\nTime: $startTime - $endTime',
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
                                  await _showRejectionDialog(context);
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

  // Show rejection dialog to get reason from admin
  Future<void> _showRejectionDialog(BuildContext context) async {
    final TextEditingController _reasonController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Reject Venue Request',
            style: TextStyle(
              fontFamily: 'FredokaOne',
              fontSize: 18,
              color: Color(0xFF801e15),
            ),
          ),
          content: TextField(
            controller: _reasonController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Enter reason for rejection',
              filled: true,
              fillColor: const Color(0xFFe8c9ab),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFF801e15),
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFF801e15),
                  width: 2,
                ),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF801e15),
                  fontFamily: 'FredokaOne',
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              child: const Text(
                'Submit',
                style: TextStyle(
                  color: Color(0xFF801e15),
                  fontFamily: 'FredokaOne',
                ),
              ),
              onPressed: () async {
                final reason = _reasonController.text.trim();
                if (reason.isNotEmpty) {
                  await _rejectVenue(context, reason); // Reject with reason
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please provide a reason for rejection.')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Reject venue request with a reason
  Future<void> _rejectVenue(BuildContext context, String reason) async {
    try {
      // Update Firestore to mark as rejected and save the reason
      await FirebaseFirestore.instance.collection('events').doc(eventId).update({
        'isVenueApproved': false,
        'rejectionReason': reason,
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Venue request rejected.')),
      );

      // Navigate back to previous screen
      Navigator.pop(context); // Close the dialog
      Navigator.pop(context); // Return to AdminVenueRequests page
    } catch (e) {
      // Handle errors if rejection fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reject venue: $e')),
      );
    }
  }
}