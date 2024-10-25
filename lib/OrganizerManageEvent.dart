import 'package:evinti_app/OrganizerRejectedEvents.dart';
import 'package:flutter/material.dart';
import 'OrganizerApprovedEvents.dart'; // Import the OrganizerApprovedEvents page
import 'OrganizerRejectedEvents.dart';
import 'OrganizerEventList.dart';
import 'OrganizerEventParticipationGraph.dart';

class OrganizerManageEvent extends StatelessWidget {
  const OrganizerManageEvent({Key? key}) : super(key: key);

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
                  // Top Bar with Back Button and Logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Button Icon
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context); // Go back when tapped
                        },
                        icon: Image.asset('assets/images/back2.png'),
                        iconSize: 40,
                      ),
                      // Logo (center)
                      Image.asset(
                        'assets/images/Logo2.png',
                        height: 100, // Increased the logo size to make it bigger
                      ),
                      // Empty Box to maintain spacing
                      const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Manage Events Title
                  const Text(
                    'Manage Events',
                    style: TextStyle(
                      fontFamily: 'FredokaOne',
                      fontSize: 36,
                      color: Color(0xFF801e15),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Buttons for different functionalities
                  _buildManageButton(
                    context,
                    label: 'Approved Events',
                    onPressed: () {
                      // Navigate to the OrganizerApprovedEvents page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OrganizerApprovedEvents(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildManageButton(
                    context,
                    label: 'Rejected Events',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OrganizerRejectedEvents(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildManageButton(
                    context,
                    label: 'List of Participants',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OrganizerEventList(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildManageButton(
                    context,
                    label: 'Graph of Participants',
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OrganizerEventParticipationGraph(),
                          ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method to build each button with consistent styling
  Widget _buildManageButton(BuildContext context,
      {required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity, // Make button take full width
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF801e15), // Button color
          padding: const EdgeInsets.symmetric(vertical: 15), // Padding for the button
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFF470b06), width: 2), // Border styling
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'FredokaOne',
            fontSize: 18,
            color: Color(0xFFe8c9ab), // Text color
          ),
        ),
      ),
    );
  }
}