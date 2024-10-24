import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore to check user role
import 'StudentHome.dart';
import 'OrganizerHomePage.dart'; // Import Organizer Home Page
import 'AdminHomePage.dart';     // Import Admin Home Page
import 'StudentRegistration.dart';
import 'OrganizerRegistration.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers for getting user input
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/Bg1.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(
                    'assets/images/Logo.png',
                    height: 120,
                  ),
                  const SizedBox(height: 30),
                  // "Login" Text
                  const Text(
                    'Login',
                    style: TextStyle(
                      fontFamily: 'AbrilFatface',
                      fontSize: 36,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Email Input
                  Stack(
                    children: [
                      _buildTextField(
                        context,
                        controller: emailController,
                        iconPath: 'assets/images/mail.png',
                        hintText: 'name@example.com',
                        labelText: 'Email',
                      ),
                      Positioned(
                        right: 0,
                        top: 25,
                        child: Transform.rotate(
                          angle: -0.4,
                          child: Image.asset(
                            'assets/images/butterfly.png',
                            height: 20,
                            width: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Password Input
                  Stack(
                    children: [
                      _buildTextField(
                        context,
                        controller: passwordController,
                        iconPath: 'assets/images/password.png',
                        hintText: '●●●●●●●●',
                        labelText: 'Password',
                        obscureText: true,
                      ),
                      Positioned(
                        left: 0,
                        bottom: -2,
                        child: Transform.rotate(
                          angle: 0.4,
                          child: Image.asset(
                            'assets/images/butterfly.png',
                            height: 20,
                            width: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Login Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF801e15),
                      padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      // Get email and password from text fields
                      final email = emailController.text.trim();
                      final password = passwordController.text.trim();

                      if (email.isNotEmpty && password.isNotEmpty) {
                        try {
                          // Authenticate the user with Firebase Authentication
                          UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                            email: email,
                            password: password,
                          );

                          // Get the user's role from Firestore
                          final userDoc = await FirebaseFirestore.instance
                              .collection('users')
                              .doc(userCredential.user?.uid)
                              .get();

                          if (userDoc.exists) {
                            // Check the 'role' field in Firestore
                            final role = userDoc['role'];
                            if (role == 'admin') {
                              // Navigate to the Admin Home Page
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const AdminHomePage()),
                              );
                            } else if (role == 'student') {
                              // Navigate to the Student Home Page
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const StudentHome()),
                              );
                            } else if (role == 'organizer') {
                              // Navigate to the Organizer Home Page
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const OrganizerHomePage()),
                              );
                            } else {
                              // Show error if the role is unknown
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('Unknown role: $role'),
                              ));
                            }
                          } else {
                            // User not found in Firestore
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('User not found in Firestore.'),
                            ));
                          }
                        } catch (e) {
                          // Handle login error
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Login failed: ${e.toString()}'),
                          ));
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Please enter both email and password'),
                        ));
                      }
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontFamily: 'FredokaOne',
                        fontSize: 18,
                        color: Color(0xFFe8c9ab),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Register Button
                  TextButton(
                    onPressed: () {
                      _showRegistrationDialog(context);
                    },
                    child: const Text(
                      'Register New Account',
                      style: TextStyle(
                        fontFamily: 'FredokaOne',
                        fontSize: 12,
                        color: Color(0xFFe8c9ab),
                        decoration: TextDecoration.underline,
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

  void _showRegistrationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Registration Type'),
          content: const Text('Are you registering as a Student or an Event Organizer?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StudentRegistration()),
                );
              },
              child: const Text('Student'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OrganizerRegistration()),
                );
              },
              child: const Text('Event Organizer'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(BuildContext context,
      {required String iconPath,
        required String hintText,
        required String labelText,
        required TextEditingController controller,
        bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset(
              iconPath,
              height: 20,
              width: 20,
            ),
            const SizedBox(width: 8),
            Text(
              labelText,
              style: const TextStyle(
                fontFamily: 'FredokaOne',
                fontSize: 18,
                color: Color(0xFFe8c9ab),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(
            color: Color(0xFFe8c9ab),
          ),
          decoration: InputDecoration(
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            filled: true,
            fillColor: Colors.transparent,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFFe8c9ab),
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFFe8c9ab),
                width: 2,
              ),
            ),
            hintText: hintText,
            hintStyle: const TextStyle(
              fontFamily: 'FredokaOne',
              fontSize: 16,
              color: Color(0xFFe8c9ab),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}