import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart'; // Import the login page

class StudentTagSelection extends StatefulWidget {
  @override
  _StudentTagSelectionState createState() => _StudentTagSelectionState();
}

class _StudentTagSelectionState extends State<StudentTagSelection> {
  // List of available tags
  List<String> allTags = [
    "Music", "Alternative", "Cultural", "Educational", "Food", "Gaming",
    "Socializing", "Sports", "Arts", "Business", "Health"
  ];
  List<String> selectedTags = []; // List to hold the selected tags

  void _saveTags() async {
    // Save selected tags to a 'preferredTags' sub-collection under the user's document
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final preferredTagsCollection = userDocRef.collection('preferredTags');

      // Clear any existing documents in 'preferredTags' collection (optional)
      final snapshot = await preferredTagsCollection.get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      // Add the selected tags as separate documents within 'preferredTags'
      for (String tag in selectedTags) {
        await preferredTagsCollection.add({'tagName': tag});
      }

      // Navigate to the login page after saving
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preferences saved! Please log in.')),
      );
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
                image: AssetImage('assets/images/bg2.png'), // Reuse the background from StudentSearch
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const Text(
                    'Add your interests',
                    style: TextStyle(
                      fontFamily: 'FredokaOne',
                      fontSize: 30,
                      color: Color(0xFFe8c9ab),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Customize your event recommendations based on your preferences. The more you select, the better suggestions we can offer.',
                    style: TextStyle(
                      fontFamily: 'FredokaOne',
                      fontSize: 16,
                      color: Color(0xFFe8c9ab),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Tag selection grid
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: allTags.map((tag) {
                      final isSelected = selectedTags.contains(tag);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              selectedTags.remove(tag);
                            } else {
                              selectedTags.add(tag);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF801e15) : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFe8c9ab),
                              width: 2,
                            ),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontFamily: 'FredokaOne',
                              fontSize: 16,
                              color: isSelected ? Colors.white : const Color(0xFFe8c9ab),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 30),
                  // Save button
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF801e15), // Button color
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _saveTags,
                      child: const Text(
                        'Save Preferences',
                        style: TextStyle(
                          fontFamily: 'FredokaOne',
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
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