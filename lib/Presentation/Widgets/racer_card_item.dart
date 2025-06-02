// import 'package:flutter/material.dart';
// import 'package:racecar_tracker/Presentation/Pages/racer_details_screen.dart';
// import 'package:racecar_tracker/Utils/Constants/app_constants.dart';
// import 'package:racecar_tracker/Utils/theme_extensions.dart';
// import 'package:racecar_tracker/models/racer.dart';
// import 'package:racecar_tracker/models/deal_item.dart'; // Import DealItem model
// import 'dart:io';
// import 'package:cached_network_image/cached_network_image.dart';
// // Import the new screen

// class RacerCardItem extends StatelessWidget {
//   final Racer racer;
//   // This callback function will be used to get specific deals for a racer
//   final List<DealItem> Function(String racerName) getDealItemsForRacer;

//   const RacerCardItem({
//     Key? key,
//     required this.racer,
//     required this.getDealItemsForRacer, // Receive the callback
//   }) : super(key: key);

//   // Reusing the _buildActionButton for consistency
//   Widget _buildActionButton(IconData icon, VoidCallback onPressed) {
//     return InkWell(
//       onTap: onPressed,
//       borderRadius: BorderRadius.circular(8), // Match design from screenshots
//       child: Container(
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
//           gradient: const LinearGradient(
//             colors: [
//               Color(0xFF8B6AD2),
//               Color(0xFF211E83),
//             ], // Gradient from screenshots
//           ),
//         ),
//         child: Icon(icon, color: Colors.white, size: 20),
//       ),
//     );
//   }

//   Widget _buildRacerAvatar(Racer racer) {
//     if (racer.racerImageUrl != null && racer.racerImageUrl!.isNotEmpty) {
//       return Container(
//         width: 40,
//         height: 40,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(8),
//           color: const Color(0xFF252D38).withOpacity(0.8),
//           border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(8),
//           child:
//               racer.isLocalRacerImage
//                   ? _buildLocalImage(racer.racerImageUrl!)
//                   : CachedNetworkImage(
//                     imageUrl: racer.racerImageUrl!,
//                     fit: BoxFit.cover,
//                     width: 40,
//                     height: 40,
//                     placeholder:
//                         (context, url) =>
//                             _buildInitialsContainer(racer.initials),
//                     errorWidget:
//                         (context, url, error) =>
//                             _buildInitialsContainer(racer.initials),
//                   ),
//         ),
//       );
//     } else {
//       return _buildInitialsContainer(racer.initials);
//     }
//   }

//   Widget _buildLocalImage(String imagePath) {
//     try {
//       // Remove 'file://' prefix if present and handle the path properly
//       final cleanPath = imagePath.replaceAll('file://', '');
//       final file = File(cleanPath);

//       if (file.existsSync()) {
//         return Image.file(
//           file,
//           fit: BoxFit.cover,
//           width: 40,
//           height: 40,
//           errorBuilder: (context, error, stackTrace) {
//             print('Error loading local image: $error');
//             return _buildInitialsContainer(racer.initials);
//           },
//         );
//       } else {
//         print('File does not exist: $cleanPath');
//         return _buildInitialsContainer(racer.initials);
//       }
//     } catch (e) {
//       print('Error processing local image: $e');
//       return _buildInitialsContainer(racer.initials);
//     }
//   }

//   Widget _buildVehicleImage(Racer racer) {
//     if (racer.vehicleImageUrl == null || racer.vehicleImageUrl!.isEmpty) {
//       return Container(
//         height: 120,
//         width: double.infinity,
//         color: Colors.grey[800],
//         child: const Icon(Icons.directions_car, color: Colors.white, size: 40),
//       );
//     }

//     return ClipRRect(
//       borderRadius: BorderRadius.circular(12),
//       child:
//           racer.isLocalVehicleImage
//               ? _buildLocalVehicleImage(racer.vehicleImageUrl!)
//               : CachedNetworkImage(
//                 imageUrl: racer.vehicleImageUrl!,
//                 height: 120,
//                 width: double.infinity,
//                 fit: BoxFit.cover,
//                 placeholder:
//                     (context, url) => Container(
//                       height: 120,
//                       width: double.infinity,
//                       color: Colors.grey[800],
//                       child: const Icon(
//                         Icons.image,
//                         color: Colors.white,
//                         size: 40,
//                       ),
//                     ),
//                 errorWidget:
//                     (context, url, error) => Container(
//                       height: 120,
//                       width: double.infinity,
//                       color: Colors.grey[800],
//                       child: const Icon(
//                         Icons.error_outline,
//                         color: Colors.white,
//                         size: 40,
//                       ),
//                     ),
//               ),
//     );
//   }

//   Widget _buildLocalVehicleImage(String imagePath) {
//     try {
//       // Remove 'file://' prefix if present and handle the path properly
//       final cleanPath = imagePath.replaceAll('file://', '');
//       final file = File(cleanPath);

//       if (file.existsSync()) {
//         return Image.file(
//           file,
//           height: 120,
//           width: double.infinity,
//           fit: BoxFit.cover,
//           errorBuilder: (context, error, stackTrace) {
//             print('Error loading local vehicle image: $error');
//             return Container(
//               height: 120,
//               width: double.infinity,
//               color: Colors.grey[800],
//               child: const Icon(
//                 Icons.error_outline,
//                 color: Colors.white,
//                 size: 40,
//               ),
//             );
//           },
//         );
//       } else {
//         print('Vehicle image file does not exist: $cleanPath');
//         return Container(
//           height: 120,
//           width: double.infinity,
//           color: Colors.grey[800],
//           child: const Icon(Icons.error_outline, color: Colors.white, size: 40),
//         );
//       }
//     } catch (e) {
//       print('Error processing local vehicle image: $e');
//       return Container(
//         height: 120,
//         width: double.infinity,
//         color: Colors.grey[800],
//         child: const Icon(Icons.error_outline, color: Colors.white, size: 40),
//       );
//     }
//   }

//   Widget _buildInitialsContainer(String initials) {
//     return Container(
//       width: 40,
//       height: 40,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(8),
//         color: const Color(0xFF252D38).withOpacity(0.8),
//         border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
//       ),
//       alignment: Alignment.center,
//       child: Text(
//         initials,
//         style: const TextStyle(
//           color: Color(0xFFFFCC29),
//           fontWeight: FontWeight.w700,
//           fontSize: 16,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(
//         horizontal: kDefaultPadding,
//       ).copyWith(bottom: 16),
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
//           color: const Color(0xFF13386B), // Dark blue card background
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(kDefaultPadding),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Racer Image and Initials or Profile Image
//               Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(12),
//                     child: _buildVehicleImage(racer),
//                   ),
//                   Positioned(
//                     top: 10, // Adjust position as needed
//                     left: 10,
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(8),
//                       child: _buildRacerAvatar(racer),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),

//               // Racer Name and Vehicle Model
//               Text(
//                 racer.name,
//                 style: context.titleMedium?.copyWith(
//                   color: const Color(0xFFA8E266), // Greenish color for name
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//               Text(
//                 "Vehicle: ${racer.vehicleModel}",
//                 style: context.bodyMedium?.copyWith(color: Colors.white),
//               ),
//               const SizedBox(height: 8),

//               // Team Name, Current Event, Earnings
//               Text(
//                 "Team: ${racer.teamName}",
//                 style: context.bodySmall?.copyWith(color: Colors.white70),
//               ),
//               Text(
//                 "Current Event: ${racer.currentEvent}",
//                 style: context.bodySmall?.copyWith(color: Colors.white70),
//               ),
//               const SizedBox(height: 12),
//               Align(
//                 alignment: Alignment.centerLeft, // Align earnings to left
//                 child: Text(
//                   "Earnings: ${racer.earnings}",
//                   style: context.titleSmall?.copyWith(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // "View Racer" button
//               _buildActionButton(Icons.play_arrow, () {
//                 // Using play_arrow as a placeholder for the triangle icon
//                 // 1. Fetch deals for the specific racer using the callback function
//                 final dealsForThisRacer = getDealItemsForRacer(racer.name);

//                 // 2. Navigate to RacerDetailScreen, passing the current racer and its deals
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder:
//                         (context) => RacerDetailsScreen(
//                           racer: racer, // Pass the specific racer object
//                           racerDealItems:
//                               dealsForThisRacer, // Pass the relevant deals
//                         ),
//                   ),
//                 );
//               }),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:racecar_tracker/Presentation/Pages/racer_details_screen.dart';
import 'package:racecar_tracker/Services/image_picker_util.dart';
import 'package:racecar_tracker/Utils/Constants/app_constants.dart';
import 'package:racecar_tracker/Utils/theme_extensions.dart';
import 'package:racecar_tracker/Utils/image_url_helper.dart';
import 'package:racecar_tracker/models/deal_item.dart';
import 'package:racecar_tracker/models/racer.dart';

class RacerCardItem extends StatelessWidget {
  final Racer racer;
  final List<DealItem> Function(String racerName) getDealItemsForRacer;

  const RacerCardItem({
    Key? key,
    required this.racer,
    required this.getDealItemsForRacer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageUtil = ImagePickerUtil();
    final vehicleImageUrl = imageUtil.getUrlForUserUploadedImage(racer.vehicleImageUrl ?? '');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          color: const Color(0xFF27518A),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header image with initials
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  // Vehicle Image
                  (racer.vehicleImageUrl != null && racer.vehicleImageUrl!.isNotEmpty)
                      ? Image.network(
                          vehicleImageUrl,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _vehicleFallback(),
                        )
                      : _vehicleFallback(),

                  // Initials Box
                  Positioned(
                    top: 12,
                    left: 15,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF252D38),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                      ),
                      child: Text(
                        racer.initials,
                        style: const TextStyle(
                          color: Color(0xFFFFCC29),
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Text content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    racer.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildInfoRow("Vehicle :", racer.vehicleModel, context),
                  const SizedBox(height: 4),
                  _buildInfoRow("Team :", racer.teamName, context),
                  const SizedBox(height: 12),
                  Text("Current Event :", style: context.labelMedium?.copyWith(color: Colors.white)),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      racer.currentEvent,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow("Earnings :", racer.earnings, context),
                  const SizedBox(height: 8),

                  // View Racer button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final deals = getDealItemsForRacer(racer.name);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RacerDetailsScreen(
                              racer: racer,
                              racerDealItems: deals,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.play_arrow, color: Colors.black),
                      label: const Text(
                        "View Racer",
                        style: TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kButtonColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(60)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _vehicleFallback() {
    return Container(
      height: 120,
      width: double.infinity,
      color: Colors.grey[800],
      child: const Icon(Icons.directions_car, color: Colors.white, size: 40),
    );
  }

  Widget _buildInfoRow(String label, String value, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: context.labelMedium?.copyWith(color: Colors.white)),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ],
    );
  }
}

