import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'login.dart';
import 'StudentRegisteredEvent.dart';
import 'StudentSaved.dart';
import 'StudentBadgesPage.dart';

class StudentProfile extends StatefulWidget {
  const StudentProfile({Key? key}) : super(key: key);

  @override
  _StudentProfileState createState() => _StudentProfileState();
}

class _StudentProfileState extends State<StudentProfile> {
  String? studentName;
  String? email;
  String? currentUserId; // Store userId
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  // Fetch user details and profile picture from Firestore and Firebase Storage
  Future<void> _fetchUserDetails() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      setState(() {
        studentName = userDoc['name'];
        email = currentUser.email;
        currentUserId = currentUser.uid;
      });

      // Retrieve profile picture from Firebase Storage
      try {
        final ref = FirebaseStorage.instance.ref().child('profile_pictures/${currentUser.uid}.jpg');
        _profileImageUrl = await ref.getDownloadURL();
      } catch (e) {
        // No profile picture exists
        print("Error loading profile picture: $e"); // Debugging error
        _profileImageUrl = null;
      }
      setState(() {}); // Update the UI
    }
  }

  Future<void> _uploadProfilePicture() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final ref = FirebaseStorage.instance.ref().child('profile_pictures/${user.uid}.jpg');

      await ref.putFile(file);
      final url = await ref.getDownloadURL();

      setState(() {
        _profileImageUrl = url;
      });

      // Optional: Save profile picture URL to Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'profileImageUrl': url,
      });
    }
  }

  // Logout the user and navigate to the login screen
  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
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
                      width: 55,
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
                      height: 90,
                    ),
                    SizedBox(
                      width: 55,
                      height: 55,
                      child: IconButton(
                        icon: Image.asset('assets/images/logout.png'),
                        onPressed: () => _logout(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Profile Picture with Edit Icon
              Center(
                child: SizedBox(
                  width: 120,
                  height: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        backgroundImage: _profileImageUrl != null ? NetworkImage(_profileImageUrl!) : null,
                        child: _profileImageUrl == null
                            ? Image.asset(
                          'assets/images/profile.png',
                          height: 60,
                          width: 60,
                        )
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 10,
                        child: GestureDetector(
                          onTap: _uploadProfilePicture,
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: Image.asset('assets/images/pencil.png'),
                          ),
                        ),
                      ),
                    ],
                  ),
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
                              builder: (context) => StudentRegisteredEvent(userId: currentUserId!),
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
                              builder: (context) => StudentSaved(userId: currentUserId!),
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
                    const SizedBox(height: 20),
                    // "View Badges" Button
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const StudentBadgesPage()),
                        );
                      },
                      icon: Image.asset(
                        'assets/images/badge.png',
                        height: 24,
                        width: 24,
                      ),
                      label: const Text(
                        'View Badges',
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