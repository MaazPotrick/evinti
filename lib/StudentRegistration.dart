import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:confetti/confetti.dart';
import 'StudentTagSelection.dart'; // Import StudentTagSelection

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
          backgroundColor: const Color(0xFF801e15), // Custom background color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          title: const Text(
            'Error',
            style: TextStyle(
              fontFamily: 'FredokaOne',
              fontSize: 20,
              color: Color(0xFFe8c9ab),
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontFamily: 'FredokaOne',
              fontSize: 16,
              color: Color(0xFFe8c9ab),
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
                  color: Color(0xFFe8c9ab),
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
              backgroundColor: const Color(0xFF801e15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              title: const Text(
                'Success',
                style: TextStyle(
                  fontFamily: 'FredokaOne',
                  fontSize: 20,
                  color: Color(0xFFe8c9ab),
                ),
              ),
              content: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'FredokaOne',
                  fontSize: 16,
                  color: Color(0xFFe8c9ab),
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
                      color: Color(0xFFe8c9ab),
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
                    obscureText: !_isPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Image.asset(
                        _isPasswordVisible ? 'assets/images/openEye.png' : 'assets/images/closeEye.png',
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
                        obscureText: !_isConfirmPasswordVisible,
                        suffixIcon: IconButton(
                          icon: Image.asset(
                            _isConfirmPasswordVisible ? 'assets/images/openEye.png' : 'assets/images/closeEye.png',
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
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}