import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'login.dart';

class OrganizerProfile extends StatefulWidget {
  const OrganizerProfile({Key? key}) : super(key: key);

  @override
  _OrganizerProfileState createState() => _OrganizerProfileState();
}

class _OrganizerProfileState extends State<OrganizerProfile> {
  String? _name;
  String? _email;
  String? _clubName;
  int _eventsCreated = 0;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchOrganizerDetails();
  }

  Future<void> _fetchOrganizerDetails() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      String clubName = userDoc['clubName'];

      setState(() {
        _name = userDoc['name'];
        _email = user.email;
        _clubName = clubName;
      });

      // Check for an existing profile picture
      try {
        final ref = FirebaseStorage.instance.ref().child('profile_pictures/${user.uid}.jpg');
        _profileImageUrl = await ref.getDownloadURL();
      } catch (e) {
        // Profile picture doesn't exist yet
        _profileImageUrl = null;
      }

      QuerySnapshot eventSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('clubId', isEqualTo: clubName)
          .get();

      setState(() {
        _eventsCreated = eventSnapshot.docs.length;
      });
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
                  // Top Row with back button and logout icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: SizedBox(
                          width: 30,
                          height: 30,
                          child: Image.asset('assets/images/back2.png'),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      IconButton(
                        icon: SizedBox(
                          width: 40,
                          height: 40,
                          child: Image.asset('assets/images/logout2.png'),
                        ),
                        onPressed: () => _logout(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Profile picture placeholder
                  // Centered Profile picture with edit icon beside and slightly lower
                  Center(
                    child: SizedBox(
                      width: 120, // Slightly larger to allow space for the pencil icon
                      height: 100,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            backgroundImage: _profileImageUrl != null ? NetworkImage(_profileImageUrl!) : null,
                            child: _profileImageUrl == null
                                ? const Icon(
                              Icons.person,
                              size: 60,
                              color: Color(0xFF801e15),
                            )
                                : null,
                          ),
                          Positioned(
                            right: 0,
                            bottom: 10, // Lower the pencil icon a bit
                            child: GestureDetector(
                              onTap: _uploadProfilePicture,
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: Image.asset('assets/images/pencil2.png'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Organizer name display
                  Text(
                    _name ?? 'Organizer Name',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'FredokaOne',
                      fontSize: 26,
                      color: Color(0xFF801e15),
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Email display
                  Text(
                    _email ?? 'Email not available',
                    style: const TextStyle(
                      fontFamily: 'FredokaOne',
                      fontSize: 16,
                      color: Color(0xFF470b06),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Combined Container for Club and Total Events Created
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFe8c9ab),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF470b06), width: 2),
                    ),
                    child: Column(
                      children: [
                        // Club Name
                        const Text(
                          'Club Name:',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'FredokaOne',
                            fontSize: 20,
                            color: Color(0xFF470b06),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _clubName ?? 'Club Name',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'FredokaOne',
                            fontSize: 18,
                            color: Color(0xFF801e15),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Divider line
                        Divider(
                          color: const Color(0xFF470b06),
                          thickness: 1,
                        ),
                        const SizedBox(height: 20),
                        // Total Events Created
                        const Text(
                          'Total Events Created',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'FredokaOne',
                            fontSize: 20,
                            color: Color(0xFF470b06),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '$_eventsCreated',
                          style: const TextStyle(
                            fontFamily: 'FredokaOne',
                            fontSize: 28,
                            color: Color(0xFF801e15),
                          ),
                        ),
                      ],
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