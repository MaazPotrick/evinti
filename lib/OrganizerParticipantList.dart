import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrganizerParticipantList extends StatelessWidget {
  final String eventId;
  final String? eventName;

  const OrganizerParticipantList({Key? key, required this.eventId, this.eventName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          eventName ?? 'Participants',
          style: const TextStyle(
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
                  // Display a list of participants registered for the event
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('events')
                          .doc(eventId)
                          .collection('participants') // Assuming participants are stored as a subcollection
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Center(child: Text('Error loading participants.'));
                        }
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final participants = snapshot.data?.docs ?? [];
                        if (participants.isEmpty) {
                          return const Center(child: Text('No participants registered.'));
                        }

                        return ListView.builder(
                          itemCount: participants.length,
                          itemBuilder: (context, index) {
                            final participant = participants[index].data() as Map<String, dynamic>;
                            return ListTile(
                              title: Text(
                                participant['name'] ?? 'Unnamed Participant',
                                style: const TextStyle(
                                  fontFamily: 'FredokaOne',
                                  fontSize: 18,
                                  color: Color(0xFF470b06),
                                ),
                              ),
                              subtitle: Text(
                                'Email: ${participant['email'] ?? 'No email available'}',
                                style: const TextStyle(
                                  fontFamily: 'FredokaOne',
                                  fontSize: 14,
                                  color: Color(0xFF470b06),
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
          ),
        ],
      ),
    );
  }
}