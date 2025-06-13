import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final mediaQuery = MediaQuery.of(context);
    final imageUtil = ImagePickerUtil();
    final vehicleImageUrl = imageUtil.getUrlForUserUploadedImage(
      racer.vehicleImageUrl ?? '',
    );

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
          children: [
            // Header image with initials
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  // Vehicle Image
                  (racer.vehicleImageUrl != null &&
                          racer.vehicleImageUrl!.isNotEmpty)
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF252D38),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
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

            // Flexible and scrollable content section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: IntrinsicHeight(
                  // <--- Add IntrinsicHeight here
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment:
                        MainAxisAlignment
                            .start, // Ensure content starts from top
                    children: [


                      MediaQuery(
        data: mediaQuery.copyWith(textScaleFactor: 1.0),
        child: Text(
          racer.name,
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
                      const SizedBox(height: 4),
                      _buildInfoRow("Vehicle :", racer.vehicleModel, context),
                      const SizedBox(height: 4),
                      _buildInfoRow("Team :", racer.teamName, context),
                      const SizedBox(height: 12),
                      MediaQuery(
        data: mediaQuery.copyWith(textScaleFactor: 1.0),
        child: Text(
          "current Event :",
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: MediaQuery(
        data: mediaQuery.copyWith(textScaleFactor: 1.0),
        child: Text(
          racer.currentEvent,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow("Earnings :", racer.earnings, context),
                      const SizedBox(height: 8),

                      // Add a Spacer to push the button to the bottom if there's extra space
                      Spacer(), // <--- Add Spacer here
                      // View Racer button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final deals = getDealItemsForRacer(racer.name);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => RacerDetailsScreen(
                                      racer: racer,
                                      racerDealItems: deals,
                                    ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.play_arrow,
                            color: Colors.black,
                          ),
                          label: const Text(
                            "View Racer",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kButtonColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(60),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
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
    );
  }
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
  final mediaQuery = MediaQuery.of(context);

  return Row(
    children: [
      // Label Text with no scale
      MediaQuery(
        data: mediaQuery.copyWith(textScaleFactor: 1.0),
        child: Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),

      const SizedBox(width: 8),

      // Value Text with no scale
      Expanded(
        child: MediaQuery(
          data: mediaQuery.copyWith(textScaleFactor: 1.0),
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    ],
  );
}
