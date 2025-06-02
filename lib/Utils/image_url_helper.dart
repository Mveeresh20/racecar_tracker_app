// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:racecar_tracker/Services/app_constant.dart';

// class ImageUrlHelper {
//   /// Returns the full URL for an image given its relative path
//   static String getFullImageUrl(String? relativePath) {
//     if (relativePath == null || relativePath.isEmpty) {
//       print('ImageUrlHelper: Empty or null path provided');
//       return '';
//     }

//     // If it's already a full URL, return as is
//     if (relativePath.startsWith('http')) {
//       print('ImageUrlHelper: Full URL provided: $relativePath');
//       return relativePath;
//     }

//     // If it's a local file path, return as is
//     if (relativePath.startsWith('/') || relativePath.startsWith('file://')) {
//       print('ImageUrlHelper: Local file path provided: $relativePath');
//       return relativePath;
//     }

//     // Remove any leading slashes and clean the path
//     String cleanPath =
//         relativePath.startsWith('/') ? relativePath.substring(1) : relativePath;

//     // Remove any old path structures if present
//     cleanPath = cleanPath
//         .replaceAll('racers/profile/', '')
//         .replaceAll('racers/vehicle/', '')
//         .replaceAll('478/', ''); // Remove any test bundle prefix

//     // Ensure the path starts with 'images/'
//     if (!cleanPath.startsWith('images/')) {
//       cleanPath = 'images/$cleanPath';
//     }

//     // Production URL structure: https://d1r9c4nksnam33.cloudfront.net/images/[filename]
//     final fullUrl = '${AppConstant.baseUrl}$cleanPath';
//     print('ImageUrlHelper: Constructed URL: $fullUrl');
//     return fullUrl;
//   }

//   /// Returns a widget that can display either a network image or a local file
//   static Widget getImageWidget({
//     required String? imagePath,
//     double? width,
//     double? height,
//     BoxFit fit = BoxFit.cover,
//     Widget? placeholder,
//     Widget? errorWidget,
//   }) {
//     if (imagePath == null || imagePath.isEmpty) {
//       print(
//         'ImageUrlHelper: Empty or null imagePath provided to getImageWidget',
//       );
//       return _buildErrorWidget(width, height, errorWidget);
//     }

//     // Handle local files
//     if (imagePath.startsWith('/') || imagePath.startsWith('file://')) {
//       try {
//         return Image.file(
//           File(imagePath),
//           width: width,
//           height: height,
//           fit: fit,
//           errorBuilder: (context, error, stackTrace) {
//             print('ImageUrlHelper: Error loading local image: $error');
//             return _buildErrorWidget(width, height, errorWidget);
//           },
//         );
//       } catch (e) {
//         print('ImageUrlHelper: Error processing local image: $e');
//         return _buildErrorWidget(width, height, errorWidget);
//       }
//     }

//     // Handle network images with caching
//     final fullUrl = getFullImageUrl(imagePath);
//     print('ImageUrlHelper: Loading network image from URL: $fullUrl');

//     return CachedNetworkImage(
//       imageUrl: fullUrl,
//       width: width,
//       height: height,
//       fit: fit,
//       placeholder:
//           (context, url) =>
//               placeholder ??
//               const Center(
//                 child: CircularProgressIndicator(
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                 ),
//               ),
//       errorWidget: (context, url, error) {
//         print(
//           'ImageUrlHelper: Error loading network image: $error for URL: $url',
//         );
//         return _buildErrorWidget(width, height, errorWidget);
//       },
//     );
//   }

//   static Widget _buildErrorWidget(
//     double? width,
//     double? height,
//     Widget? errorWidget,
//   ) {
//     return Container(
//       width: width,
//       height: height,
//       color: Colors.grey[800],
//       child:
//           errorWidget ??
//           const Center(
//             child: Icon(Icons.error_outline, color: Colors.white54, size: 24),
//           ),
//     );
//   }
// }
