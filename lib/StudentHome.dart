import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore package
import 'package:intl/intl.dart'; // Import the intl package for DateFormat
import 'StudentEventDetails.dart'; // Import the Event Details page
import 'StudentProfile.dart';
import 'StudentSearch.dart';
import 'package:firebase_auth/firebase_auth.dart'; // To get the current user

class StudentHome extends StatefulWidget {
  const StudentHome({Key? key}) : super(key: key);

  @override
  _StudentHomeState createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  List<String> preferredTags = []; // List to hold the student's preferred tags

  @override
  void initState() {
    super.initState();
    _fetchPreferredTags(); // Fetch the student's preferred tags
  }

  // Fetch the student's preferred tags from Firestore
  Future<void> _fetchPreferredTags() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final preferredTagsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('preferredTags')
          .get();
      setState(() {
        preferredTags = preferredTagsSnapshot.docs
            .map((doc) => doc['tagName'] as String)
            .toList();
        print("Preferred Tags: $preferredTags"); // Debug: Log the preferred tags
      });
    }
  }

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
          Column(
            children: [
              const SizedBox(height: 30),
              // Top bar with logo and icons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: IconButton(
                        icon: Image.asset('assets/images/setting.png'),
                        onPressed: () {},
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Image.asset(
                          'assets/images/Logo.png',
                          height: 100, // Keep logo bigger
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: IconButton(
                        icon: Image.asset('assets/images/more.png'),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Section title "Events you may like"
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Events you may like",
                  style: TextStyle(
                    fontFamily: 'FredokaOne',
                    fontSize: 18,
                    color: Color(0xFFe8c9ab),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Fetch and display events that match the student's preferred tags
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('events')
                    .where('isVenueApproved', isEqualTo: true) // Show only approved events
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading events.'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final events = snapshot.data?.docs ?? [];
                  // Filter events to show only those matching the student's preferred tags
                  final filteredEvents = events.where((event) {
                    final eventData = event.data() as Map<String, dynamic>;
                    final eventTags = List<String>.from(eventData['tags'] ?? []);

                    // Convert tags to lowercase for case-insensitive comparison
                    final eventTagsLowerCase = eventTags.map((tag) => tag.toLowerCase().trim()).toList();
                    final preferredTagsLowerCase = preferredTags.map((tag) => tag.toLowerCase().trim()).toList();

                    // Debug: Log the event tags and check if they match preferred tags
                    print("Event: ${eventData['eventName']}, Tags: $eventTags");
                    bool match = eventTagsLowerCase.any((tag) => preferredTagsLowerCase.contains(tag));
                    print("Event matches preferred tags: $match");
                    return match;
                  }).toList();

                  if (filteredEvents.isEmpty) {
                    return const Center(child: Text('No events matching your interests are available.'));
                  }

                  return CarouselSlider(
                    options: CarouselOptions(
                      height: 250, // Increased height for a longer card
                      enlargeCenterPage: true,
                      autoPlay: false,
                      aspectRatio: 16 / 9,
                      enableInfiniteScroll: true,
                      viewportFraction: 0.7, // Adjust viewport fraction if needed
                    ),
                    items: filteredEvents.map((event) {
                      // Extract event details from Firestore document
                      final eventData = event.data() as Map<String, dynamic>;
                      final eventId = event.id;
                      final eventDate = (eventData['eventDate'] as Timestamp).toDate();

                      return GestureDetector(
                        onTap: () {
                          // Navigate to StudentEventDetails with event data
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StudentEventDetails(
                                eventName: eventData['eventName'] ?? 'Unknown Event',
                                eventVenue: eventData['venue'] ?? 'Unknown Venue',
                                eventDescription: eventData['description'] ?? 'No description available.',
                                startTime: eventData['startTime'] ?? 'Not available',
                                endTime: eventData['endTime'] ?? 'Not available',
                                eventId: eventId,
                                eventDate: DateFormat('yyyy-MM-dd').format(eventDate), // Pass formatted date
                              ),
                            ),
                          );
                        },
                        child: _buildEventCard(
                          eventData['eventName'] ?? 'Unknown Event',
                          eventData['venue'] ?? 'Unknown Venue',
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Section title "Latest events"
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Latest events",
                  style: TextStyle(
                    fontFamily: 'FredokaOne',
                    fontSize: 18,
                    color: Color(0xFFe8c9ab),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Fetch and display latest approved events sorted by eventDate
              Padding(
                padding: const EdgeInsets.only(bottom: 20), // Adding bottom padding to improve spacing
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('events')
                      .where('isVenueApproved', isEqualTo: true) // Show only approved events
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(child: Text('Error loading events.'));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Fetch events from Firestore
                    final events = snapshot.data?.docs ?? [];

                    // Sort events by startTime (most recent first)
                    final sortedEvents = events
                        .map((event) => event.data() as Map<String, dynamic>)
                        .where((eventData) => eventData['eventDate'] != null) // Ensure there's an eventDate
                        .toList();

                    sortedEvents.sort((a, b) {
                      // Convert eventDate to DateTime, handling Timestamp
                      DateTime aDate = (a['eventDate'] as Timestamp).toDate();
                      DateTime bDate = (b['eventDate'] as Timestamp).toDate();
                      return bDate.compareTo(aDate); // Most recent first
                    });

                    if (sortedEvents.isEmpty) {
                      return const Center(child: Text('No latest approved events available.'));
                    }

                    return CarouselSlider(
                      options: CarouselOptions(
                        height: 250, // Increased height for a longer card
                        enlargeCenterPage: true,
                        autoPlay: false,
                        aspectRatio: 16 / 9,
                        enableInfiniteScroll: true,
                        viewportFraction: 0.7, // Adjust viewport fraction if needed
                      ),
                      items: sortedEvents.map((eventData) {
                        final eventId = events.first.id;
                        final eventDate = (eventData['eventDate'] as Timestamp).toDate();

                        return GestureDetector(
                          onTap: () {
                            // Navigate to StudentEventDetails with event data
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StudentEventDetails(
                                  eventName: eventData['eventName'] ?? 'Unnamed Event',
                                  eventVenue: eventData['venue'] ?? 'Unknown Venue',
                                  eventDescription: eventData['description'] ?? 'No description available.',
                                  startTime: eventData['startTime'] ?? 'Not available',
                                  endTime: eventData['endTime'] ?? 'Not available',
                                  eventId: eventId,
                                  eventDate: DateFormat('yyyy-MM-dd').format(eventDate), // Pass formatted date
                                ),
                              ),
                            );
                          },
                          child: _buildEventCard(
                            eventData['eventName'] ?? 'Unnamed Event',
                            eventData['venue'] ?? 'Unknown Venue',
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ],
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
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: IconButton(
                      icon: Image.asset('assets/images/home.png'),
                      onPressed: () {},
                    ),
                  ),
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

  // Method to build an event card dynamically
  Widget _buildEventCard(String eventName, String eventVenue) {
    return SizedBox(
      width: 300, // Explicit width to make the card wider
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 5,
        child: Column(
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
      ),
    );
  }

  // Helper function to convert startTime to DateTime
  DateTime _convertToDateTime(dynamic startTime) {
    if (startTime is Timestamp) {
      return startTime.toDate(); // Handle Timestamp case
    } else if (startTime is String) {
      // Trim the string to remove extra spaces and try parsing time in "h:mm a" format
      try {
        return DateFormat.jm().parseStrict(startTime.trim()); // Handles time like "4:30 PM"
      } catch (e) {
        print("Invalid time format: $startTime");
        return DateTime.now(); // Default fallback
      }
    } else {
      return DateTime.now(); // Fallback in case of unknown format
    }
  }
}