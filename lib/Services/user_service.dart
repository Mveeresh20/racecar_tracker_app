import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  // Method to get the current user's ID
  String? getCurrentUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  
}