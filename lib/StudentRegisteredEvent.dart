import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // To fetch registered events from Firestore
import 'StudentSearch.dart';
import 'StudentHome.dart';
import 'StudentProfile.dart';
import 'StudentEventDetails.dart'; // Import Event Details page

class StudentRegisteredEvent extends StatelessWidget {
  final String userId; // Accept userId as a parameter

  const StudentRegisteredEvent({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg2.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar with back button and centered logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Image.asset(
                        'assets/images/back.png', // Use back.png image
                        height: 30,
                        width: 30,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Expanded(
                      child: Center(
                        child: Image.asset(
                          'assets/images/Logo.png',
                          height: 100, // Maintain the size of the logo
                        ),
                      ),
                    ),
                    const SizedBox(width: 30), // Empty space to balance the row
                  ],
                ),
                const SizedBox(height: 20),
                // Title "Events registered for"
                const Text(
                  'Events\nregistered for',
                  style: TextStyle(
                    fontFamily: 'FredokaOne',
                    fontSize: 36,
                    color: Color(0xFFe8c9ab),
                  ),
                ),
                const SizedBox(height: 10),
                // Grid of registered events from Firestore
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 80), // Add extra padding at the bottom
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(userId)
                          .collection('registeredEvents')
                          .snapshots(),
                      builder: (context, registeredSnapshot) {
                        if (registeredSnapshot.hasError) {
                          return const Center(child: Text('Error loading registered events.'));
                        }
                        if (registeredSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final registeredEvents = registeredSnapshot.data?.docs ?? [];
                        if (registeredEvents.isEmpty) {
                          return const Center(child: Text('No events registered.'));
                        }

                        // Fetch liked events to check for liked status
                        return FutureBuilder<QuerySnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .doc(userId)
                              .collection('likedEvents')
                              .get(),
                          builder: (context, likedSnapshot) {
                            if (likedSnapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            final likedEvents = likedSnapshot.data?.docs.map((doc) => doc.id).toSet() ?? {};

                            return GridView.builder(
                              padding: const EdgeInsets.all(8),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemCount: registeredEvents.length,
                              itemBuilder: (context, index) {
                                final event = registeredEvents[index];
                                final eventData = event.data() as Map<String, dynamic>;
                                final isLiked = likedEvents.contains(event.id);

                                return _buildEventCard(context, eventData, event.id, isLiked);
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bottom navigation bar
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: const Color(0xFF801e15),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Search Icon
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: IconButton(
                      icon: Image.asset('assets/images/search.png'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const StudentSearch()),
                        );
                      },
                    ),
                  ),
                  // Home Icon
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: IconButton(
                      icon: Image.asset('assets/images/home.png'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const StudentHome()),
                        );
                      },
                    ),
                  ),
                  // Profile Icon
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: IconButton(
                      icon: Image.asset('assets/images/profile.png'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const StudentProfile()),
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

  // Method to build an event card with image, navigation, and liked status
  Widget _buildEventCard(BuildContext context, Map<String, dynamic> eventData, String eventId, bool isLiked) {
    return GestureDetector(
      onTap: () {
        // Navigate to StudentEventDetails page with event data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StudentEventDetails(
              eventName: eventData['eventName'] ?? 'Unknown Event',
              eventVenue: eventData['eventVenue'] ?? 'Unknown Venue',
              eventDescription: eventData['description'] ?? 'No description available.',
              startTime: eventData['startTime'] ?? 'Not available',
              endTime: eventData['endTime'] ?? 'Not available',
              eventId: eventId,
              eventDate: eventData['eventDate'] ?? 'Not available',
              imageUrl: eventData['imageUrl'],
            ),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 5,
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                eventData['imageUrl'] != null
                    ? Image.network(
                  eventData['imageUrl'],
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
                    : const Icon(Icons.image, size: 60, color: Colors.grey), // Placeholder for event image
                const SizedBox(height: 10),
                Text(
                  eventData['eventName'] ?? 'Unnamed Event',
                  style: const TextStyle(
                    fontFamily: 'FredokaOne',
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                Text(
                  eventData['eventVenue'] ?? 'Unknown Venue',
                  style: const TextStyle(
                    fontFamily: 'FredokaOne',
                    fontSize: 14,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
            // Heart icon based on liked status
            Positioned(
              top: 10,
              left: 10,
              child: Image.asset(
                isLiked ? 'assets/images/redheart.png' : 'assets/images/heart.png',
                height: 24,
                width: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}