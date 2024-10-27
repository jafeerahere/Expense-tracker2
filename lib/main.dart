import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaff/auth/login_screen.dart';
import 'package:jaff/auth/signup_screen.dart';
import 'package:jaff/helper/sharedpreference_helper.dart';
import 'package:jaff/models/expense_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp();
    print('Firebase initialized successfully');
  } catch (e) {
    print('Error initializing Firebase: $e');
    return; // Exit if Firebase initialization fails
  }

  // Check login state using SharedPreferencesHelper
  bool isLoggedIn = await SharedPreferencesHelper.getIsLoggedIn();

  // Run the app and pass the login status
  runApp(ExpenseTrackerApp(isLoggedIn: isLoggedIn));
}

class ExpenseTrackerApp extends StatelessWidget {
  final bool isLoggedIn;

  const ExpenseTrackerApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Expense Tracker',
      initialRoute: isLoggedIn ? '/home' : '/login', // Decide initial route based on login state
      getPages: [
        GetPage(name: '/login', page: () => const Login()),
        GetPage(name: '/signup', page: () => const Register()),
        GetPage(name: '/home', page: () => const ExpenseTrackerPage()), // Assuming this is the home page
      ],
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'BreeSerif', // Set your font family here
      ),
    );
  }
}
