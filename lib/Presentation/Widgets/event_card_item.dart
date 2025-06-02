import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:racecar_tracker/Utils/Constants/app_constants.dart'; // For kDefaultPadding
import 'package:racecar_tracker/Utils/Constants/images.dart'; // For track images and racer placeholders
import 'package:racecar_tracker/Utils/theme_extensions.dart';
import 'package:racecar_tracker/models/event.dart';
import 'package:cached_network_image/cached_network_image.dart';
// Import the Event model

class EventCardItem extends StatelessWidget {
  final Event event;

  const EventCardItem({Key? key, required this.event}) : super(key: key);

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
              // Top Row: Title, Race Type, Status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.name,
                          style: TextStyle(
                            color: Color(0xFFA8E266),
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          event.type,
                          style: context.bodyMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: event.statusColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      event.statusText,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
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
                                ).format(event.startDate),
                                style: context.titleSmall?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Location
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              event.location,
                              overflow: TextOverflow.ellipsis,
                              style: context.titleSmall?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Racers Count
                        Row(
                          children: [
                            const Icon(
                              Icons.group,
                              color: Colors.white,
                              size: 16,
                            ),
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
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Event Image
                  if (event.imageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: event.imageUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) => Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey.shade700,
                              child: const Icon(
                                Icons.image,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                        errorWidget:
                            (context, url, error) => Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey.shade700,
                              child: const Icon(
                                Icons.broken_image,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Racers List
              if (event.racerImageUrls != null &&
                  event.racerImageUrls!.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Racers:",
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return _buildRacerAvatars(
                            event.racerImageUrls!,
                            event.totalRacers - event.racerImageUrls!.length,
                            constraints.maxWidth,
                          );
                        },
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 16),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF8B6AD2), Color(0xFF211E83)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          // Handle Assign Racers action
                        },
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              "Assign Racers",
                              style: context.titleSmall?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF8B6AD2), Color(0xFF211E83)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
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
      ),
    );
  }

  Widget _buildRacerAvatars(
    List<String> imageUrls,
    int totalOtherRacers,
    double availableWidth,
  ) {
    const double avatarSize = 32.0;
    const double overlap = 16.0;
    const int maxVisibleAvatars = 8;

    List<Widget> avatars = [];
    int actualVisibleAvatars = 0;

    int remainingRacers = totalOtherRacers;
    List<String> displayImageUrls = [];

    if (imageUrls.length > maxVisibleAvatars) {
      displayImageUrls = imageUrls.sublist(0, maxVisibleAvatars - 1);
      remainingRacers += (imageUrls.length - (maxVisibleAvatars - 1));
    } else {
      displayImageUrls = imageUrls;
    }

    for (int i = 0; i < displayImageUrls.length; i++) {
      avatars.add(
        Positioned(
          left: i * (avatarSize - overlap),
          child: CircleAvatar(
            radius: avatarSize / 2,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: (avatarSize / 2) - 2,
              backgroundColor: Colors.grey.shade600,
              child: CachedNetworkImage(
                imageUrl: displayImageUrls[i],
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.person,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ),
                errorWidget:
                    (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.person,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ),
              ),
            ),
          ),
        ),
      );
      actualVisibleAvatars++;
    }

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
      actualVisibleAvatars++;
    }

    double requiredWidth = 0;
    if (actualVisibleAvatars > 0) {
      requiredWidth =
          (actualVisibleAvatars - 1) * (avatarSize - overlap) + avatarSize;
    }

    final double finalWidth = requiredWidth.clamp(0.0, availableWidth);

    return SizedBox(
      height: avatarSize,
      width: finalWidth,
      child: Stack(children: avatars),
    );
  }
}
