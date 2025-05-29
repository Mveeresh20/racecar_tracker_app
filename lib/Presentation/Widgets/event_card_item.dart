import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:racecar_tracker/Utils/Constants/app_constants.dart'; // For kDefaultPadding
import 'package:racecar_tracker/Utils/Constants/images.dart'; // For track images and racer placeholders
import 'package:racecar_tracker/Utils/theme_extensions.dart';
import 'package:racecar_tracker/models/event.dart';   
 // Import the Event model

class EventCardItem extends StatelessWidget {
  final Event event;

  const EventCardItem({Key? key, required this.event}) : super(key: key);

  // Helper to map track name to image asset/URL
  String _getTrackImage(String trackName) {
    switch (trackName.toLowerCase()) {
      case "longmilan track":
        return Images.longmilanTrackLayout;
      case "drift track":
        return Images.driftTrackLayout;
      // Add more cases for other track names
      default:
        return Images.genericTrackLayout; // Fallback image for unknown tracks
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          color: const Color(0xFF13386B),
        ),

    
    
    
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Title, Race Type, Status, Track Image
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: TextStyle(
                          color: Color(0xFFA8E266),
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event.raceType,
                        style: context.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: event.statusColor, // Dynamic status color
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        event.statusText, // Dynamic status text
                        style: const TextStyle(
                          color: Colors.black, // Text color for status button
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Track Image based on trackName
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,

              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      // Date & Time
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              DateFormat(
                                'MMMM dd, yyyy hh:mm a',
                              ).format(event.dateTime),
                              style: context.titleSmall?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Track Name & Racers Count
                      Row(
                        children: [
                          const Icon(
                            Icons.track_changes,
                            color: Colors.white,
                            size: 16,
                          ), // Example icon for track
                          const SizedBox(width: 8),
                          Text(
                            "Track ${event.trackName} ",
                            overflow: TextOverflow.ellipsis,
                            style: context.titleSmall?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.group,
                            color: Colors.white,
                            size: 16,
                          ), // Example icon for track
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "${event.currentRacers}/${event.maxRacers} Racers",
                              style: context.titleSmall?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                       Row(
                        children: [
                          const Icon(
                            Icons.car_crash,
                            color: Colors.white,
                            size: 16,
                          ), // Example icon for track
                          const SizedBox(width: 8),
                          Text(
                            "${event.raceName} ",
                            overflow: TextOverflow.ellipsis,
                            style: context.titleSmall?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                Image.network(
                  _getTrackImage(event.trackName),
                  width: 80, // Adjust size as needed
                  
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      
                      color: Colors.grey.shade700,
                      child: const Icon(
                        Icons.map,
                        color: Colors.white,
                        size: 40,
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              // mainAxisSize: MainAxisSize.min, // Consider removing mainAxisSize.min from the parent Row
              // if you want it to expand and provide proper width to Flexible/Expanded children.
              // If you keep mainAxisSize.min, the Row will try to be as small as possible.
              children: [
                Text(
                  "Racers:",
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                ),
                const SizedBox(width: 8),
                // Use an Expanded or Flexible here to give _buildRacerAvatars a bounded width
                Expanded(
                  // Or Flexible if you want it to shrink-wrap
                  child: LayoutBuilder(
                    // Use LayoutBuilder to get the available width
                    builder: (context, constraints) {
                      return _buildRacerAvatars(
                        event.racerImageUrls,
                        event.totalOtherRacers,
                        constraints
                            .maxWidth, // Pass the available width to the function
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Action Buttons (Assign Racers & Edit)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Color(0xFF8B6AD2),Color(0xFF211E83)],begin: Alignment.topLeft,end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withOpacity(0.3),width: 1),
                    ),
                    child: InkWell(
                      onTap: () {
                        // Handle Assign Racers action
                      },
                      
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10,),
                          child: Text(
                            "Assign Racers",
                            style: context.titleSmall?.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 44, // Fixed size for the edit icon button
                  height: 44,
                  decoration: BoxDecoration(

                    gradient: LinearGradient(colors: [Color(0xFF8B6AD2),Color(0xFF211E83)],begin: Alignment.topLeft,end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.3),width: 1),
                    
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () {
                      // Handle Edit action
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),);
  }

  Widget _buildRacerAvatars(
    List<String> imageUrls,
    int totalOtherRacers,
    double availableWidth,
  ) {
    const double avatarSize = 32.0;
    const double overlap = 16.0; // How much avatars overlap
    const int maxVisibleAvatars = 8; // Or any number that fits your design

    List<Widget> avatars = [];
    int actualVisibleAvatars = 0;

    // Determine how many avatars can actually be displayed
    // considering the maxVisibleAvatars and if there's a "+X" circle
    int remainingRacers = totalOtherRacers;
    List<String> displayImageUrls = [];

    // If there are more racers than can be visually represented by individual avatars
    if (imageUrls.length > maxVisibleAvatars) {
      displayImageUrls = imageUrls.sublist(
        0,
        maxVisibleAvatars - 1,
      ); // Leave space for +X
      remainingRacers += (imageUrls.length - (maxVisibleAvatars - 1));
    } else {
      displayImageUrls = imageUrls;
    }

    // Build the individual avatar widgets
    for (int i = 0; i < displayImageUrls.length; i++) {
      avatars.add(
        Positioned(
          left: i * (avatarSize - overlap),
          child: CircleAvatar(
            radius: avatarSize / 2,
            backgroundColor: Colors.white, // Border around avatar
            child: CircleAvatar(
              radius: (avatarSize / 2) - 2, // Inner avatar size
              backgroundImage: NetworkImage(displayImageUrls[i]),
              backgroundColor: Colors.grey.shade600, // Placeholder
              onBackgroundImageError: (exception, stackTrace) {
                debugPrint('Error loading racer image: $exception');
              },
            ),
          ),
        ),
      );
      actualVisibleAvatars++;
    }

    // Add "+X Other Racers" if applicable
    if (remainingRacers > 0) {
      final double otherRacersOffset =
          actualVisibleAvatars * (avatarSize - overlap);
      avatars.add(
        Positioned(
          left: otherRacersOffset,
          child: CircleAvatar(
            radius: avatarSize / 2,
            backgroundColor: Colors.grey.shade700,
            child: Text(
              '+$remainingRacers',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      );
      actualVisibleAvatars++; // Count this as one visible "avatar" for width calculation
    }

    // Calculate the required width based on actual visible items
    double requiredWidth = 0;
    if (actualVisibleAvatars > 0) {
      requiredWidth =
          (actualVisibleAvatars - 1) * (avatarSize - overlap) + avatarSize;
    }

    // Ensure the calculated width doesn't exceed the available width
    final double finalWidth = requiredWidth.clamp(0.0, availableWidth);

    return SizedBox(
      height: avatarSize, // Fixed height for the stack of avatars
      width: finalWidth, // Use the calculated width, clamped by available space
      child: Stack(children: avatars),
    );
  }
}

//   Widget _buildRacerAvatars(List<String> imageUrls, int totalOtherRacers) {
//     const double avatarSize = 32.0;
//     const double overlap = 16.0; // How much avatars overlap

//     List<Widget> avatars = [];
//     for (int i = 0; i < imageUrls.length; i++) {
//       avatars.add(
//         Positioned(
//           left: i * (avatarSize - overlap),
//           child: CircleAvatar(
//             radius: avatarSize / 2,
//             backgroundColor: Colors.white, // Border around avatar
//             child: CircleAvatar(
//               radius: (avatarSize / 2) - 2, // Inner avatar size
//               backgroundImage: NetworkImage(imageUrls[i]),
//               backgroundColor: Colors.grey.shade600, // Placeholder
//               onBackgroundImageError: (exception, stackTrace) {
//                 debugPrint('Error loading racer image: $exception');
//               },
//             ),
//           ),
//         ),
//       );
//     }

//     // Calculate the total width needed for the avatars
//     double totalWidth = 0;
//     if (imageUrls.length > 0) {
//       totalWidth = (imageUrls.length - 1) * (avatarSize - overlap) + avatarSize;
//     }

//     // Add "+X Other Racers" if applicable
//     if (totalOtherRacers > 0) {
//       final double otherRacersOffset =
//           imageUrls.length * (avatarSize - overlap);
//       avatars.add(
//         Positioned(
//           left: otherRacersOffset,
//           child: CircleAvatar(
//             radius: avatarSize / 2,
//             backgroundColor: Colors.grey.shade700,
//             child: Text(
//               '+$totalOtherRacers',
//               style: const TextStyle(color: Colors.white, fontSize: 12),
//             ),
//           ),
//         ),
//       );
//       // Adjust total width to include the "+X" circle
//       totalWidth = otherRacersOffset + avatarSize;
//     }

//     return SizedBox(
//       height: avatarSize, // Fixed height for the stack of avatars
//       width: totalWidth, // <--- Crucial: Give the SizedBox a calculated width
//       child: Stack(children: avatars),
//     );
//   }
// }

// Helper method to build racer avatars
//   Widget _buildRacerAvatars(List<String> imageUrls, int totalOtherRacers) {
//     const double avatarSize = 32.0;
//     const double overlap = 16.0; // How much avatars overlap

//     List<Widget> avatars = [];
//     for (int i = 0; i < imageUrls.length; i++) {
//       avatars.add(
//         Positioned(
//           left: i * (avatarSize - overlap),
//           child: CircleAvatar(
//             radius: avatarSize / 2,
//             backgroundColor: Colors.white, // Border around avatar
//             child: CircleAvatar(
//               radius: (avatarSize / 2) - 2, // Inner avatar size
//               backgroundImage: NetworkImage(imageUrls[i]),
//               backgroundColor: Colors.grey.shade600, // Placeholder
//               onBackgroundImageError: (exception, stackTrace) {
//                 // Fallback for broken image URLs
//                 debugPrint('Error loading racer image: $exception');
//               },
//             ),
//           ),
//         ),
//       );
//     }

//     // Add "+X Other Racers" if applicable
//     if (totalOtherRacers > 0) {
//       avatars.add(
//         Positioned(
//           left: imageUrls.length * (avatarSize - overlap),
//           child: CircleAvatar(
//             radius: avatarSize / 2,
//             backgroundColor: Colors.grey.shade700,
//             child: Text(
//               '+$totalOtherRacers',
//               style: const TextStyle(color: Colors.white, fontSize: 12),
//             ),
//           ),
//         ),
//       );
//     }

//     return SizedBox(
//       height: avatarSize, // Fixed height for the stack of avatars
//       child: Stack(children: avatars),
//     );
//   }
// }
