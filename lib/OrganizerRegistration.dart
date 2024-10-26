import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:confetti/confetti.dart';
import 'OrganizerHomePage.dart';

class OrganizerRegistration extends StatefulWidget {
  const OrganizerRegistration({Key? key}) : super(key: key);

  @override
  _OrganizerRegistrationState createState() => _OrganizerRegistrationState();
}

class _OrganizerRegistrationState extends State<OrganizerRegistration> {
  // Controllers for user input
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController clubNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // Terms & Conditions Checkbox
  bool agreeToTerms = false;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Confetti controller for celebration
  final ConfettiController _confettiController = ConfettiController(duration: const Duration(seconds: 2));

  bool isPasswordValid(String password) {
    final passwordRegex = RegExp(
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
    );
    return passwordRegex.hasMatch(password);
  }

  // Function to show an error message box
  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFe8c9ab), // Custom background color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          title: const Text(
            'Error',
            style: TextStyle(
              fontFamily: 'FredokaOne',
              fontSize: 20,
              color: Color(0xFF801e15),
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontFamily: 'FredokaOne',
              fontSize: 16,
              color: Color(0xFF801e15),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  fontFamily: 'FredokaOne',
                  fontSize: 16,
                  color: Color(0xFF801e15),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Function to show a success message box
  void showSuccessDialog(String message) {
    _confettiController.play(); // Start confetti animation
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                emissionFrequency: 0.05,
                numberOfParticles: 30,
                gravity: 0.3,
              ),
            ),
            AlertDialog(
              backgroundColor: const Color(0xFFe8c9ab),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              title: const Text(
                'Success',
                style: TextStyle(
                  fontFamily: 'FredokaOne',
                  fontSize: 20,
                  color: Color(0xFF801e15),
                ),
              ),
              content: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'FredokaOne',
                  fontSize: 16,
                  color: Color(0xFF801e15),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _confettiController.stop(); // Stop confetti when dialog is closed
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontFamily: 'FredokaOne',
                      fontSize: 16,
                      color: Color(0xFF801e15),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
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
                image: AssetImage('assets/images/bg3.png'),
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
                    'assets/images/Logo2.png',
                    height: 130, // Slightly reduce logo size to save vertical space
                  ),
                  const SizedBox(height: 0), // Remove additional space between the logo and Sign Up
                  // "Sign Up" Text
                  const Text(
                    'Sign up',
                    style: TextStyle(
                      fontFamily: 'AbrilFatface',
                      fontSize: 36,
                      color: Color(0xFF801e15),
                    ),
                  ),
                  const SizedBox(height: 5), // Reduce space after Sign Up text
                  // Name Input
                  Stack(
                    children: [
                      _buildTextField(
                        context,
                        controller: nameController,
                        iconPath: 'assets/images/profile2.png',
                        hintText: 'Name as per I/C',
                        labelText: 'Name',
                      ),
                      Positioned(
                        right: 0,
                        top: 20,
                        child: Transform.rotate(
                          angle: -0.3, // Rotate counterclockwise by ~17 degrees
                          child: Image.asset(
                            'assets/images/butterfly.png',
                            height: 20,
                            width: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10), // Reduce space between fields
                  // Email Input
                  _buildTextField(
                    context,
                    controller: emailController,
                    iconPath: 'assets/images/mail2.png',
                    hintText: 'Email',
                    labelText: 'Email',
                  ),
                  const SizedBox(height: 10), // Reduce space between fields
                  // Club Name Input
                  _buildTextField(
                    context,
                    controller: clubNameController,
                    iconPath: 'assets/images/people.png',
                    hintText: 'Club Name',
                    labelText: 'Club Name',
                  ),
                  const SizedBox(height: 10), // Reduce space between fields
                  // Password Input
                  _buildTextField(
                    context,
                    controller: passwordController,
                    iconPath: 'assets/images/password2.png',
                    hintText: '●●●●●●●●',
                    labelText: 'Password',
                    obscureText: !_isPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Image.asset(
                        _isPasswordVisible ? 'assets/images/openEye2.png' : 'assets/images/closeEye2.png',
                        height: 20,
                        width: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 10), // Reduce space between fields
                  // Confirm Password Input
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _buildTextField(
                        context,
                        controller: confirmPasswordController,
                        iconPath: 'assets/images/confirm2.png',
                        hintText: '●●●●●●●●',
                        labelText: 'Confirm Password',
                        obscureText: !_isConfirmPasswordVisible,
                        suffixIcon: IconButton(
                          icon: Image.asset(
                            _isConfirmPasswordVisible ? 'assets/images/openEye2.png' : 'assets/images/closeEye2.png',
                            height: 20,
                            width: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                            });
                          },
                        ),
                      ),
                      Positioned(
                        left: 0,
                        bottom: -5,
                        child: Transform.rotate(
                          angle: 0.3, // Rotate clockwise by ~17 degrees
                          child: Image.asset(
                            'assets/images/butterfly.png',
                            height: 20,
                            width: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10), // Reduce space between fields
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
                  const SizedBox(height: 15), // Reduced space before the button
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

                      if (!isPasswordValid(passwordController.text)) {
                        showErrorDialog('Password must include at least 8 characters, one uppercase letter, one lowercase letter, one number, and one special character.');
                        return;
                      }

                      if (passwordController.text == confirmPasswordController.text && agreeToTerms) {
                        try {
                          // Register user with Firebase
                          UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                          );

                          // Get the UID of the newly registered user
                          String uid = userCredential.user?.uid ?? "";

                          // Automatically create a Firestore document for the organizer
                          await FirebaseFirestore.instance.collection('users').doc(uid).set({
                            'email': emailController.text.trim(),
                            'role': 'organizer', // Set role to organizer
                            'name': nameController.text.trim(), // Optional: store user's name
                            'clubName': clubNameController.text.trim(), // Store club name
                          });

                          // Navigate to Organizer Home on successful sign-up
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const OrganizerHomePage()),
                          );

                          showSuccessDialog('Registration Successful!');
                        } catch (e) {
                          // Show error message
                          showErrorDialog('Error: ${e.toString()}');
                        }
                      } else {
                        // Handle validation error
                        showErrorDialog('Passwords do not match or terms not agreed.');
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

  @override
  void dispose() {
    _confettiController.dispose(); // Dispose of the confetti controller
    super.dispose();
  }

  Widget _buildTextField(BuildContext context,
      {required String iconPath,
        required String hintText,
        required String labelText,
        required TextEditingController controller,
        bool obscureText = false,
        Widget? suffixIcon}) {
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
                color: Color(0xFF801e15),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(
            color: Color(0xFF801e15),
          ),
          decoration: InputDecoration(
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            filled: true,
            fillColor: Colors.transparent,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFF801e15),
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFF801e15),
                width: 2,
              ),
            ),
            hintText: hintText,
            hintStyle: const TextStyle(
              fontFamily: 'FredokaOne',
              fontSize: 16,
              color: Color(0xFF801e15),
            ),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}