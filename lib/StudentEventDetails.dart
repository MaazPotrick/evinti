import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // To get the current logged-in user

class StudentEventDetails extends StatefulWidget {
  final String eventName;
  final String eventVenue;
  final String eventDescription;
  final String startTime;    // Accept startTime
  final String endTime;      // Accept endTime
  final String eventId;      // Add eventId to identify the event

  // Constructor to receive the event data
  const StudentEventDetails({
    Key? key,
    required this.eventName,
    required this.eventVenue,
    required this.eventDescription,
    required this.startTime,    // Initialize startTime
    required this.endTime,      // Initialize endTime
    required this.eventId,      // Initialize eventId
  }) : super(key: key);

  @override
  _StudentEventDetailsState createState() => _StudentEventDetailsState();
}

class _StudentEventDetailsState extends State<StudentEventDetails> {
  bool isLiked = false; // Track if the event is liked or not

  @override
  void initState() {
    super.initState();
    _checkIfLiked(); // Check if the event is already liked
  }

  // Function to check if the event is already liked
  Future<void> _checkIfLiked() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        DocumentSnapshot likedEvent = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('likedEvents')
            .doc(widget.eventId)
            .get();

        if (likedEvent.exists) {
          setState(() {
            isLiked = true;
          });
        }
      }
    } catch (e) {
      print('Error checking liked event: $e');
    }
  }

  // Function to like the event
  Future<void> _likeEvent() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        Map<String, dynamic> likedEventData = {
          'eventId': widget.eventId,
          'eventName': widget.eventName,
          'eventVenue': widget.eventVenue,
          'startTime': widget.startTime,
          'endTime': widget.endTime,
          'likedTime': Timestamp.now(),
        };

        // Save the liked event to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('likedEvents')
            .doc(widget.eventId)
            .set(likedEventData);

        setState(() {
          isLiked = true;
        });
      }
    } catch (e) {
      print('Error liking event: $e');
    }
  }

  // Function to unlike the event
  Future<void> _unlikeEvent() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // Remove the liked event from Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('likedEvents')
            .doc(widget.eventId)
            .delete();

        setState(() {
          isLiked = false;
        });
      }
    } catch (e) {
      print('Error unliking event: $e');
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
                        'assets/images/back.png',
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
                          height: 100,
                        ),
                      ),
                    ),
                    const SizedBox(width: 30), // Empty space to balance the row
                  ],
                ),
                const SizedBox(height: 20),
                // Event Name with heart icon
                Center(
                  child: Column(
                    children: [
                      Text(
                        widget.eventName,
                        style: const TextStyle(
                          fontFamily: 'FredokaOne',
                          fontSize: 24,
                          color: Color(0xFFe8c9ab),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Stack(
                        children: [
                          // Event Image Placeholder
                          Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.image,
                                size: 100,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          // Heart Icon
                          Positioned(
                            top: 10,
                            left: 10,
                            child: GestureDetector(
                              onTap: () {
                                if (isLiked) {
                                  _unlikeEvent();
                                } else {
                                  _likeEvent();
                                }
                              },
                              child: Image.asset(
                                isLiked
                                    ? 'assets/images/redheart.png'
                                    : 'assets/images/heart.png',
                                height: 24,
                                width: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Event Description
                Text(
                  widget.eventDescription,
                  style: const TextStyle(
                    fontFamily: 'FredokaOne',
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                // Venue Details
                Text(
                  'Venue - ${widget.eventVenue}',
                  style: const TextStyle(
                    fontFamily: 'FredokaOne',
                    fontSize: 12,
                    color: Color(0xFFe8c9ab),
                  ),
                ),
                // Start and End Time
                Text(
                  'Time - ${widget.startTime} - ${widget.endTime}',
                  style: const TextStyle(
                    fontFamily: 'FredokaOne',
                    fontSize: 12,
                    color: Color(0xFFe8c9ab),
                  ),
                ),
                const Spacer(),
                // Register Button
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF801e15),
                      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      _showConfirmationDialog(context);  // Call confirmation dialog
                    },
                    child: const Text(
                      'Register for Event',
                      style: TextStyle(
                        fontFamily: 'FredokaOne',
                        fontSize: 18,
                        color: Color(0xFFe8c9ab),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Show a confirmation dialog to register for the event
  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Registration'),
          content: const Text('Are you sure you want to register for this event?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();  // Close the dialog
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                await _registerForEvent(context);  // Register for the event first
                Navigator.of(context).pop();  // Close the dialog after successful registration
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  // Function to register the user for the event
  Future<void> _registerForEvent(BuildContext context) async {
    try {
      // Get the current user's ID from Firebase Authentication
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // Fetch the student's name from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        String studentName = userDoc['name'] ?? 'Anonymous'; // Use student's name if available, otherwise "Anonymous"

        // Create the data to save in the 'registeredEvents' collection of the user
        Map<String, dynamic> registeredEventData = {
          'eventId': widget.eventId,         // Store the event ID
          'eventName': widget.eventName,
          'eventVenue': widget.eventVenue,
          'startTime': widget.startTime,
          'endTime': widget.endTime,
          'registrationTime': Timestamp.now(), // Store the time when the registration happened
        };

        // Save the registered event to the user's document in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)  // Use the current user's ID
            .collection('registeredEvents')  // Store registered events as a subcollection
            .doc(widget.eventId)  // Use eventId as the document ID
            .set(registeredEventData);

        Map<String, dynamic> participantData = {
          'userId': currentUser.uid,
          'name': studentName, // Use the fetched name
          'email': currentUser.email ?? 'No email provided',
          'registrationTime': Timestamp.now(),
        };

        // Also save the participant's information in the 'participants' subcollection of the event
        await FirebaseFirestore.instance
            .collection('events')
            .doc(widget.eventId)
            .collection('participants')
            .doc(currentUser.uid) // Use userId as the document ID for the participant
            .set({
          'userId': currentUser.uid,
          'name': studentName, // Save the student's name
          'email': currentUser.email ?? 'No email provided',
          'registrationTime': Timestamp.now(),
        });

        // Show success message BEFORE navigating or dismissing the widget
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully registered for the event!')),
        );
      }
    } catch (e) {
      // Show error message if registration fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to register: $e')),
      );
    }
  }
}