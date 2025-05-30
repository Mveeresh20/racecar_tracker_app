import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:racecar_tracker/Services/profile_details.dart';
import 'package:racecar_tracker/Services/user_service.dart';
import 'package:racecar_tracker/Utils/Constants/images.dart';
import 'package:racecar_tracker/Services/app_constant.dart';

import 'package:firebase_auth/firebase_auth.dart';

class EditProfileProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _hasError = false;

  bool get isLoading => _isLoading;
  bool get hasError => _hasError;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(bool value) {
    _hasError = value;
    notifyListeners();
  }

  FocusNode? firstNameFocusNode;
  TextEditingController firstNameController = TextEditingController();
  String? validateFirstName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name cannot be empty';
    }
    return null;
  }

  FocusNode? lastNameFocusNode;
  TextEditingController? lastNameController = TextEditingController();
  String? validateLastName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Last Name cannot be empty';
    }
    return null;
  }

  FocusNode? emailFocusNode;
  TextEditingController emailTextController = TextEditingController();
  String emailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email cannot be empty';
    } else if (!RegExp(emailRegex).hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  FocusNode? recurrenceNode;
  String? selectedGender;
  String? validateGender(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a gender';
    }
    return null;
  }

  ProfileDetails? _profileDetails;

  ProfileDetails? get profileDetails => _profileDetails;

  set profileDetails(ProfileDetails? value) {
    _profileDetails = value;
    notifyListeners();
  }

  String? _profilePicture = '';

  String? get profilePicture => _profilePicture;

  set profilePicture(String? value) {
    _profilePicture = value;
    notifyListeners();
  }

  // Get the full image URL for display
  String getProfileImageUrl() {
    if (_profilePicture == null || _profilePicture!.isEmpty) {
      return Images.profileImg;
    }
    try {
      // If the profile picture is already a full URL, return it
      if (_profilePicture!.startsWith('http')) {
        return _profilePicture!;
      }
      // Otherwise, construct the URL using the correct base URL
      return "${AppConstant.baseUrlToUploadAndFetchUsersImage}/${_profilePicture!}";
    } catch (e) {
      print("Error getting image URL: $e");
      return Images.profileImg;
    }
  }

  Future<void> updateUserProfile(String imagePath, BuildContext context) async {
    setLoading(true);
    try {
      String? userId = UserService().getCurrentUserId();
      if (userId == null) {
        throw Exception('User is not authenticated');
      }

      // Update in Firebase
      DatabaseReference ref = FirebaseDatabase.instance.ref(
        '478_users/$userId/profileDetails',
      );

      // Store only the relative path (e.g., users/profile/profile_1234567890.jpg)
      await ref.update({'imageProfile': imagePath});

      // Update local state
      profilePicture = imagePath;
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile picture updated successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("Error updating profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error updating profile picture: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setLoading(false);
    }
  }

  Future<String?> fetchUserProfileImage() async {
    String? userId = UserService().getCurrentUserId();
    if (userId != null) {
      DatabaseReference ref = FirebaseDatabase.instance.ref(
        '478_users/$userId/profileDetails',
      );
      DatabaseEvent event = await ref.once();

      DataSnapshot snapshot = event.snapshot;

      final data = snapshot.value;
      if (data is! Map) {
        return null;
      }
      Map<String, dynamic> userData = Map<String, dynamic>.from(data);

      ProfileDetails profileDetails = ProfileDetails.fromMap(userData);

      profilePicture = profileDetails.imageProfile ?? '';
      emailTextController.text = profileDetails.email ?? '';

      // Extract profile details
      firstNameController.text = '${profileDetails.userName}';
      notifyListeners();
      if (snapshot.exists) {
        // Fetch the 'imageProfile' from the snapshot
        log('imageProfile ->1 $profilePicture');

        return snapshot.child('imageProfile').value as String?;
      } else {
        print('User profile not found');
        return null;
      }
    } else {
      print('User is not authenticated');
      return null;
    }
  }

  Future<void> updateUserProfileDetails(BuildContext context) async {
    setLoading(true);

    try {
      String? userId = UserService().getCurrentUserId();
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User is not authenticated')),
        );
        setLoading(false);
        return;
      }

      // Validate gender
      if (selectedGender == null || selectedGender!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a gender'),
            backgroundColor: Colors.red,
          ),
        );
        setLoading(false);
        return;
      }

      // First fetch the existing profile details to get the current image
      DatabaseReference ref = FirebaseDatabase.instance.ref(
        '478_users/$userId/profileDetails',
      );
      DatabaseEvent event = await ref.once();
      DataSnapshot snapshot = event.snapshot;

      String? existingImageProfile;
      if (snapshot.exists) {
        final data = snapshot.value;
        if (data is Map) {
          Map<String, dynamic> userData = Map<String, dynamic>.from(data);
          existingImageProfile = userData['imageProfile'] as String?;
        }
      }

      // Create the profile details object with the existing image OR the current provider image
      var profileDetails = ProfileDetails(
        userName: firstNameController.text,
        email: emailTextController.text,
        gender: selectedGender,
        imageProfile: existingImageProfile ?? profilePicture,
      );

      // Update the user's profile details in Firebase
      await ref.update(profileDetails.toMap());
      setLoading(false);

      // Return to the previous screen with a result of true
      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.grey,
        ),
      );
    } catch (e) {
      setLoading(false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<ProfileDetails?> fetchUserProfileDetails() async {
    try {
      setLoading(true);
      setError(false);

      String? userId = UserService().getCurrentUserId();
      if (userId == null) {
        log('User is not authenticated');
        setLoading(false);
        setError(true);
        return null;
      }

      DatabaseReference ref = FirebaseDatabase.instance.ref(
        '478_users/$userId/profileDetails',
      );
      final event = await ref.once();
      final snapshot = event.snapshot;

      if (!snapshot.exists) {
        log('No profile data found');
        setLoading(false);
        setError(true);
        return null;
      }

      final data = snapshot.value;
      if (data == null || data is! Map) {
        log('Invalid data format');
        setLoading(false);
        setError(true);
        return null;
      }

      Map<String, dynamic> userData = Map<String, dynamic>.from(data);
      profileDetails = ProfileDetails.fromMap(userData);

      firstNameController.text = profileDetails?.userName ?? '';
      emailTextController.text = profileDetails?.email ?? '';
      profilePicture = profileDetails?.imageProfile;

      String? gender = profileDetails?.gender;
      selectedGender = (gender != null && gender.isNotEmpty) ? gender : null;

      setLoading(false);
      return profileDetails;
    } catch (e) {
      log('Error fetching profile details: $e');
      setLoading(false);
      setError(true);
      return null;
    }
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // Optionally clear provider state
    profileDetails = null;
    profilePicture = '';
    firstNameController.clear();
    lastNameController?.clear();
    emailTextController.clear();
    selectedGender = null;
    notifyListeners();
    // Navigate to login/signup
    Navigator.pushNamedAndRemoveUntil(context, '/sign_in', (route) => false);
  }

  /// Update only the user's name and email (no gender required)
  Future<void> updateUserNameAndEmail(
    String name,
    String email,
    BuildContext context,
  ) async {
    setLoading(true);
    try {
      String? userId = UserService().getCurrentUserId();
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User is not authenticated')),
        );
        setLoading(false);
        return;
      }
      DatabaseReference ref = FirebaseDatabase.instance.ref(
        '478_users/$userId/profileDetails',
      );
      await ref.update({'userName': name, 'email': email});
      // Update provider state
      firstNameController.text = name;
      emailTextController.text = email;
      if (_profileDetails != null) {
        _profileDetails!.userName = name;
        _profileDetails!.email = email;
      }
      notifyListeners();
      setLoading(false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.grey,
        ),
      );
    } catch (e) {
      setLoading(false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  void dispose() {
    // Clean up controllers
    firstNameController.dispose();
    lastNameController?.dispose();
    emailTextController.dispose();
    super.dispose();
  }
}
