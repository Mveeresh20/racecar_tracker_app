import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:racecar_tracker/Services/edit_profile_provider.dart';
import 'package:racecar_tracker/Services/image_picker_util.dart';
import 'package:racecar_tracker/Utils/Constants/image_path.dart';
import 'package:racecar_tracker/Utils/Constants/images.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final EditProfileProvider _provider;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _provider = EditProfileProvider();
    _loadUserProfile();
  }

  Future<void> _initializeData() async {
    await _provider.fetchUserProfileDetails();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
    _nameController.dispose();
    _emailController.dispose();
  }

  Future<void> _loadUserProfile() async {
    final provider = Provider.of<EditProfileProvider>(context, listen: false);
    await provider.fetchUserProfileDetails();
    setState(() {
      _nameController.text = provider.profileDetails?.userName ?? '';
      _emailController.text = provider.profileDetails?.email ?? '';
    });
  }

  Future<void> _pickImage() async {
    final provider = Provider.of<EditProfileProvider>(context, listen: false);

    ImagePickerUtil().showImageSourceSelection(
      context,
      (String imagePath) async {
        // Success callback
        await provider.updateUserProfile(imagePath, context);
        setState(() {
          _imageFile =
              null; // Clear local file since we're using the uploaded path
        });
      },
      (String error) {
        // Error callback
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2D5586), Color(0xFF171E45)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF13386B),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 10,
                          ),
                          child: Icon(
                            Icons.home,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        "Edit Profile",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Profile Image
                Center(
                  child: Stack(
                    children: [
                      Center(
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          // Align the edit icon at the bottom-right
                          children: [
                            // Profile Image (centered)
                            InkWell(
                              onTap: () {
                                ImagePickerUtil().showImageSourceSelection(
                                  context,
                                  (responseBody) async {
                                    print("Upload Success: $responseBody");
                                    await _provider.updateUserProfile(
                                      responseBody,
                                      context,
                                    );
                                    // setState(() {
                                    //   _provider.profilePicture = responseBody;
                                    // });
                                  },
                                  (error) {
                                    print("Upload Failed: $error");
                                  },
                                );
                              },
                              child: Container(
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Align(
                                      alignment: const AlignmentDirectional(
                                        0.0,
                                        0.0,
                                      ),
                                      child: Container(
                                        width: 127.0,
                                        height: 127.0,
                                        decoration:
                                            (_provider.profilePicture != null &&
                                                    _provider
                                                        .profilePicture!
                                                        .isNotEmpty)
                                                ? BoxDecoration(
                                                  image: DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: CachedNetworkImageProvider(
                                                      ImagePickerUtil()
                                                          .getUrlForUserUploadedImage(
                                                            _provider
                                                                .profilePicture!,
                                                          ),
                                                    ),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        150.0,
                                                      ),
                                                )
                                                : BoxDecoration(
                                                  image: const DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: AssetImage(
                                                      ImagePath.profile,
                                                    ),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        59.0,
                                                      ),
                                                ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Edit Icon
                            Positioned(
                              bottom: 0, // Distance from the bottom
                              right: 0,
                              child: Container(
                                width: 36.0,
                                height: 36.0,
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(99),
                                  border: Border.all(
                                    color: Colors.white, // Border color
                                  ),
                                ),
                                child: GestureDetector(
                                  onTap: () async {
                                    ImagePickerUtil().showImageSourceSelection(
                                      context,
                                      (responseBody) async {
                                        print("Upload Success: $responseBody");
                                        await _provider.updateUserProfile(
                                          responseBody,
                                          context,
                                        );
                                      },
                                      (error) {
                                        print("Upload Failed: $error");
                                      },
                                    );
                                  }, // Open image picker when clicked
                                  child: Icon(
                                    Icons.edit,
                                    size: 24,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Positioned(
                      //   right: 0,
                      //   bottom: 0,
                      //   child: Container(
                      //     padding: const EdgeInsets.all(8),
                      //     decoration: const BoxDecoration(
                      //       color: Color(0xFFFFCC29),
                      //       shape: BoxShape.circle,
                      //     ),
                      //     child: const Icon(
                      //       Icons.edit,
                      //       color: Colors.black,
                      //       size: 16,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Form Fields
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Name",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF13386B),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          style: const TextStyle(color: Colors.white),
                          controller: _nameController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(8),
                            hintText: "Enter your name",
                            hintStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        "Email/Phone number",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF13386B),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          style: const TextStyle(color: Colors.white),
                          controller: _emailController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(8),
                            hintText: "Enter your email",
                            hintStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Update Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: Consumer<EditProfileProvider>(
                      builder: (context, provider, child) {
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFCC29),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(60),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          onPressed:
                              provider.isLoading
                                  ? null
                                  : () async {
                                    await provider.updateUserNameAndEmail(
                                      _nameController.text,
                                      _emailController.text,
                                      context,
                                    );
                                  },
                          child:
                              provider.isLoading
                                  ? const CircularProgressIndicator()
                                  : const Text(
                                    "Update Profile",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                        );
                      },
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
