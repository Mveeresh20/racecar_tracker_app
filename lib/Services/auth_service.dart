import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:racecar_tracker/Presentation/Pages/home_screen.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      print("Sign up error:${e.message}");
      return null;
    }
  }

  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      print("Sign in error: ${e.message}");
      return null;
      
    }
  }

  Future<void> signInAnonymously(BuildContext context) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance.signInAnonymously();
    User? user = userCredential.user;

    if (user != null) {
      print("Signed in anonymously with UID: ${user.uid}");

      // ✅ Navigate to HomeScreen (replace with your actual screen)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  } catch (e) {
    print("Anonymous sign-in failed: $e");
  }
}
Future<UserCredential?> signInWithApple() async {
  
  if (!Platform.isIOS) {
    print("Apple Sign-In is only available on iOS.");
    return null;
  }

  final appleCredential = await SignInWithApple.getAppleIDCredential(
    scopes: [
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName,
    ],
  );

  final oauthCredential = OAuthProvider("apple.com").credential(
    idToken: appleCredential.identityToken,
    accessToken: appleCredential.authorizationCode,
  );

  return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
}



}

