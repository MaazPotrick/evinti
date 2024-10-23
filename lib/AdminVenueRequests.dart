import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'AdminRequestDetails.dart'; // Correct reference to AdminRequestDetails

class AdminVenueRequests extends StatelessWidget {
  const AdminVenueRequests({Key? key}) : super(key: key);

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
                          Navigator.pop(context); // Go back to AdminHomePage
                        },
                        icon: Image.asset('assets/images/back2.png'),
                        iconSize: 40,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Page Title
                  const Text(
                    'Venue Requests',
                    style: TextStyle(
                      fontFamily: 'FredokaOne',
                      fontSize: 36,
                      color: Color(0xFF801e15),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Fetch venue requests dynamically from Firestore
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('events')
                          .where('isVenueApproved', isEqualTo: false) // Query pending approvals
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Center(child: Text('Error loading venue requests.'));
                        }

                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final events = snapshot.data?.docs ?? [];

                        if (events.isEmpty) {
                          return const Center(child: Text('No pending venue requests.'));
                        }

                        return ListView.builder(
                          itemCount: events.length,
                          itemBuilder: (context, index) {
                            final event = events[index].data() as Map<String, dynamic>;
                            final eventId = events[index].id; // Get document ID
                            final eventName = event['eventName'] ?? 'Unnamed Event';
                            final venueName = event['venue'] ?? 'Unknown Venue';

                            return _buildRequestCard(context, eventName, venueName, eventId);
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

  // Build a request card dynamically
  Widget _buildRequestCard(BuildContext context, String eventName, String venueName, String eventId) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminRequestDetails(eventId: eventId), // Pass eventId to details page
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFe8c9ab),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF801e15), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              eventName,
              style: const TextStyle(
                fontFamily: 'FredokaOne',
                fontSize: 18,
                color: Color(0xFF801e15),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              venueName,
              style: const TextStyle(
                fontFamily: 'FredokaOne',
                fontSize: 16,
                color: Color(0xFF470b06),
              ),
            ),
          ],
        ),
      ),
    );
  }
}