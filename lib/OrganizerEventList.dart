import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'OrganizerParticipantList.dart';

class OrganizerEventList extends StatefulWidget {
  const OrganizerEventList({Key? key}) : super(key: key);

  @override
  _OrganizerEventListState createState() => _OrganizerEventListState();
}

class _OrganizerEventListState extends State<OrganizerEventList> {
  String? _clubName; // Store the organizer's club name

  @override
  void initState() {
    super.initState();
    _fetchOrganizerDetails(); // Fetch organizer's club on page load
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'List of Participants',
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
                  // Display a list of events created by the organizer
                  Expanded(
                    child: _clubName == null
                        ? const Center(child: CircularProgressIndicator())
                        : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('events')
                          .where('clubId', isEqualTo: _clubName) // Filter by organizer's club
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Center(child: Text('Error loading events.'));
                        }
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final events = snapshot.data?.docs ?? [];
                        if (events.isEmpty) {
                          return const Center(child: Text('No events found.'));
                        }

                        return ListView.builder(
                          itemCount: events.length,
                          itemBuilder: (context, index) {
                            final event = events[index].data() as Map<String, dynamic>;
                            final eventId = events[index].id;
                            return _buildEventCard(context, event, eventId);
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

  // Event Card Builder
  Widget _buildEventCard(BuildContext context, Map<String, dynamic> event, String eventId) {
    return Card(
      color: const Color(0xFFe8c9ab),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFF470b06), width: 2),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        title: Text(
          event['eventName'] ?? 'Unnamed Event',
          style: const TextStyle(
            fontFamily: 'FredokaOne',
            fontSize: 18,
            color: Color(0xFF470b06),
          ),
        ),
        subtitle: Text(
          'Venue: ${event['venues'] ?? 'Unknown Venue'}\nDate: ${event['eventDate']?.toDate().toString().split(' ')[0] ?? 'Unknown Date'}',
          style: const TextStyle(
            fontFamily: 'FredokaOne',
            fontSize: 14,
            color: Color(0xFF470b06),
          ),
        ),
        onTap: () {
          // Navigate to the participants list for the selected event
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrganizerParticipantList(eventId: eventId, eventName: event['eventName']),
            ),
          );
        },
      ),
    );
  }
}