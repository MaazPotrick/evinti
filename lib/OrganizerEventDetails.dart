import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore for database operations
import 'OrganizerEventEdit.dart'; // Import the OrganizerEventEdit page

class OrganizerEventDetails extends StatefulWidget {
  final Map<String, dynamic> event;
  final String eventDocId; // Pass the Firestore document ID

  const OrganizerEventDetails({
    Key? key,
    required this.event,
    required this.eventDocId, // Include document ID in constructor
  }) : super(key: key);

  @override
  _OrganizerEventDetailsState createState() => _OrganizerEventDetailsState();
}

class _OrganizerEventDetailsState extends State<OrganizerEventDetails> {
  late Map<String, dynamic> event; // Store the event details

  @override
  void initState() {
    super.initState();
    event = widget.event; // Initialize event with the passed data
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFe8c9ab),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          title: const Text(
            'Error',
            style: TextStyle(
              fontFamily: 'FredokaOne',
              fontSize: 20,
              color: Color(0xFF801e15),
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontFamily: 'FredokaOne',
              fontSize: 16,
              color: Color(0xFF801e15),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  fontFamily: 'FredokaOne',
                  fontSize: 16,
                  color: Color(0xFF801e15),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFe8c9ab),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          title: const Text(
            'Success',
            style: TextStyle(
              fontFamily: 'FredokaOne',
              fontSize: 20,
              color: Color(0xFF801e15),
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontFamily: 'FredokaOne',
              fontSize: 16,
              color: Color(0xFF801e15),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  fontFamily: 'FredokaOne',
                  fontSize: 16,
                  color: Color(0xFF801e15),
                ),
              ),
            ),
          ],
        );
      },
    );
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
                  // Top Bar with Back Button and Logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context); // Go back when tapped
                        },
                        icon: Image.asset('assets/images/back2.png'),
                        iconSize: 40,
                      ),
                      Image.asset(
                        'assets/images/Logo2.png',
                        height: 80,
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Event Name Title (Dynamically populated)
                  Text(
                    event['eventName'] ?? '[Event Name]',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'FredokaOne',
                      fontSize: 36,
                      color: Color(0xFF801e15),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Display event image if available, otherwise show placeholder
                  Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                      image: event['imageUrl'] != null
                          ? DecorationImage(
                        image: NetworkImage(event['imageUrl']),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                    child: event['imageUrl'] == null
                        ? const Icon(
                      Icons.image,
                      size: 100,
                      color: Colors.black,
                    )
                        : null,
                  ),
                  const SizedBox(height: 30),
                  // Event Details Text (Dynamically populated)
                  Text(
                    'Venue: ${_getVenuesText(event['venues'])}\n\n'
                        'Date: ${_formatDate(event['eventDate'])}\n\n'
                        'Time: ${event['startTime']} - ${event['endTime']}\n\n'
                        '${event['description']}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'FredokaOne',
                      fontSize: 16,
                      color: Color(0xFF801e15),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Edit and Delete Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Edit Button - Navigate to OrganizerEventEdit page
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF56100a),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          // Navigate to edit page and pass eventDocId to OrganizerEventEdit page
                          final updatedEvent = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  OrganizerEventEdit(
                                    event: event,
                                    eventDocId: widget
                                        .eventDocId, // Pass the document ID for editing
                                  ),
                            ),
                          );

                          if (updatedEvent != null) {
                            // Update the event data with the edited event
                            setState(() {
                              event = updatedEvent;
                            });
                          }
                        },
                        child: const Text(
                          'edit',
                          style: TextStyle(
                            fontFamily: 'FredokaOne',
                            fontSize: 18,
                            color: Color(0xFFe8c9ab),
                          ),
                        ),
                      ),
                      // Delete Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFab2d22),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          _confirmDeleteEvent(
                              context); // Call delete confirmation
                        },
                        child: const Text(
                          'delete',
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to display the list of venues
  String _getVenuesText(dynamic venues) {
    if (venues == null) {
      return 'No venue specified'; // No venue provided
    }
    if (venues is String) {
      return venues; // Single venue case
    } else if (venues is List && venues.isNotEmpty) {
      if (venues.length == 1) {
        return venues[0]; // If the list has only one venue, display that
      }
      return venues.join(', '); // Multiple venues case
    }
    return 'No venue specified'; // Default fallback
  }

  // Helper function to format the date
  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'No date specified';
    DateTime date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}'; // Format as DD/MM/YYYY
  }

  // Show confirmation dialog and delete event if confirmed
  void _confirmDeleteEvent(BuildContext context) {
    // Check if the event date is 3 days or more from today
    DateTime eventDate = (event['eventDate'] as Timestamp).toDate();
    DateTime currentDate = DateTime.now();

    if (eventDate.isBefore(currentDate.add(const Duration(days: 3)))) {
      // If the event is less than 3 days away, show a message box
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Cannot Delete Event'),
            content: const Text(
                'You cannot delete the event because it is less than 3 days away.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      // If the event is 3 days or more away, show the delete confirmation dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Deletion'),
            content: const Text('Are you sure you want to delete this event?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _deleteEvent(context);
                },
                child: const Text('Yes'),
              ),
            ],
          );
        },
      );
    }
  }

  // Delete the event from Firestore using document ID and navigate back to home
  Future<void> _deleteEvent(BuildContext context) async {
    try {
      // Use the passed Firestore document ID (eventDocId) to delete the event
      await FirebaseFirestore.instance.collection('events').doc(
          widget.eventDocId).delete();

      // Show a success message
      showSuccessDialog('Event deleted successfully!');


      // Navigate back to homepage and refresh
      Navigator.of(context).popUntil((route) =>
      route.isFirst); // Go back to homepage directly
    } catch (e) {
      // Show error message if something goes wrong
      showErrorDialog('Failed to delete the event. Please try again.');
    }
  }
}