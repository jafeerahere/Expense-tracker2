import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jaff/global/custom_textfeild.dart';
import 'package:jaff/global/showtoast.dart';
import 'package:jaff/models/expense_screen.dart';
import 'package:jaff/services/firebaseauth_service.dart';
class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  bool _isSigning = false;

  bool _rememberMe = false;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signUp() async {
    setState(() {
      _isSigning = true;
    });

    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    // Input validation
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        _isSigning = false;
      });
      showToast(message: 'All fields are required');
      return;
    }

    // Signing up the user
    User? user = await _auth.signUpWithEmailAndPassword(email, password);

    setState(() {
      _isSigning = false;
    });

    if (user != null) {
      print('User Registered Successfully');
      Get.offAll(const ExpenseTrackerPage()); // Navigate to DashboardScreen on success
    } else {
      print('Sign up failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                CustomTextField(
                  controller: _usernameController,
                  title: 'Name*',
                  hint: "Enter name",
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _emailController,
                  title: 'Email*',
                  hint: "Enter email",
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _passwordController,
                  title: 'Password*',
                  hint: "Enter password",
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value!;
                        });
                      },
                    ),
                    Text(
                      'I agree to the ',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xff827C7C),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Terms Of Service ',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.purple,
                        ),
                      ),
                    ),
                    Text(
                      'and ',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xff827C7C),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Privacy Policy',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.purple,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _isSigning ? null : _signUp, // Prevent double taps
                  child: Container(
                    width: Get.width,
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                    child: _isSigning
                        ? const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          )
                        : Text(
                            'Register',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                                color: Colors.white, fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
