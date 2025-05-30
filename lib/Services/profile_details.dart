import 'package:firebase_auth/firebase_auth.dart';


class ProfileDetails {
  String? userName;
  String? email;
  String? gender;
  String? imageProfile;

  ProfileDetails({
    this.userName,
    this.email,
    this.gender,
    this.imageProfile,
  });

 
  ProfileDetails.fromMap(Map<String, dynamic> map) {
    userName = map['userName'];
    email = map['email'];
    gender = map['gender'];
    imageProfile = map['imageProfile'];
  }

 
  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'email': email,
      'gender': gender,
      'imageProfile': imageProfile,
    };
  }
}

// 2. UserService Class

