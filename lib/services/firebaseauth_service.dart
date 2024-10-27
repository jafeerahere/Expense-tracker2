import 'package:firebase_auth/firebase_auth.dart';
import 'package:jaff/global/showtoast.dart';
import 'package:jaff/helper/sharedpreference_helper.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      print('Somthing is wrong');
      if (e.code == 'email-already-in-use') {
        showToast(message: 'The Email is already in use');
      } else {
        showToast(message: 'Error has been occured :${e.code}');
      }
    }
    return null;
  }

Future<User?> signInWithEmailAndPassword(String email, String password) async {
  try {
    // Firebase authentication for email and password sign-in
    UserCredential credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    // Return the User object from the UserCredential
    return credential.user;
  } on FirebaseAuthException catch (e) {
    // Handle FirebaseAuthException with specific error codes
    if (e.code == 'user-not-found') {
      showToast(message: 'No user found for that email.');
    } else if (e.code == 'wrong-password') {
      showToast(message: 'Wrong password provided.');
    } else {
      showToast(message: 'An error occurred: ${e.message}');
    }
  } catch (e) {
    // Handle any other errors
    showToast(message: 'An unexpected error occurred. Please try again.');
  }
  
  // Return null if login fails
  return null;
}


  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(PhoneAuthCredential) onVerificationCompleted,
    required void Function(FirebaseAuthException) onVerificationFailed,
    required void Function(String, int?) onCodeSent,
    required void Function(String) onCodeAutoRetrievalTimeout,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: onVerificationCompleted,
        verificationFailed: onVerificationFailed,
        codeSent: onCodeSent,
        codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
      );
    } on FirebaseAuthException catch (e) {
      showToast(message: 'Error occurred: ${e.code}');
    }
  }

 // Logout functionality
   Future<void> logout() async {
    try {
      await _auth.signOut();
      await SharedPreferencesHelper.clearPreferences(); // Clear shared preferences on logout
      showToast(message: 'Successfully logged out.');
    } catch (e) {
      showToast(message: 'Error occurred while logging out: ${e.toString()}');
    }
  }
}
