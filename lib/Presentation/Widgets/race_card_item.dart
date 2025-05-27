import 'package:flutter/material.dart';
import 'package:racecar_tracker/Presentation/Pages/racer_details_screen.dart';
import 'package:racecar_tracker/Presentation/Pages/racers_screen.dart';
import 'package:racecar_tracker/Utils/Constants/app_constants.dart'; // For kDefaultPadding
import 'package:racecar_tracker/Utils/Constants/images.dart';
import 'package:racecar_tracker/Utils/theme_extensions.dart';
import 'package:racecar_tracker/models/deal_item.dart';
import 'package:racecar_tracker/models/racer.dart'; // Import the Racer model

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
            // Top Row: Initials/Image and Vehicle Image
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),

              child: Stack(
                children: [
                  Image.network(
                    racer.vehicleImageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Container(height: 120, width: double.infinity),

                  Positioned(
                    top: 12,
                    left: 15,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF252D38),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),

                        // Placeholder color for initials background
                      ),

                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 7,
                          ),
                          child: Text(
                            racer.initials,
                            style: TextStyle(
                              color: Color(0xFFFFCC29),
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      // alignment: Alignment.center,
                      // child: Text(
                      //   racer.initials,
                      //   style: const TextStyle(
                      //     color: Colors.white,
                      //     fontWeight: FontWeight.bold,
                      //     fontSize: 16,
                      //   ),
                      // ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    racer.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "Vehicle :",
                          style: context.labelMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        racer.vehicleModel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  // Vehicle
                  const SizedBox(height: 4),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Team :",
                        style: context.labelMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        racer.teamName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  // Team
                  const SizedBox(height: 12),

                  Text(
                    "Current Event :",
                    style: context.labelMedium?.copyWith(color: Colors.white),
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      racer.currentEvent,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // Current Event
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Earnings :",
                        style: context.labelMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        racer.earnings,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  // Earnings
                  const SizedBox(height: 8),

                  // View Racer Button
                  SizedBox(
                    width: double.infinity, // Make button take full width
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final dealsForThisRacer = getDealItemsForRacer(
                          racer.name,
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RacerDetailsScreen(
                              racer: racer,
                              racerDealItems: dealsForThisRacer,
                              
                            ),
                          ),
                        );

                        // Handle View Racer action
                      },
                      icon: const Icon(
                        Icons.play_arrow,
                        color: Colors.black,
                      ), // Play icon
                      label: const Text(
                        "View Racer",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            kButtonColor, // Your yellow button color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            60,
                          ), // Slightly rounded corners
                        ),
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
}
