import 'package:flutter/material.dart';
import 'package:racecar_tracker/Presentation/Pages/racer_details_screen.dart';
import 'package:racecar_tracker/Utils/Constants/app_constants.dart';
import 'package:racecar_tracker/Utils/theme_extensions.dart';
import 'package:racecar_tracker/models/racer.dart';
import 'package:racecar_tracker/models/deal_item.dart'; // Import DealItem model
import 'dart:io';
// Import the new screen

class RacerCardItem extends StatelessWidget {
  final Racer racer;
  // This callback function will be used to get specific deals for a racer
  final List<DealItem> Function(String racerName) getDealItemsForRacer;

  const RacerCardItem({
    Key? key,
    required this.racer,
    required this.getDealItemsForRacer, // Receive the callback
  }) : super(key: key);

  // Reusing the _buildActionButton for consistency
  Widget _buildActionButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8), // Match design from screenshots
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF8B6AD2),
              Color(0xFF211E83),
            ], // Gradient from screenshots
          ),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildRacerAvatar(Racer racer) {
    if (racer.racerImageUrl != null && racer.racerImageUrl!.isNotEmpty) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: const Color(0xFF252D38).withOpacity(0.8),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child:
              racer.isLocalImage
                  ? Image.file(
                    File(racer.racerImageUrl!.replaceAll('file://', '')),
                    fit: BoxFit.cover,
                    width: 40,
                    height: 40,
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading local racer image: $error');
                      return _buildInitialsContainer(racer.initials);
                    },
                  )
                  : Image.network(
                    racer.racerImageUrl!,
                    fit: BoxFit.cover,
                    width: 40,
                    height: 40,
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading network racer image: $error');
                      return _buildInitialsContainer(racer.initials);
                    },
                  ),
        ),
      );
    } else {
      return _buildInitialsContainer(racer.initials);
    }
  }

  Widget _buildInitialsContainer(String initials) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFF252D38).withOpacity(0.8),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          color: Color(0xFFFFCC29),
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: kDefaultPadding,
      ).copyWith(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          color: const Color(0xFF13386B), // Dark blue card background
        ),
        child: Padding(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Racer Image and Initials or Profile Image
              Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child:
                        racer.isLocalImage
                            ? Image.file(
                              File(racer.vehicleImageUrl),
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                            : Image.network(
                              racer.vehicleImageUrl,
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 120,
                                  width: double.infinity,
                                  color: Colors.grey[800],
                                  child: const Icon(
                                    Icons.error_outline,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                );
                              },
                            ),
                  ),
                  Positioned(
                    top: 10, // Adjust position as needed
                    left: 10,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xFF252D38).withOpacity(0.8),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child:
                            racer.isLocalImage
                                ? Image.file(
                                  File(racer.racerImageUrl!),
                                  fit: BoxFit.cover,
                                  width: 40,
                                  height: 40,
                                  errorBuilder: (context, error, stackTrace) {
                                    print(
                                      'Error loading local racer image: $error',
                                    );
                                    return Center(
                                      child: Text(
                                        racer.initials,
                                        style: const TextStyle(
                                          color: Color(0xFFFFCC29),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ),
                                      ),
                                    );
                                  },
                                )
                                : Image.network(
                                  racer.racerImageUrl!,
                                  fit: BoxFit.cover,
                                  width: 40,
                                  height: 40,
                                  errorBuilder: (context, error, stackTrace) {
                                    print(
                                      'Error loading network racer image: $error',
                                    );
                                    return Center(
                                      child: Text(
                                        racer.initials,
                                        style: const TextStyle(
                                          color: Color(0xFFFFCC29),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Racer Name and Vehicle Model
              Text(
                racer.name,
                style: context.titleMedium?.copyWith(
                  color: const Color(0xFFA8E266), // Greenish color for name
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                "Vehicle: ${racer.vehicleModel}",
                style: context.bodyMedium?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),

              // Team Name, Current Event, Earnings
              Text(
                "Team: ${racer.teamName}",
                style: context.bodySmall?.copyWith(color: Colors.white70),
              ),
              Text(
                "Current Event: ${racer.currentEvent}",
                style: context.bodySmall?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft, // Align earnings to left
                child: Text(
                  "Earnings: ${racer.earnings}",
                  style: context.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // "View Racer" button
              _buildActionButton(Icons.play_arrow, () {
                // Using play_arrow as a placeholder for the triangle icon
                // 1. Fetch deals for the specific racer using the callback function
                final dealsForThisRacer = getDealItemsForRacer(racer.name);

                // 2. Navigate to RacerDetailScreen, passing the current racer and its deals
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RacerDetailsScreen(
                      racer: racer, // Pass the specific racer object
                      racerDealItems: dealsForThisRacer, // Pass the relevant deals
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
