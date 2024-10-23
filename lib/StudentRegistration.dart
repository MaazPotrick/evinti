import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'StudentTagSelection.dart'; // Import StudentTagSelection
import 'login.dart';

class StudentRegistration extends StatefulWidget {
  const StudentRegistration({Key? key}) : super(key: key);

  @override
  _StudentRegistrationState createState() => _StudentRegistrationState();
}

class _StudentRegistrationState extends State<StudentRegistration> {
  // Controllers for user input
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // Terms & Conditions Checkbox
  bool agreeToTerms = false;

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
                    height: 150,
                  ),
                  const SizedBox(height: 0),
                  // "Sign Up" Text
                  const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontFamily: 'AbrilFatface',
                      fontSize: 36,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Name Input
                  Stack(
                    children: [
                      _buildTextField(
                        context,
                        controller: nameController,
                        iconPath: 'assets/images/profile.png',
                        hintText: 'Full Name',
                        labelText: 'Name',
                      ),
                      Positioned(
                        right: 0,
                        top: 20,
                        child: Transform.rotate(
                          angle: -0.3,
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
                  // Email Input
                  _buildTextField(
                    context,
                    controller: emailController,
                    iconPath: 'assets/images/mail.png',
                    hintText: 'name@example.com',
                    labelText: 'Email',
                  ),
                  const SizedBox(height: 20),
                  // Password Input
                  _buildTextField(
                    context,
                    controller: passwordController,
                    iconPath: 'assets/images/password.png',
                    hintText: '●●●●●●●●',
                    labelText: 'Password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  // Confirm Password Input
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _buildTextField(
                        context,
                        controller: confirmPasswordController,
                        iconPath: 'assets/images/confirm.png',
                        hintText: '●●●●●●●●',
                        labelText: 'Confirm Password',
                        obscureText: true,
                      ),
                      Positioned(
                        left: 0,
                        bottom: -5,
                        child: Transform.rotate(
                          angle: 0.3,
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
                  // Terms and Conditions Checkbox
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: agreeToTerms,
                        onChanged: (bool? value) {
                          setState(() {
                            agreeToTerms = value ?? false;
                          });
                        },
                        activeColor: const Color(0xFF597fef),
                      ),
                      const Text(
                        'You Agree to Terms & Conditions',
                        style: TextStyle(
                          fontFamily: 'FredokaOne',
                          fontSize: 14,
                          color: Color(0xFF597fef),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Sign Up Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF801e15),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 100, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      if (passwordController.text == confirmPasswordController.text && agreeToTerms) {
                        try {
                          // Register user with Firebase
                          UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                          );

                          // Get the UID of the newly registered user
                          String uid = userCredential.user?.uid ?? "";

                          // Automatically create a Firestore document for the user
                          await FirebaseFirestore.instance.collection('users').doc(uid).set({
                            'email': emailController.text.trim(),
                            'role': 'student',
                            'name': nameController.text.trim(),
                          });

                          // Navigate to StudentTagSelection instead of Login on successful sign-up
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => StudentTagSelection()),
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Registration Successful!'))
                          );
                        } catch (e) {
                          // Show error message
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: ${e.toString()}'))
                          );
                        }
                      } else {
                        // Handle validation error
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Passwords do not match or terms not agreed'))
                        );
                      }
                    },
                    child: const Text(
                      'Sign Up',
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
          ),
        ],
      ),
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
}