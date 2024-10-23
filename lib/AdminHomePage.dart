import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth for logout functionality
import 'login.dart'; // Corrected the reference to login.dart
import 'AdminVenueRequests.dart'; // Reference to the venue requests page
import 'AdminVenueManagement.dart'; // Reference to the new venue management page

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({Key? key}) : super(key: key);

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
                  const SizedBox(height: 30),
                  // Logo
                  Image.asset(
                    'assets/images/Logo2.png',
                    height: 100,
                  ),
                  const SizedBox(height: 40),
                  // Welcome Text
                  const Text(
                    'Welcome, Admin',
                    style: TextStyle(
                      fontFamily: 'FredokaOne',
                      fontSize: 36,
                      color: Color(0xFF801e15),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Buttons Container
                  Expanded(
                    child: ListView(
                      children: [
                        // View Venue Requests Button
                        _buildAdminButton(
                          context,
                          'View Venue Requests',
                          const AdminVenueRequests(),
                          backgroundColor: const Color(0xFF801e15),
                        ),
                        const SizedBox(height: 20),
                        // Manage Venues Button
                        _buildAdminButton(
                          context,
                          'Manage Venues',
                          const AdminVenueManagement(),
                          backgroundColor: const Color(0xFF801e15),
                        ),
                        const SizedBox(height: 20),
                        // Logout Button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFab2d22),
                            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            // Perform Firebase sign out
                            await FirebaseAuth.instance.signOut();

                            // Navigate back to the LoginScreen
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(), // Redirect to LoginScreen after logout
                              ),
                            );
                          },
                          child: const Text(
                            'Logout',
                            style: TextStyle(
                              fontFamily: 'FredokaOne',
                              fontSize: 18,
                              color: Color(0xFFe8c9ab),
                            ),
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

  // Method to build an admin button
  Widget _buildAdminButton(BuildContext context, String text, Widget targetPage, {Color backgroundColor = const Color(0xFF801e15)}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => targetPage,
          ),
        );
      },
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'FredokaOne',
          fontSize: 18,
          color: Color(0xFFe8c9ab),
        ),
      ),
    );
  }
}