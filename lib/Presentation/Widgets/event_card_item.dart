import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:racecar_tracker/Utils/Constants/app_constants.dart'; // For kDefaultPadding
import 'package:racecar_tracker/Utils/Constants/images.dart'; // For track images and racer placeholders
import 'package:racecar_tracker/models/event.dart'; // Import the Event model

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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: kDefaultPadding, vertical: 8.0),
      color: const Color(0xFF253B64), // Card background color
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event.raceType,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: event.statusColor, // Dynamic status color
                        borderRadius: BorderRadius.circular(20),
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        _getTrackImage(event.trackName),
                        width: 80, // Adjust size as needed
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey.shade700,
                            child: const Icon(Icons.map, color: Colors.white, size: 40),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Date & Time
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.grey, size: 16),
                const SizedBox(width: 8),
                Text(
                  DateFormat('MMMM dd, yyyy hh:mm a').format(event.dateTime),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Track Name & Racers Count
            Row(
              children: [
                const Icon(Icons.alt_route, color: Colors.grey, size: 16), // Example icon for track
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Track ${event.trackName} ${event.currentRacers}/${event.maxRacers} Racers",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Racers Images
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Racers:",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                _buildRacerAvatars(event.racerImageUrls, event.totalOtherRacers),
              ],
            ),
            const SizedBox(height: 16),

            // Action Buttons (Assign Racers & Edit)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle Assign Racers action
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B487A), // Button background color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      "Assign Racers",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 44, // Fixed size for the edit icon button
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B487A),
                    borderRadius: BorderRadius.circular(8),
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
    );
  }

  // Helper method to build racer avatars
  Widget _buildRacerAvatars(List<String> imageUrls, int totalOtherRacers) {
    const double avatarSize = 32.0;
    const double overlap = 16.0; // How much avatars overlap

    List<Widget> avatars = [];
    for (int i = 0; i < imageUrls.length; i++) {
      avatars.add(
        Positioned(
          left: i * (avatarSize - overlap),
          child: CircleAvatar(
            radius: avatarSize / 2,
            backgroundColor: Colors.white, // Border around avatar
            child: CircleAvatar(
              radius: (avatarSize / 2) - 2, // Inner avatar size
              backgroundImage: NetworkImage(imageUrls[i]),
              backgroundColor: Colors.grey.shade600, // Placeholder
              onBackgroundImageError: (exception, stackTrace) {
                // Fallback for broken image URLs
                debugPrint('Error loading racer image: $exception');
              },
            ),
          ),
        ),
      );
    }

    // Add "+X Other Racers" if applicable
    if (totalOtherRacers > 0) {
      avatars.add(
        Positioned(
          left: imageUrls.length * (avatarSize - overlap),
          child: CircleAvatar(
            radius: avatarSize / 2,
            backgroundColor: Colors.grey.shade700,
            child: Text(
              '+$totalOtherRacers',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: avatarSize, // Fixed height for the stack of avatars
      child: Stack(
        children: avatars,
      ),
    );
  }
}