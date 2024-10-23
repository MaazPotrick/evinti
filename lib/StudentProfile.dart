import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';
import 'StudentRegisteredEvent.dart';
import 'StudentSaved.dart';

class StudentProfile extends StatefulWidget {
  const StudentProfile({Key? key}) : super(key: key);

  @override
  _StudentProfileState createState() => _StudentProfileState();
}

class _StudentProfileState extends State<StudentProfile> {
  String? studentName;
  String? email;
  String? currentUserId; // Store userId

  @override
  void initState() {
    super.initState();
    _fetchUserDetails(); // Fetch the user details when the page loads
  }

  // Fetch user details from Firestore
  Future<void> _fetchUserDetails() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      setState(() {
        studentName = userDoc['name'];
        email = currentUser.email;
        currentUserId = currentUser.uid; // Save userId
      });
    }
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
              const SizedBox(height: 50),
              // Top bar with settings and logout icons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 55, // Smaller size for the back icon
                      height: 55,
                      child: IconButton(
                        icon: Image.asset('assets/images/back.png'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Image.asset(
                      'assets/images/Logo.png',
                      height: 90, // Logo size
                    ),
                    SizedBox(
                      width: 55, // Logout icon
                      height: 55,
                      child: IconButton(
                        icon: Image.asset('assets/images/logout.png'),
                        onPressed: () => _logout(context), // Call logout method
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Profile Picture
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: Image.asset(
                  'assets/images/profile.png',
                  height: 60,
                  width: 60,
                ),
              ),
              const SizedBox(height: 20),
              // Display Student Name and Email
              Text(
                studentName ?? "Loading Name...",
                style: const TextStyle(
                  fontFamily: 'FredokaOne',
                  fontSize: 36,
                  color: Color(0xFFe8c9ab),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                email ?? 'Loading Email...',
                style: const TextStyle(
                  fontFamily: 'FredokaOne',
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              // Buttons for "Events Registered" and "Saved"
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF801e15),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // "Events Registered for" Button
                    TextButton.icon(
                      onPressed: () {
                        if (currentUserId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StudentRegisteredEvent(userId: currentUserId!), // Pass the userId to StudentRegisteredEvent page
                            ),
                          );
                        }
                      },
                      icon: Image.asset(
                        'assets/images/bell.png',
                        height: 24,
                        width: 24,
                      ),
                      label: const Text(
                        'Events Registered for',
                        style: TextStyle(
                          fontFamily: 'FredokaOne',
                          fontSize: 23,
                          color: Color(0xFFe8c9ab),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // "Saved" Button
                    TextButton.icon(
                      onPressed: () {
                        if (currentUserId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StudentSaved(userId: currentUserId!), // Pass the userId to StudentSaved page
                            ),
                          );
                        }
                      },
                      icon: Image.asset(
                        'assets/images/heart.png',
                        height: 24,
                        width: 24,
                      ),
                      label: const Text(
                        'Saved',
                        style: TextStyle(
                          fontFamily: 'FredokaOne',
                          fontSize: 23,
                          color: Color(0xFFe8c9ab),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}