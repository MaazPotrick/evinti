import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:intl/intl.dart'; // Import intl for DateFormat
import 'StudentHome.dart';
import 'StudentProfile.dart';
import 'StudentEventDetails.dart'; // Import StudentEventDetails

class StudentSearch extends StatefulWidget {
  const StudentSearch({Key? key}) : super(key: key);

  @override
  _StudentSearchState createState() => _StudentSearchState();
}

class _StudentSearchState extends State<StudentSearch> {
  String searchQuery = "";  // Holds the user's search input

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
          // Scrollable content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                // Top bar with settings button and centered logo
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
                      const SizedBox(
                        width: 60,
                        height: 60,
                      ), // Placeholder to balance the layout
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                // Greeting Text
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Hi [User Name],\nwhich event are you looking for?',
                    style: TextStyle(
                      fontFamily: 'FredokaOne',
                      fontSize: 29,
                      color: Color(0xFFe8c9ab),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Search Field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFe8c9ab), width: 2),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/search.png',
                          height: 24,
                          width: 24,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            onChanged: (value) {
                              // Update search query
                              setState(() {
                                searchQuery = value.toLowerCase();
                              });
                            },
                            decoration: const InputDecoration(
                              hintText: 'Search',
                              hintStyle: TextStyle(
                                fontFamily: 'FredokaOne',
                                fontSize: 16,
                                color: Color(0xFFe8c9ab),
                              ),
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(
                              fontFamily: 'FredokaOne',
                              fontSize: 16,
                              color: Color(0xFFe8c9ab),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Search results - StreamBuilder with Firestore query
                SizedBox(
                  height: 500, // Set a height for the ListView
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('events')
                        .where('isVenueApproved', isEqualTo: true) // Only approved events
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(child: Text('Error loading events.'));
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final events = snapshot.data?.docs ?? [];

                      // Filter the events based on the search query
                      final filteredEvents = searchQuery.isEmpty
                          ? [] // No events should show up if the search query is empty
                          : events.where((event) {
                        final eventData = event.data() as Map<String, dynamic>;
                        final eventName = eventData['eventName']?.toString().toLowerCase() ?? '';
                        final eventDescription = eventData['description']?.toString().toLowerCase() ?? '';
                        final venues = List<String>.from(eventData['venues'] ?? []);
                        final eventVenues = venues.join(', ').toLowerCase();

                        return eventName.contains(searchQuery) ||
                            eventDescription.contains(searchQuery) ||
                            eventVenues.contains(searchQuery);
                      }).toList();

                      if (filteredEvents.isEmpty && searchQuery.isNotEmpty) {
                        return const Center(child: Text('No matching events found.'));
                      }

                      // Display matching events with better design
                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80), // Add padding at the bottom
                        itemCount: filteredEvents.length,
                        itemBuilder: (context, index) {
                          final eventData = filteredEvents[index].data() as Map<String, dynamic>;
                          final eventName = eventData['eventName'] ?? 'Unnamed Event';
                          final venues = List<String>.from(eventData['venues'] ?? []);
                          final eventVenue = venues.isNotEmpty ? venues.join(', ') : 'Unknown Venue';
                          final eventDescription = eventData['description'] ?? 'No description';
                          final eventId = filteredEvents[index].id;

                          // Format eventDate
                          final eventDateTimestamp = eventData['eventDate'];
                          final formattedEventDate = eventDateTimestamp != null
                              ? DateFormat('yyyy-MM-dd').format((eventDateTimestamp as Timestamp).toDate())
                              : 'No Event Date';

                          return GestureDetector(
                            onTap: () {
                              // Navigate to StudentEventDetails and pass event details
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StudentEventDetails(
                                    eventName: eventName,
                                    eventVenue: eventVenue,
                                    eventDescription: eventDescription,
                                    startTime: eventData['startTime'] ?? 'No Start Time',  // Pass start time
                                    endTime: eventData['endTime'] ?? 'No End Time',
                                    eventId: eventId,
                                    eventDate: formattedEventDate, // Pass formatted date
                                    imageUrl: eventData['imageUrl'],
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF801e15),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 5,
                                      offset: Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      eventName,
                                      style: const TextStyle(
                                        fontFamily: 'FredokaOne',
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      eventVenue,
                                      style: const TextStyle(
                                        fontFamily: 'FredokaOne',
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      eventDescription,
                                      style: const TextStyle(
                                        fontFamily: 'FredokaOne',
                                        fontSize: 14,
                                        color: Colors.white60,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
                      onPressed: () {},
                    ),
                  ),
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
}