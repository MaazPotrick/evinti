import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'OrganizerEventDetails.dart'; // Import the event details page
import 'OrganizerEventCreate.dart';
import 'OrganizerManageEvent.dart'; // Import the Manage Events page
import 'login.dart'; // Import the login page

class OrganizerHomePage extends StatefulWidget {
  const OrganizerHomePage({Key? key}) : super(key: key);

  @override
  _OrganizerHomePageState createState() => _OrganizerHomePageState();
}

class _OrganizerHomePageState extends State<OrganizerHomePage> {
  String? _clubName; // Store the organizer's club name
  List<Map<String, dynamic>> _events = []; // Store the list of events

  @override
  void initState() {
    super.initState();
    _fetchOrganizerDetails(); // Fetch organizer's club and events on page load
  }

  // Fetch the organizer's details (club name) from Firestore
  Future<void> _fetchOrganizerDetails() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      // Fetch user data (including club name)
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      setState(() {
        _clubName = userDoc['clubName']; // Store club name
      });

      // Fetch events for this club
      _fetchClubEvents(userDoc['clubName']);
    }
  }

  // Fetch events for the logged-in organizer's club
  Future<void> _fetchClubEvents(String clubName) async {
    QuerySnapshot eventSnapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('clubId', isEqualTo: clubName) // Filter events by clubId (organizer's club)
        .get();

    setState(() {
      // Store the events as a list of maps
      _events = eventSnapshot.docs.map((doc) {
        Map<String, dynamic> eventData = doc.data() as Map<String, dynamic>;
        eventData['eventId'] = doc.id; // Store the event document ID (eventId)
        // Handle both single venue ('venue') and multiple venues ('Venues')
        if (eventData.containsKey('Venues')) {
          eventData['venue'] = eventData['Venues'].join(', '); // Combine multiple venues into a single string
        } else if (eventData.containsKey('venue')) {
          eventData['venue'] = eventData['venue']; // Keep the single venue
        } else {
          eventData['venue'] = 'No venue specified'; // Default in case venue data is missing
        }
        return eventData;
      }).toList();
      // Debugging: Print total number of events fetched
      print("Total events fetched: ${_events.length}");
    });
  }

  // Logout the user and navigate to the login screen
  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false, // This removes all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Container(
          color: const Color(0xFF56100A), // Dark red background color for the drawer
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50), // Space from the top
              // Back Arrow Icon
              IconButton(
                icon: Image.asset('assets/images/back.png'),
                iconSize: 40,
                onPressed: () {
                  Navigator.pop(context); // Close the drawer when back button is clicked
                },
              ),
              const SizedBox(height: 30),
              // Manage Events Button - Navigate to OrganizerManageEvent page
              _buildDrawerButton(context, 'Manage Events', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OrganizerManageEvent()),
                );
              }),
              const SizedBox(height: 20),
              // Create New Event Button - Navigate to OrganizerEventCreate page
              _buildDrawerButton(context, 'Create New Event', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OrganizerEventCreate()),
                );
              }),
              const SizedBox(height: 20),
              // Profile Button
              _buildDrawerButton(context, 'Profile'),
              const SizedBox(height: 20),
              // Logout Button
              _buildDrawerButton(context, 'Logout', () => _logout(context)),
            ],
          ),
        ),
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
                  // Top Bar with Logo, Settings, and Sidebar icons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Settings Icon (Top left)
                      Builder(
                        builder: (context) => SizedBox(
                          height: 50, // Explicit height control
                          width: 50,  // Explicit width control
                          child: GestureDetector(
                            onTap: () {
                              Scaffold.of(context).openDrawer(); // Open drawer when tapped
                            },
                            child: Image.asset('assets/images/more2.png'),
                          ),
                        ),
                      ),
                      // Logo (center)
                      Image.asset(
                        'assets/images/Logo2.png',
                        height: 90, // Increased height of the logo
                      ),
                      // Settings Icon (Top right) - Re-fetch events on tap
                      SizedBox(
                        height: 50,
                        width: 50,
                        child: GestureDetector(
                          onTap: () => _fetchClubEvents(_clubName!), // Refresh when tapped
                          child: Image.asset('assets/images/setting2.png'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Welcome Club Name Text
                  Text(
                    'Welcome\n${_clubName ?? ''}', // Display organizer's club name
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'FredokaOne',
                      fontSize: 36,
                      color: Color(0xFF801e15),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Event Under Club Name Text
                  Text(
                    'Events under ${_clubName ?? ''}', // Display organizer's club name
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'FredokaOne',
                      fontSize: 24,
                      color: Color(0xFF470b06),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Display events dynamically
                  Expanded(
                    child: ListView.builder(
                      itemCount: _events.length,
                      itemBuilder: (context, index) {
                        final event = _events[index];
                        return _buildEventButton(context, event);
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

  Widget _buildEventButton(BuildContext context, Map<String, dynamic> event) {
    return SizedBox(
      width: double.infinity, // Full width button
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          backgroundColor: const Color(0xFFe8c9ab),
          side: const BorderSide(color: Color(0xFF470b06), width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {
          // Navigate to OrganizerEventDetails page when an event is clicked
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrganizerEventDetails(
                event: event,            // Pass event data
                eventDocId: event['eventId'],  // Pass event ID
              ),
            ),
          );
        },
        child: Text(
          event['eventName'],
          style: const TextStyle(
            fontFamily: 'FredokaOne',
            fontSize: 18,
            color: Color(0xFF470b06),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerButton(BuildContext context, String text, [VoidCallback? onPressed]) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity, // Full width button
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 20),
            backgroundColor: const Color(0xFFe8c9ab),
            side: const BorderSide(color: Color(0xFF470b06), width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: onPressed, // Optional onPressed handler
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'FredokaOne',
              fontSize: 24,
              color: Color(0xFF56100A),
            ),
          ),
        ),
      ),
    );
  }
}