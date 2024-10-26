import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentBadgesPage extends StatefulWidget {
  const StudentBadgesPage({Key? key}) : super(key: key);

  @override
  _StudentBadgesPageState createState() => _StudentBadgesPageState();
}

class _StudentBadgesPageState extends State<StudentBadgesPage> {
  List<Map<String, dynamic>> badges = [];

  @override
  void initState() {
    super.initState();
    _fetchBadges();
  }

  // Function to fetch badges from Firestore
  Future<void> _fetchBadges() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        QuerySnapshot badgeSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('badges')
            .get();

        setState(() {
          badges = badgeSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch badges: $e')),
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
                image: AssetImage('assets/images/bg2.png'), // Ensure consistency with the StudentProfile page
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Top bar with back arrow and title
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: SizedBox(
                          width: 30, // Adjust width for a smaller arrow
                          height: 30, // Adjust height for a smaller arrow
                          child: Image.asset('assets/images/back.png'),
                        ),
                        onPressed: () {
                          Navigator.pop(context); // Go back when tapped
                        },
                      ),
                      const Text(
                        'My Badges',
                        style: TextStyle(
                          fontFamily: 'FredokaOne',
                          fontSize: 36,
                          color: Color(0xFFe8c9ab),
                        ),
                      ),
                      const SizedBox(width: 40), // To keep title centered
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: badges.isEmpty
                      ? const Center(
                    child: Text(
                      'No badges earned yet.',
                      style: TextStyle(
                        fontFamily: 'FredokaOne',
                        fontSize: 18,
                        color: Color(0xFFe8c9ab),
                      ),
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    itemCount: badges.length,
                    itemBuilder: (context, index) {
                      final badge = badges[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: const Color(0xFF801e15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: Image.asset(
                            badge['imagePath'], // The path of the badge image (e.g., 'assets/images/bronze.png')
                            height: 50,
                            width: 50,
                          ),
                          title: Text(
                            badge['title'], // The title of the badge
                            style: const TextStyle(
                              fontFamily: 'FredokaOne',
                              fontSize: 20,
                              color: Color(0xFFe8c9ab),
                            ),
                          ),
                          subtitle: Text(
                            'Awarded on: ${badge['awardedTime'].toDate().toString().split(' ')[0]}',
                            style: const TextStyle(
                              fontFamily: 'FredokaOne',
                              fontSize: 14,
                              color: Color(0xFFe8c9ab),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}