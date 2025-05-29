import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:racecar_tracker/Presentation/Pages/edit_profile_page.dart';
import 'package:racecar_tracker/Presentation/Pages/upgrade_to_premium_screen.dart';
import 'package:racecar_tracker/Presentation/Widgets/assist_text_theme.dart';
import 'package:racecar_tracker/Utils/Constants/images.dart';
import 'package:racecar_tracker/Utils/theme_extensions.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _imageFile;

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery, // Or ImageSource.camera
      imageQuality: 85,
    );

    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: 24,
              ).copyWith(top: 64, bottom: 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2D5586), Color(0xFF171E45)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF13386B),

                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
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
                      SizedBox(width: 16),
                      Text(
                        "Profile",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  // Space before bottom border
                ],
              ),
            ),

            SizedBox(height: 16),

            Column(
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 3,
                        color: Colors.black.withOpacity(0.2),
                      ),
                    ),
                    child: ClipOval(
                      child:
                          _imageFile != null
                              ? Image.file(
                                _imageFile!,
                                fit: BoxFit.cover,
                                height: 80,
                                width: 80,
                              )
                              : Image.network(
                                Images.profile,
                                fit: BoxFit.cover,
                                height: 80,
                                width: 80,
                              ),
                    ),
                  ),
                ),

                SizedBox(height: 8),
                Text(
                  "John M",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "john@gmail.com",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 18),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFFFCC29),
                    borderRadius: BorderRadius.circular(60),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit, color: Colors.black, size: 16),
                        SizedBox(width: 8),
                        Text(
                          "Edit Profile",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Community",
                      style: context.titleMedium?.copyWith(color: Colors.white),
                    ),
                    SizedBox(height: 8),
                    GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfilePage()));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF13386B),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.edit_outlined, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    "Edit Profile",
                                    style: context.labelMedium?.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                height: 24,
                      
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                      
                                  color: Color(0xFFFFCC29),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.black,
                                    size: 8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      "Your Subscription",
                      style: context.titleMedium?.copyWith(color: Colors.white),
                    ),
                    SizedBox(height: 12),
                    GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => UpgradeToPremiumScreen()));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF13386B),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Image.network(
                                  Images.premiumPurchase,
                                  height: 24,
                                  width: 24,
                                  fit: BoxFit.cover,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Premium Purchase",
                                  style: context.labelMedium?.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              height: 24,

                              decoration: BoxDecoration(
                                shape: BoxShape.circle,

                                color: Color(0xFFFFCC29),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.black,
                                  size: 8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),

                    SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF13386B),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Image.network(
                                  Images.premiumPurchase,
                                  height: 24,
                                  width: 24,
                                  fit: BoxFit.cover,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Restore Purchase",
                                  style: context.labelMedium?.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              height: 24,

                              decoration: BoxDecoration(
                                shape: BoxShape.circle,

                                color: Color(0xFFFFCC29),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.black,
                                  size: 8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 24),

                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF13386B),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16,).copyWith(top:16 ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(60),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete,
                                      color: Colors.black,
                                      size: 16,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "Delete Account",
                                      style: context.labelMedium?.copyWith(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal:  16).copyWith(bottom: 16),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFFE5555),
                                borderRadius: BorderRadius.circular(60),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Icon(Icons.logout, color: Colors.white, size: 16),
                                    SizedBox(width: 8),
                                    Text(
                                      "Log out",
                                      style: context.labelMedium?.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            
          ],
        ),
      ),
    );
  }
}
