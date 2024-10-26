import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // To get the current logged-in user
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Import local notifications
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';

// Initialize the local notifications plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

class StudentEventDetails extends StatefulWidget {
  final String eventName;
  final String eventVenue;
  final String eventDescription;
  final String startTime;    // Accept startTime
  final String endTime;      // Accept endTime
  final String eventId;      // Add eventId to identify the event
  final String eventDate;
  final String? imageUrl;

  // Constructor to receive the event data
  const StudentEventDetails({
    Key? key,
    required this.eventName,
    required this.eventVenue,
    required this.eventDescription,
    required this.startTime,    // Initialize startTime
    required this.endTime,      // Initialize endTime
    required this.eventId,
    required this.eventDate,
    this.imageUrl, // Initialize eventDate
  }) : super(key: key);

  @override
  _StudentEventDetailsState createState() => _StudentEventDetailsState();
}

class _StudentEventDetailsState extends State<StudentEventDetails> {
  bool isLiked = false; // Track if the event is liked or not
  bool isRegistered = false; // Track if the user is already registered
  bool canAttend = false; // Check if the "Attend Event" button can be enabled

  @override
  void initState() {
    super.initState();
    _checkIfLiked(); // Check if the event is already liked
    _checkIfRegistered(); // Check if the user is already registered
    _initializeNotifications(); // Initialize notifications
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF801e15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          title: const Text(
            'Error',
            style: TextStyle(
              fontFamily: 'FredokaOne',
              fontSize: 20,
              color: Color(0xFFe8c9ab),
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontFamily: 'FredokaOne',
              fontSize: 16,
              color: Color(0xFFe8c9ab),
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
                  color: Color(0xFFe8c9ab),
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
          backgroundColor: const Color(0xFF801e15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          title: const Text(
            'Success',
            style: TextStyle(
              fontFamily: 'FredokaOne',
              fontSize: 20,
              color: Color(0xFFe8c9ab),
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontFamily: 'FredokaOne',
              fontSize: 16,
              color: Color(0xFFe8c9ab),
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
                  color: Color(0xFFe8c9ab),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Function to initialize notifications
  void _initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tapped
        if (response.payload != null) {
          print('Notification payload: ${response.payload}');
        }
      },
    );

    // Initialize time zone data
    tz.initializeTimeZones();
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

  // Function to check if the user is already registered for the event
  Future<void> _checkIfRegistered() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        DocumentSnapshot registeredEvent = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('registeredEvents')
            .doc(widget.eventId)
            .get();

        if (registeredEvent.exists) {
          setState(() {
            isRegistered = true;
            _checkIfCanAttend(); // Check if the "Attend Event" button can be enabled
          });
        }
      }
    } catch (e) {
      print('Error checking registration status: $e');
    }
  }

  // Function to check if "Attend Event" can be enabled based on the event date
  void _checkIfCanAttend() {
    DateTime eventDate = DateFormat('yyyy-MM-dd').parse(widget.eventDate);
    DateTime today = DateTime.now();

    if (today.year == eventDate.year && today.month == eventDate.month && today.day == eventDate.day) {
      setState(() {
        canAttend = true;
      });
    }
  }

  // Function to schedule a notification
  Future<void> _scheduleNotification(String notificationTitle, String notificationBody) async {
    await flutterLocalNotificationsPlugin.show(
      widget.eventId.hashCode, // Use a unique notification ID
      notificationTitle,
      notificationBody,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'event_channel_id',
          'Event Notifications',
          channelDescription: 'Notifications for upcoming events',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      payload: 'Event Notification',
    );
  }

  // Schedule a notification for the registered event
  Future<void> _scheduleEventNotification() async {
    final String formattedDate = widget.eventDate;
    await _scheduleNotification(
      'Event Registered: ${widget.eventName}',
      'You have registered for the event on $formattedDate.',
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
                              image: widget.imageUrl != null
                                  ? DecorationImage(
                                image: NetworkImage(widget.imageUrl!),
                                fit: BoxFit.cover,
                              )
                                  : null,
                            ),
                            child: widget.imageUrl == null
                                ? const Center(
                              child: Icon(
                                Icons.image,
                                size: 100,
                                color: Colors.grey,
                              ),
                            )
                                : null,
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
                // Register or Attend Button
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF801e15),
                      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: isRegistered
                        ? (canAttend ? () => _attendEvent() : null)
                        : () => _showConfirmationDialog(context),
                    child: Text(
                      isRegistered ? 'Attend Event' : 'Register for Event',
                      style: const TextStyle(
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

  // Function to attend the event
  Future<void> _attendEvent() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        Map<String, dynamic> attendedEventData = {
          'eventId': widget.eventId,
          'eventName': widget.eventName,
          'eventVenue': widget.eventVenue,
          'startTime': widget.startTime,
          'endTime': widget.endTime,
          'eventDate': widget.eventDate, // Save the event date as well
          'attendedTime': Timestamp.now(),
        };

        // Save the attended event
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('attendedEvents')
            .doc(widget.eventId)
            .set(attendedEventData);

        // Check for badges
        await _checkForBadge(currentUser.uid);

        showSuccessDialog('Enjoy your event!');
      }
    } catch (e) {
      showErrorDialog('Failed to attend the event: $e');
    }
  }

  // Check and award badges based on attendance count
  Future<void> _checkForBadge(String userId) async {
    // Get the count of attended events
    QuerySnapshot attendedEventsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('attendedEvents')
        .get();

    int attendedCount = attendedEventsSnapshot.size;

    String? badgeTitle;
    String? badgeImage;

    if (attendedCount == 1) {
      badgeTitle = "Attended 1 event";
      badgeImage = "assets/images/bronze.png";
    } else if (attendedCount == 10) {
      badgeTitle = "Attended 10 events";
      badgeImage = "assets/images/silver.png";
    } else if (attendedCount == 50) {
      badgeTitle = "Attended 50 events";
      badgeImage = "assets/images/gold.png";
    } else if (attendedCount == 100) {
      badgeTitle = "Attended 100 events";
      badgeImage = "assets/images/diamond.png";
    }

    // If a badge needs to be awarded
    if (badgeTitle != null && badgeImage != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('badges')
          .doc(badgeTitle)
          .set({
        'title': badgeTitle,
        'imagePath': badgeImage,
        'awardedTime': Timestamp.now(),
      });

      // Notify user about the new badge
      showSuccessDialog('Congratulations! You earned a new badge: $badgeTitle');
    }
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
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                await _registerForEvent(context);
                Navigator.of(context).pop();
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
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        String studentName = userDoc['name'] ?? 'Anonymous';

        Map<String, dynamic> registeredEventData = {
          'eventId': widget.eventId,
          'eventName': widget.eventName,
          'eventVenue': widget.eventVenue,
          'startTime': widget.startTime,
          'endTime': widget.endTime,
          'eventDate': widget.eventDate, // Save the event date as well
          'registrationTime': Timestamp.now(),
        };

        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('registeredEvents')
            .doc(widget.eventId)
            .set(registeredEventData);

        await FirebaseFirestore.instance
            .collection('events')
            .doc(widget.eventId)
            .collection('participants')
            .doc(currentUser.uid)
            .set({
          'userId': currentUser.uid,
          'name': studentName,
          'email': currentUser.email ?? 'No email provided',
          'registrationTime': Timestamp.now(),
        });

        // Schedule notification for the event registration
        await _scheduleEventNotification();

        setState(() {
          isRegistered = true;
        });

        showSuccessDialog('Successfully registered for the event!');
      }
    } catch (e) {
      showErrorDialog('Failed to register: $e');
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
}