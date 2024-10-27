import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jaff/auth/signup_screen.dart';
import 'package:jaff/global/custom_textfeild.dart';
import 'package:jaff/helper/sharedpreference_helper.dart';
import 'package:jaff/models/expense_screen.dart';
import 'package:jaff/services/firebaseauth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isSigning = false;

  bool _rememberMe = false;
  bool _obscureNewPassword = true;

  void _toggleNewPasswordVisibility() {
    setState(() {
      _obscureNewPassword = !_obscureNewPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // loginandsignuptitle(
                //   title: 'Welcome Back! 👋',
                // ),
                const SizedBox(
                  height: 30,
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     _loginWith(image: 'assets/loginlogo/google.png'),
                //     _loginWith(image: 'assets/loginlogo/microsoft.png'),
                //     _loginWith(image: 'assets/loginlogo/facebook.png')
                //   ],
                // ),
                const SizedBox(
                  height: 20,
                ),
                // _lineBetweenForm(),
                const SizedBox(
                  height: 20,
                ),
                CustomTextField(
                  controller: _emailController,
                  title: 'Email*',
                  hint: "Enter email",
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Password*',
                        style: GoogleFonts.inter(
                            fontSize: 14, fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureNewPassword
                                  ? Icons.remove_red_eye
                                  : Icons.visibility_off,
                              color: const Color(0xff827C7C),
                            ),
                            onPressed: _toggleNewPasswordVisibility,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xff827C7C),
                              width: 1,
                            ),
                          ),
                          hintStyle: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xff827C7C),
                          ),
                          hintText: 'Enter  Password',
                        ),
                        obscureText: _obscureNewPassword,
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
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
                      'Remember me',
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xff827C7C)),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        // Get.to(const ForgetPassword());
                      },
                      child: Text(
                        'Forget Password?',
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.purple,
                            decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                GestureDetector(
                    onTap: () async {
                      _signIn();
                    },
                    child: Container(
                      width: Get.width,
                      decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.circular(12)),
                      padding:
                          const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                      child: _isSigning
                          ? const Center(
                              child: CircularProgressIndicator(
                              color: Colors.white,
                            ))
                          : Text(
                              'Login',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                  color: Colors.white, fontSize: 16),
                            ),
                    )),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an account yet?',
                      style: GoogleFonts.inter(
                          fontSize: 14, fontWeight: FontWeight.w400),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(const Register());
                      },
                      child: Text(
                        'Sign Up',
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.purple.withOpacity(.5)),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

 void _signIn() async {
    setState(() {
      _isSigning = true;
    });

    String email = _emailController.text;
    String password = _passwordController.text;

    User? user = await _auth.signInWithEmailAndPassword(email, password);

    setState(() {
      _isSigning = false;
    });

    if (user != null) {
      print('User Registered Successfully');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(
          'isNewUser', false); // Set isNewUser to false for returning users
      await SharedPreferencesHelper.setIsLoggedIn(true);
      Get.to(const ExpenseTrackerPage());
    } else {
      print('Wrong Crediential or somthing went wrong');
    }
  }
  Row _lineBetweenForm() {
    return Row(children: <Widget>[
      const Expanded(
          child: Divider(
        thickness: .5,
        color: Color(0xff000000),
      )),
      const SizedBox(
        width: 10,
      ),
      Text(
        "or",
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: const Color(0xff000000),
        ),
      ),
      const SizedBox(
        width: 10,
      ),
      const Expanded(
          child: Divider(
        color: Color(0xff000000),
        thickness: .5,
      )),
    ]);
  }

  Container _loginWith({
    String image = '',
  }) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(.2)),
          borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
      child: Image.asset(image),
    );
  }
}