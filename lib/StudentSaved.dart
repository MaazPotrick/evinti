import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore to fetch saved events
import 'StudentSearch.dart';
import 'StudentHome.dart';
import 'StudentProfile.dart';

class StudentSaved extends StatelessWidget {
  final String userId; // Accept userId as a parameter

  const StudentSaved({Key? key, required this.userId}) : super(key: key);

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
                          height: 100, // Increase the size of the logo
                        ),
                      ),
                    ),
                    const SizedBox(width: 30), // Empty space to balance the row
                  ],
                ),
                const SizedBox(height: 20),
                // Title "Saved" with heart icon
                Row(
                  children: [
                    const Text(
                      'Saved ',
                      style: TextStyle(
                        fontFamily: 'FredokaOne',
                        fontSize: 36,
                        color: Color(0xFFe8c9ab),
                      ),
                    ),
                    Image.asset(
                      'assets/images/heart.png',
                      height: 36,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Display saved events from Firestore
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId) // Filter by the logged-in user's ID
                        .collection('likedEvents') // Retrieve the liked events collection
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(child: Text('Error loading saved events.'));
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final likedEvents = snapshot.data?.docs ?? [];
                      if (likedEvents.isEmpty) {
                        return const Center(child: Text('No saved events found.'));
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: likedEvents.length,
                        itemBuilder: (context, index) {
                          final event = likedEvents[index];
                          final eventData = event.data() as Map<String, dynamic>;
                          return _buildEventCard(eventData['eventName'], eventData['eventVenue']);
                        },
                      );
                    },
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

  // Method to build an event card
  Widget _buildEventCard(String eventName, String eventVenue) {
    return Card(
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
              const Icon(Icons.image, size: 60, color: Colors.grey), // Placeholder for event image
              const SizedBox(height: 10),
              Text(
                eventName,
                style: const TextStyle(
                  fontFamily: 'FredokaOne',
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              Text(
                eventVenue,
                style: const TextStyle(
                  fontFamily: 'FredokaOne',
                  fontSize: 14,
                  color: Colors.black45,
                ),
              ),
            ],
          ),
          // Red heart icon for saved events
          Positioned(
            top: 10,
            left: 10,
            child: Image.asset(
              'assets/images/redheart.png',
              height: 24,
              width: 24,
            ),
          ),
        ],
      ),
    );
  }
}