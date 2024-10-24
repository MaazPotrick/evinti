import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase core
import 'package:permission_handler/permission_handler.dart'; // Import permission handler
import 'StudentSearch.dart';
import 'login.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Import local notifications
import 'package:timezone/data/latest.dart' as tz; // Import timezone data
import 'package:timezone/timezone.dart' as tz; // Import timezone package

// Initialize the local notifications plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

// Initialize Firebase before running the app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize timezone data
  tz.initializeTimeZones();

  // Configure notification settings
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      // Handle notification tapped
      if (response.payload != null) {
        // You can navigate to a specific screen here if needed
        print('Notification payload: ${response.payload}');
      }
    },
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  // Request notification and storage permissions
  Future<void> _requestPermissions() async {
    // Request notification permission
    PermissionStatus notificationStatus = await Permission.notification.request();
    if (notificationStatus.isGranted) {
      print("Notification permission granted");
    } else {
      print("Notification permission denied");
    }

    // Request storage permission (if needed)
    PermissionStatus storageStatus = await Permission.storage.request();
    if (storageStatus.isGranted) {
      print("Storage permission granted");
    } else {
      print("Storage permission denied");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Evinti App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LoginScreen(),
      debugShowCheckedModeBanner: false, // Optional: Hide debug banner
    );
  }
}

// Function to schedule notifications for events
Future<void> scheduleNotification(
    DateTime eventDate, String eventTitle, String eventDescription) async {
  // Convert DateTime to TZDateTime for 2 days before the event
  final tz.TZDateTime notificationTime = tz.TZDateTime.from(
      eventDate.subtract(const Duration(days: 2)), tz.local);

  // Scheduling the notification for 2 days before the event
  await flutterLocalNotificationsPlugin.zonedSchedule(
    0,
    'Upcoming Event: $eventTitle',
    'The event "$eventTitle" is happening in 2 days.',
    notificationTime,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'your_channel_id',
        'Event Notifications',
        channelDescription: 'Notification channel for event reminders',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      ),
    ),
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation:
    UILocalNotificationDateInterpretation.absoluteTime,
  );

  // Convert DateTime to TZDateTime for the event day
  final tz.TZDateTime eventDay = tz.TZDateTime.from(eventDate, tz.local);

  // Scheduling the notification for the day of the event
  await flutterLocalNotificationsPlugin.zonedSchedule(
    1,
    'Event Today: $eventTitle',
    'The event "$eventTitle" is happening today.',
    eventDay,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'your_channel_id',
        'Event Notifications',
        channelDescription: 'Notification channel for event reminders',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      ),
    ),
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation:
    UILocalNotificationDateInterpretation.absoluteTime,
  );
}