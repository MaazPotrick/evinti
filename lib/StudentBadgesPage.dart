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
      appBar: AppBar(
        title: const Text('My Badges'),
        backgroundColor: const Color(0xFF801e15),
      ),
      body: badges.isEmpty
          ? const Center(
        child: Text('No badges earned yet.'),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(20.0),
        itemCount: badges.length,
        itemBuilder: (context, index) {
          final badge = badges[index];
          return Card(
            child: ListTile(
              leading: Image.asset(
                badge['imagePath'], // The path of the badge image (e.g., 'assets/images/bronze.png')
                height: 50,
                width: 50,
              ),
              title: Text(
                badge['title'], // The title of the badge
                style: const TextStyle(fontFamily: 'FredokaOne', fontSize: 18),
              ),
              subtitle: Text(
                'Awarded on: ${badge['awardedTime'].toDate().toString().split(' ')[0]}',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          );
        },
      ),
    );
  }
}