import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:racecar_tracker/Utils/Constants/app_constants.dart'; // For kDefaultPadding
import 'package:racecar_tracker/Utils/Constants/images.dart'; // For track images and racer placeholders
import 'package:racecar_tracker/Utils/theme_extensions.dart';
import 'package:racecar_tracker/models/event.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:racecar_tracker/Services/image_picker_util.dart';
import 'package:racecar_tracker/Services/racer_service.dart'; // Import RacerService
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:racecar_tracker/models/racer.dart'; // Import Racer model
import 'package:racecar_tracker/Services/event_service.dart'; // Import EventService
import 'package:racecar_tracker/Presentation/Views/add_new_event_screen.dart';
import 'package:provider/provider.dart';
import 'package:racecar_tracker/Services/event_provider.dart';
// Import the Event model

class EventCardItem extends StatelessWidget {
  final Event event;
  final _imagePicker = ImagePickerUtil(); // Instantiate ImagePickerUtil

  EventCardItem({Key? key, required this.event}) : super(key: key);

  String _getTrackImage(String? trackName) {
    switch (trackName?.toLowerCase()) {
      case "longmilan track":
        return Images.longmilanTrackLayout;
      case "drift track":
        return Images.driftTrackLayout;
      default:
        return Images.genericTrackLayout;
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
                                "${DateFormat('MMMM dd, yyyy').format(event.startDate)} ${DateFormat('hh:mm a').format(event.startDate)} - ${DateFormat('hh:mm a').format(event.endDate)}",
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
                            Image.network(
                              Images.highwayImg,
                              height: 14,
                              width: 16,
                            ),
                            SizedBox(width: 8),
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
                        const SizedBox(height: 8),

                        // Location
                        Row(
                          children: [
                            Image.network(
                              Images.carImag,
                              height: 14,
                              width: 16,
                            ),
                            SizedBox(width: 8),
                            Text(
                              event.type,
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

                  // Event Image
                  if (event.trackName != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        _getTrackImage(event.trackName),
                        
                        height: 100,
                        fit: BoxFit.contain,
                        errorBuilder:
                            (context, url, error) => Container(
                              
                              height: 100,
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
                  if (event.racerImageUrls != null &&
                      event.racerImageUrls!.isNotEmpty)
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
                    )
                  else
                    Expanded(child: SizedBox.shrink()),
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
                          _showAssignRacersBottomSheet(context, event.id);
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
                      onPressed: () async {
                        // Navigate to AddNewEventScreen with existing event
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    AddNewEventScreen(existingEvent: event),
                          ),
                        );

                        // If the event was updated, refresh the events list
                        if (result == true) {
                          final userId = FirebaseAuth.instance.currentUser?.uid;
                          if (userId != null) {
                            // Get the EventProvider and refresh the events
                            final eventProvider = Provider.of<EventProvider>(
                              context,
                              listen: false,
                            );
                            await eventProvider.initUserEvents(userId);
                          }
                        }
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
      final imagePath = displayImageUrls[i];
      final imageUrl = _imagePicker.getUrlForUserUploadedImage(
        imagePath,
      ); // Get full S3 URL

      avatars.add(
        Positioned(
          left: i * (avatarSize - overlap),
          child: CircleAvatar(
            radius: avatarSize / 2,
            backgroundColor: Colors.white,
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: imageUrl, // Use the full S3 URL
                width:
                    avatarSize - 4, // Ensure image fills the inner CircleAvatar
                height:
                    avatarSize - 4, // Ensure image fills the inner CircleAvatar
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Container(
                      color: Colors.grey[300],
                      width: avatarSize - 4,
                      height: avatarSize - 4,
                      child: const Icon(
                        Icons.person,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ),
                errorWidget: (context, url, error) {
                  print(
                    'Error loading racer image: $error for URL: $url',
                  ); // Log error
                  return Container(
                    color: Colors.grey[300],
                    width: avatarSize - 4,
                    height: avatarSize - 4,
                    child: const Icon(
                      Icons.person,
                      size: 16,
                      color: Colors.grey,
                    ),
                  );
                },
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

  void _showAssignRacersBottomSheet(BuildContext context, String eventId) {
    final racerService = RacerService(); // Instantiate RacerService
    final userId =
        FirebaseAuth.instance.currentUser?.uid; // Get current user ID

    if (userId == null) {
      // Handle case where user is not logged in
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not logged in.')));
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300, // Set fixed height from Figma
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ), // Adjust padding
          decoration: BoxDecoration(
            gradient: LinearGradient(
              // Add gradient background
              colors: [Color(0xFF2D5586), Color(0xFF171E45)],
              begin: Alignment.topLeft,
              end: Alignment.bottomLeft,
            ), // Dark background color
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24.0),
            ), // Adjust border radius
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ), // Add border
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select member', // Title from your screenshot
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<List<Racer>>(
                  stream: racerService.getRacersStream(
                    userId,
                  ), // Stream racers for the current user
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading racers: ${snapshot.error}',
                          style: TextStyle(color: Colors.red),
                        ),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'No racers available.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      );
                    }

                    final racers = snapshot.data!;

                    return ListView.builder(
                      itemCount: racers.length,
                      itemBuilder: (context, index) {
                        final racer = racers[index];
                        // Build list tile similar to your screenshot
                        return Container(
                          margin: const EdgeInsets.only(
                            bottom: 12,
                          ), // Spacing between items
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF13386B,
                            ), // Item background color
                            borderRadius: BorderRadius.circular(
                              16,
                            ), // Adjust border radius
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ), // Border
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 24, // Adjust size as needed
                              backgroundColor: const Color(
                                0xFF27518A,
                              ), // Placeholder color
                              child: Text(
                                racer
                                    .initials, // Assuming Racer model has initials
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ), // Adjust text style
                              ),
                            ),
                            title: Text(
                              racer.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ), // Adjust text style
                            ),
                            trailing: Radio<String>(
                              value: racer.id, // Use racer ID as value
                              groupValue: null, // Selection handled by onTap
                              onChanged: (String? value) {
                                // This won't be directly used due to onTap handling
                              },
                              activeColor: Color(
                                0xFFA8E266,
                              ), // Radio button color
                            ),
                            onTap: () {
                              _assignRacerToEvent(
                                context,
                                eventId,
                                racer.id,
                              ); // Assign racer on tap
                              Navigator.pop(context); // Close bottom sheet
                            },
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ), // Adjust padding
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _assignRacerToEvent(
    BuildContext context,
    String eventId,
    String racerId,
  ) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not logged in.')));
        return;
      }

      final eventService = EventService();
      final racerService = RacerService();

      // Fetch the event and racer details
      final event = await eventService.getEvent(userId, eventId);
      final racer = await racerService.getRacer(userId, racerId);

      if (event == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Event not found.')));
        return;
      }

      if (racer == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Racer not found.')));
        return;
      }

      // Add the racer's image URL to the event's racerImageUrls if not already present
      final updatedRacerImageUrls = List<String>.from(
        event.racerImageUrls ?? [],
      );
      if (racer.racerImageUrl != null &&
          !updatedRacerImageUrls.contains(racer.racerImageUrl!)) {
        updatedRacerImageUrls.add(racer.racerImageUrl!);

        // Create an updated event object with incremented currentRacers count
        final updatedEvent = event.copyWith(
          racerImageUrls: updatedRacerImageUrls,
          currentRacers: event.currentRacers + 1,
        );

        // Update the event in Firebase
        await eventService.updateEvent(userId, updatedEvent);

        // Refresh the event provider to update the UI
        final eventProvider = Provider.of<EventProvider>(
          context,
          listen: false,
        );
        await eventProvider.initUserEvents(userId);

        if (!context.mounted) return; // Add mounted check
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Racer ${racer.name} assigned to event.')),
        );
      } else if (racer.racerImageUrl == null) {
        if (!context.mounted) return; // Add mounted check
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Racer ${racer.name} does not have an image to assign.',
            ),
          ),
        );
      } else {
        if (!context.mounted) return; // Add mounted check
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Racer ${racer.name} is already assigned to this event.',
            ),
          ),
        );
      }
    } catch (e) {
      print('Error assigning racer: $e');
      if (!context.mounted) return; // Add mounted check
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error assigning racer: ${e.toString()}')),
      );
    }
  }
}
