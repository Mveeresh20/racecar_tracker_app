import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:path/path.dart'; // For extracting the file name
import 'package:http/http.dart' as http;
import 'package:racecar_tracker/Services/app_constant.dart';
import 'package:racecar_tracker/Services/compress_image_params.dart';

class ImagePickerUtil {
  String uploadedFileUrl = '';
  final ImagePicker _picker = ImagePicker();
  final String _fileName = '';
  File? file;

  String getImageUrl(String imageName) {
    return "${AppConstant.baseUrlToFetchStaticImage}images/$imageName";
  }

  void showImageSourceSelection(
    BuildContext context,
    Function(String) onUploadSuccess, // Pass callback for success
    Function(String) onUploadFailure,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop(); // Close the bottom sheet
                  _pickImageFromGallery(
                    context,
                    onUploadSuccess,
                    onUploadFailure,
                  ); // Pass callbacks
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop(); // Close the bottom sheet
                  _pickImageFromCamera(
                    context,
                    onUploadSuccess,
                    onUploadFailure,
                  ); // Pass callbacks
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromGallery(
    BuildContext context,
    Function(String) onUploadSuccess, // Callback for success
    Function(String) onUploadFailure,
  ) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      file = File(image.path);
      debugPrint("Original image picked: ${image.path}");

      // Compress the image before showing preview
      try {
        file = await pickAndCompressImage(file!);
        debugPrint("Image compressed: ${file!.path}");
        await _showImagePreviewDialog(
          context,
          file!,
          onUploadSuccess,
          onUploadFailure,
        );
      } catch (e) {
        debugPrint("Error compressing image: $e");
        onUploadFailure("Error compressing image: $e");
      }
    }
  }

  /// Function to capture image using camera
  Future<void> _pickImageFromCamera(
    BuildContext context,
    Function(String) onUploadSuccess, // Callback for success
    Function(String) onUploadFailure,
  ) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      file = File(image.path);
      debugPrint("Original image captured: ${image.path}");

      // Compress the image before showing preview
      try {
        file = await pickAndCompressImage(file!);
        debugPrint("Image compressed: ${file!.path}");
        await _showImagePreviewDialog(
          context,
          file!,
          onUploadSuccess,
          onUploadFailure,
        );
      } catch (e) {
        debugPrint("Error compressing image: $e");
        onUploadFailure("Error compressing image: $e");
      }
    }
  }

  // Method to generate the signed URL
  Future<String?> getSignedUrl(String fileName, String bundle) async {
    String url = AppConstant.baseUrlForUploadPostApi;
    uploadedFileUrl = fileName;
    log('uploadedFileUrl -> ${url + uploadedFileUrl}');
    final Map<String, String> payload = {
      'fileName': fileName,
      'bundle': bundle,
    };

    final String jsonPayload = json.encode(payload);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonPayload,
      );

      if (response.statusCode == 200) {
        log('getSignedUrl Request successful: ${response.body}');
        Map map = json.decode(response.body);
        if (map.containsKey("data")) {
          String signedUrl = map['data'];
          return signedUrl;
        }
      } else {
        log(
          'getSignedUrl Failed request: ${response.statusCode} : ${response.body}',
        );
      }
    } catch (e) {
      log('getSignedUrl Error: $e');
    }
    return null;
  }

  // Upload file with callbacks
  Future<void> uploadFileToS3WithCallback(
    String signedUrl,
    String filePath,
    BuildContext context,
    Function(String) onUploadSuccess, // Success callback
    Function(String) onUploadFailure, // Failure callback
  ) async {
    try {
      final file = File(filePath);

      if (await file.exists()) {
        final fileBytes = await file.readAsBytes();

        final response = await http.put(
          Uri.parse(signedUrl),
          headers: {
            'Content-Type': 'application/octet-stream',
            'Content-Length': fileBytes.length.toString(),
          },
          body: fileBytes,
        );

        log("File uploaded response: ${response.body}");

        if (response.statusCode == 200) {
          onUploadSuccess(uploadedFileUrl); // Pass the filename to the callback
          // onUploadSuccess(_fileName);  // Pass the filename to the callback
        } else {
          onUploadFailure(
            'Failed to upload file: ${response.statusCode}',
          ); // Call failure callback
        }
      } else {
        onUploadFailure(
          'File not found at the specified path',
        ); // Failure callback
      }
    } catch (e) {
      onUploadFailure('Error uploading file: $e'); // Failure callback
    }
  }

  // URL for the uploaded image
  String getUrlForUserUploadedImage(String postFilePath) {
    if (postFilePath.startsWith("/")) {
      return AppConstant.baseUrlToUploadAndFetchUsersImage + postFilePath;
    }
    return "${AppConstant.baseUrlToUploadAndFetchUsersImage}/$postFilePath";
  }

  Future<void> _showImagePreviewDialog(
    BuildContext context,
    File imageFile,
    Function(String) onUploadSuccess, // Callback for success
    Function(String) onUploadFailure,
  ) async {
    bool loading = false;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  imageFile,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  frameBuilder: (
                    context,
                    child,
                    frame,
                    wasSynchronouslyLoaded,
                  ) {
                    if (frame != null || wasSynchronouslyLoaded) {
                      return child;
                    }
                    return const CircularProgressIndicator.adaptive();
                  },
                  height: 200,
                  width: 300,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
          actions: [
            // Cancel Button
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
              child: const Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
            // Upload Button
            StatefulBuilder(
              builder: (context, state) {
                return loading
                    ? Container(
                      width: 50,
                      height: 50,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator.adaptive(),
                    )
                    : ElevatedButton(
                      style: const ButtonStyle(
                        // backgroundColor:  color1,
                      ),
                      onPressed: () async {
                        // Create a structured path for the image
                        String timestamp =
                            DateTime.now().millisecondsSinceEpoch.toString();
                        String fileName =
                            'profile_$timestamp${extension(imageFile.path)}';
                        // Use the correct folder structure: users/profile/filename
                        String structuredPath = 'users/profile/$fileName';

                        try {
                          print("Structured path: $structuredPath");
                          if (structuredPath.isNotEmpty) {
                            state(() {
                              loading = true;
                            });
                            String? url = await getSignedUrl(
                              structuredPath,
                              AppConstant.bundleNameForPostAPI,
                            );
                            if (url != null && url.isNotEmpty && file != null) {
                              uploadFileToS3WithCallback(
                                url,
                                file!.path,
                                context,
                                onUploadSuccess,
                                onUploadFailure,
                              );
                              state(() {
                                loading = false;
                              });
                              Navigator.maybePop(dialogContext);
                            }
                          }
                        } catch (e) {
                          state(() {
                            loading = false;
                          });
                          onUploadFailure("Error uploading image: $e");
                        }
                      },
                      child: const Text(
                        "Upload",
                        style: TextStyle(color: Colors.black),
                      ),
                    );
              },
            ),
          ],
        );
      },
    );
  }
}

class ImagePickerUtilForPst {
  String uploadedFileUrl = '';
  final ImagePicker _picker = ImagePicker();
  String _fileName = '';
  File? file;

  // Modify this method to accept callbacks for success and failure
  Future<void> _pickImageFromGallery(
    BuildContext context,
    Function(String) onUploadSuccess, // Callback for success
    Function(String) onUploadFailure, // Callback for failure
  ) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      file = File(image.path);

      // Generate a unique file name using current date and time
      String uniqueFileName =
          'IMG_Profile_${DateTime.now().millisecondsSinceEpoch}${extension(image.path)}';

      // Update the file name
      log("Original File Name: ${basename(image.path)}");

      _fileName = uniqueFileName;

      if (_fileName.isNotEmpty) {
        String? url = await getSignedUrl(
          _fileName,
          AppConstant.bundleNameForPostAPI,
        );
        if (url != null && url.isNotEmpty && file != null) {
          uploadFileToS3WithCallback(
            url,
            file!.path,
            context,
            onUploadSuccess,
            onUploadFailure,
          );
        }
      }
    }
  }

  /// Function to capture image using camera
  Future<void> _pickImageFromCamera(
    BuildContext context,
    Function(String) onUploadSuccess, // Callback for success
    Function(String) onUploadFailure, // Callback for failure
  ) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      file = File(image.path);

      // Generate a unique file name using current date and time
      String uniqueFileName =
          'IMG_Profile_${DateTime.now().millisecondsSinceEpoch}${extension(image.path)}';

      log("Original File Name: ${basename(image.path)}");
      log("Unique File Name: $uniqueFileName");

      _fileName = uniqueFileName;
      log('_fileName  ====> $_fileName');
      if (_fileName.isNotEmpty) {
        String? url = await getSignedUrl(
          _fileName,
          AppConstant.bundleNameForPostAPI,
        );
        if (url != null && url.isNotEmpty && file != null) {
          uploadFileToS3WithCallback(
            url,
            file!.path,
            context,
            onUploadSuccess,
            onUploadFailure,
          );
        }
      }
    }
  }

  void showImageSourceSelection(
    BuildContext context,
    Function(String) onUploadSuccess, // Pass callback for success
    Function(String) onUploadFailure, // Pass callback for failure
  ) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop(); // Close the bottom sheet
                  _pickImageFromGallery(
                    context,
                    onUploadSuccess,
                    onUploadFailure,
                  ); // Pass callbacks
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop(); // Close the bottom sheet
                  _pickImageFromCamera(
                    context,
                    onUploadSuccess,
                    onUploadFailure,
                  ); // Pass callbacks
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Method to generate the signed URL
  Future<String?> getSignedUrl(String fileName, String bundle) async {
    String url = AppConstant.baseUrlForUploadPostApi;
    uploadedFileUrl = fileName;
    log('uploadedFileUrl -> ${url + uploadedFileUrl}');
    final Map<String, String> payload = {
      'fileName': fileName,
      'bundle': bundle,
    };

    final String jsonPayload = json.encode(payload);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonPayload,
      );

      if (response.statusCode == 200) {
        log('getSignedUrl Request successful: ${response.body}');
        Map map = json.decode(response.body);
        if (map.containsKey("data")) {
          String signedUrl = map['data'];
          return signedUrl;
        }
      } else {
        log(
          'getSignedUrl Failed request: ${response.statusCode} : ${response.body}',
        );
      }
    } catch (e) {
      log('getSignedUrl Error: $e');
    }
    return null;
  }

  // Upload file with callbacks
  Future<void> uploadFileToS3WithCallback(
    String signedUrl,
    String filePath,
    BuildContext context,
    Function(String) onUploadSuccess, // Success callback
    Function(String) onUploadFailure, // Failure callback
  ) async {
    try {
      final file = File(filePath);

      if (await file.exists()) {
        final fileBytes = await file.readAsBytes();

        final response = await http.put(
          Uri.parse(signedUrl),
          headers: {
            'Content-Type': 'application/octet-stream',
            'Content-Length': fileBytes.length.toString(),
          },
          body: fileBytes,
        );

        log("File uploaded response: ${response.body}");

        if (response.statusCode == 200) {
          log('File uploaded successfully!');
          onUploadSuccess(uploadedFileUrl); // Pass the filename to the callback
          // onUploadSuccess(_fileName);  // Pass the filename to the callback

          // onUploadSuccess(response.body); // Call success callback with response body
        } else {
          log(
            'Failed to upload file: ${response.statusCode} : ${response.body}',
          );
          onUploadFailure(
            'Failed to upload file: ${response.statusCode}',
          ); // Call failure callback
        }
      } else {
        log('File not found at the specified path: $filePath');
        onUploadFailure(
          'File not found at the specified path',
        ); // Failure callback
      }
    } catch (e) {
      log('Error uploading file: $e');
      onUploadFailure('Error uploading file: $e'); // Failure callback
    }
  }

  // URL for the uploaded image
  String getUrlForUserUploadedImage(String postFilePath) {
    if (postFilePath.startsWith("/")) {
      return AppConstant.baseUrlToUploadAndFetchUsersImage + postFilePath;
    }
    return "${AppConstant.baseUrlToUploadAndFetchUsersImage}/$postFilePath";
  }
}

// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// import 'package:path/path.dart'; // For extracting the file name
// import 'package:http/http.dart' as http;
// import 'package:racecar_tracker/Services/app_constant.dart';
// import 'package:racecar_tracker/Services/compress_image_params.dart';
// import 'package:racecar_tracker/Services/image_service.dart';

// class ImagePickerUtil {
//   static final ImagePicker _picker = ImagePicker();

//   static Future<void> showImageSourceSelection(
//     BuildContext context,
//     Function(String) onImageSelected,
//   ) async {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return SafeArea(
//           child: Wrap(
//             children: <Widget>[
//               ListTile(
//                 leading: const Icon(Icons.photo_library),
//                 title: const Text('Gallery'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _pickImageFromGallery(context, onImageSelected);
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.photo_camera),
//                 title: const Text('Camera'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _pickImageFromCamera(context, onImageSelected);
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   static Future<void> _pickImageFromGallery(
//     BuildContext context,
//     Function(String) onImageSelected,
//   ) async {
//     try {
//       final XFile? image = await _picker.pickImage(
//         source: ImageSource.gallery,
//         maxWidth: 1024,
//         maxHeight: 1024,
//         imageQuality: 85,
//       );

//       if (image != null) {
//         final File imageFile = File(image.path);
//         _showImagePreviewDialog(context, imageFile, onImageSelected);
//       }
//     } catch (e) {
//       print("Error picking image from gallery: $e");
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Error selecting image')));
//     }
//   }

//   static Future<void> _pickImageFromCamera(
//     BuildContext context,
//     Function(String) onImageSelected,
//   ) async {
//     try {
//       final XFile? image = await _picker.pickImage(
//         source: ImageSource.camera,
//         maxWidth: 1024,
//         maxHeight: 1024,
//         imageQuality: 85,
//       );

//       if (image != null) {
//         final File imageFile = File(image.path);
//         _showImagePreviewDialog(context, imageFile, onImageSelected);
//       }
//     } catch (e) {
//       print("Error picking image from camera: $e");
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Error taking photo')));
//     }
//   }

//   static Future<void> _showImagePreviewDialog(
//     BuildContext context,
//     File imageFile,
//     Function(String) onImageSelected,
//   ) async {
//     bool isUploading = false;

//     await showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               title: const Text('Preview Image'),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(8),
//                     child: Image.file(
//                       imageFile,
//                       height: 200,
//                       width: 200,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                   if (isUploading)
//                     const Padding(
//                       padding: EdgeInsets.only(top: 16),
//                       child: CircularProgressIndicator(),
//                     ),
//                 ],
//               ),
//               actions: [
//                 TextButton(
//                   onPressed:
//                       isUploading
//                           ? null
//                           : () {
//                             Navigator.of(context).pop();
//                           },
//                   child: const Text('Cancel'),
//                 ),
//                 TextButton(
//                   onPressed:
//                       isUploading
//                           ? null
//                           : () async {
//                             setState(() {
//                               isUploading = true;
//                             });

//                             try {
//                               // Get user ID from your auth service
//                               final userId =
//                                   "current_user_id"; // Replace with actual user ID
//                               final imagePath =
//                                   await ImageService.uploadUserProfileImage(
//                                     imageFile,
//                                     userId,
//                                   );

//                               if (imagePath != null) {
//                                 Navigator.of(context).pop();
//                                 onImageSelected(imagePath);
//                               } else {
//                                 throw Exception('Failed to upload image');
//                               }
//                             } catch (e) {
//                               print("Error uploading image: $e");
//                               if (context.mounted) {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(
//                                     content: Text(
//                                       'Failed to upload image. Please try again.',
//                                     ),
//                                     duration: Duration(seconds: 3),
//                                   ),
//                                 );
//                               }
//                             } finally {
//                               if (context.mounted) {
//                                 setState(() {
//                                   isUploading = false;
//                                 });
//                               }
//                             }
//                           },
//                   child: const Text('Upload'),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
// }

// class ImagePickerUtilForPst {
//   String uploadedFileUrl = '';
//   final ImagePicker _picker = ImagePicker();
//   String _fileName = '';
//   File? file;

//   // Modify this method to accept callbacks for success and failure
//   Future<void> _pickImageFromGallery(
//     BuildContext context,
//     Function(String) onUploadSuccess, // Callback for success
//     Function(String) onUploadFailure, // Callback for failure
//   ) async {
//     final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

//     if (image != null) {
//       file = File(image.path);

//       // Generate a unique file name using current date and time
//       String uniqueFileName =
//           'IMG_Profile_${DateTime.now().millisecondsSinceEpoch}${extension(image.path)}';

//       // Update the file name
//       log("Original File Name: ${basename(image.path)}");

//       _fileName = uniqueFileName;

//       if (_fileName.isNotEmpty) {
//         String? url = await getSignedUrl(
//           _fileName,
//           AppConstant.bundleNameForPostAPI,
//         );
//         if (url != null && url.isNotEmpty && file != null) {
//           uploadFileToS3WithCallback(
//             url,
//             file!.path,
//             context,
//             onUploadSuccess,
//             onUploadFailure,
//           );
//         }
//       }
//     }
//   }

//   /// Function to capture image using camera
//   Future<void> _pickImageFromCamera(
//     BuildContext context,
//     Function(String) onUploadSuccess, // Callback for success
//     Function(String) onUploadFailure, // Callback for failure
//   ) async {
//     final XFile? image = await _picker.pickImage(source: ImageSource.camera);
//     if (image != null) {
//       file = File(image.path);

//       // Generate a unique file name using current date and time
//       String uniqueFileName =
//           'IMG_Profile_${DateTime.now().millisecondsSinceEpoch}${extension(image.path)}';

//       log("Original File Name: ${basename(image.path)}");
//       log("Unique File Name: $uniqueFileName");

//       _fileName = uniqueFileName;
//       log('_fileName  ====> $_fileName');
//       if (_fileName.isNotEmpty) {
//         String? url = await getSignedUrl(
//           _fileName,
//           AppConstant.bundleNameForPostAPI,
//         );
//         if (url != null && url.isNotEmpty && file != null) {
//           uploadFileToS3WithCallback(
//             url,
//             file!.path,
//             context,
//             onUploadSuccess,
//             onUploadFailure,
//           );
//         }
//       }
//     }
//   }

//   void showImageSourceSelection(
//     BuildContext context,
//     Function(String) onUploadSuccess, // Pass callback for success
//     Function(String) onUploadFailure, // Pass callback for failure
//   ) {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext ctx) {
//         return SafeArea(
//           child: Wrap(
//             children: <Widget>[
//               ListTile(
//                 leading: const Icon(Icons.photo_library),
//                 title: const Text('Gallery'),
//                 onTap: () {
//                   Navigator.of(context).pop(); // Close the bottom sheet
//                   _pickImageFromGallery(
//                     context,
//                     onUploadSuccess,
//                     onUploadFailure,
//                   ); // Pass callbacks
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.photo_camera),
//                 title: const Text('Camera'),
//                 onTap: () {
//                   Navigator.of(context).pop(); // Close the bottom sheet
//                   _pickImageFromCamera(
//                     context,
//                     onUploadSuccess,
//                     onUploadFailure,
//                   ); // Pass callbacks
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // Method to generate the signed URL
//   Future<String?> getSignedUrl(String fileName, String bundle) async {
//     final url = AppConstant.uploadEndpoint;
//     uploadedFileUrl = fileName;
//     log('uploadedFileUrl -> ${url + uploadedFileUrl}');
//     final Map<String, String> payload = {
//       'fileName': fileName,
//       'bundle': bundle,
//     };

//     final String jsonPayload = json.encode(payload);

//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonPayload,
//       );

//       if (response.statusCode == 200) {
//         log('getSignedUrl Request successful: ${response.body}');
//         Map map = json.decode(response.body);
//         if (map.containsKey("data")) {
//           String signedUrl = map['data'];
//           return signedUrl;
//         }
//       } else {
//         log(
//           'getSignedUrl Failed request: ${response.statusCode} : ${response.body}',
//         );
//       }
//     } catch (e) {
//       log('getSignedUrl Error: $e');
//     }
//     return null;
//   }

//   // Upload file with callbacks
//   Future<void> uploadFileToS3WithCallback(
//     String signedUrl,
//     String filePath,
//     BuildContext context,
//     Function(String) onUploadSuccess, // Success callback
//     Function(String) onUploadFailure, // Failure callback
//   ) async {
//     try {
//       final file = File(filePath);

//       if (await file.exists()) {
//         final fileBytes = await file.readAsBytes();

//         final response = await http.put(
//           Uri.parse(signedUrl),
//           headers: {
//             'Content-Type': 'application/octet-stream',
//             'Content-Length': fileBytes.length.toString(),
//           },
//           body: fileBytes,
//         );

//         log("File uploaded response: ${response.body}");

//         if (response.statusCode == 200) {
//           log('File uploaded successfully!');
//           onUploadSuccess(uploadedFileUrl); // Pass the filename to the callback
//           // onUploadSuccess(_fileName);  // Pass the filename to the callback

//           // onUploadSuccess(response.body); // Call success callback with response body
//         } else {
//           log(
//             'Failed to upload file: ${response.statusCode} : ${response.body}',
//           );
//           onUploadFailure(
//             'Failed to upload file: ${response.statusCode}',
//           ); // Call failure callback
//         }
//       } else {
//         log('File not found at the specified path: $filePath');
//         onUploadFailure(
//           'File not found at the specified path',
//         ); // Failure callback
//       }
//     } catch (e) {
//       log('Error uploading file: $e');
//       onUploadFailure('Error uploading file: $e'); // Failure callback
//     }
//   }

//   // URL for the uploaded image
//   // String getUrlForUserUploadedImage(String postFilePath) {
//   //   if (postFilePath.startsWith("/")) {
//   //     return AppConstant.baseUrlToUploadAndFetchUsersImage + postFilePath;
//   //   }
//   //   return "${AppConstant.baseUrlToUploadAndFetchUsersImage}/$postFilePath";
//   // }
// }
