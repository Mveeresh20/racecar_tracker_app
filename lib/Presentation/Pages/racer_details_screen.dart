import 'package:flutter/material.dart';
import 'package:racecar_tracker/Presentation/Widgets/bottom_icons.dart';
import 'package:racecar_tracker/Utils/Constants/app_constants.dart';
import 'package:racecar_tracker/Utils/theme_extensions.dart';
import 'package:racecar_tracker/models/deal_item.dart';
import 'package:racecar_tracker/models/racer.dart';
import 'package:racecar_tracker/Utils/image_url_helper.dart';
import 'package:racecar_tracker/Services/app_constant.dart';
import 'package:racecar_tracker/Services/image_picker_util.dart';

class RacerDetailsScreen extends StatelessWidget {
  const RacerDetailsScreen({
    super.key,
    required this.racer,
    required this.racerDealItems,
  });

  final Racer racer;

  final List<DealItem> racerDealItems;
  // Helper widget to build the "Parts" chips for deal items
  Widget _buildDealPartChip(String text, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFF1B2953), // Dark blue chip background
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          text,
          style: context.bodySmall?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Helper widget for action buttons (View, Log Payment, Edit) for deal items
  Widget _buildDealActionButton(
    IconData icon,
    String label,
    VoidCallback onPressed,
    BuildContext context,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF8B6AD2),
              Color(0xFF211E83),
            ], // Gradient as seen in screenshots
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: context.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: 24,
              ).copyWith(top: 64, bottom: 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2D5586), Color(0xFF171E45)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.arrow_back_ios_new_outlined,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 16),
                      Text(
                        "Racer Detail",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  // Space before bottom border
                ],
              ),
            ),
            SizedBox(height: 16),
            // --- Header Section (Matching Racer Detail screenshot) ---
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Row: Initials/Image and Vehicle Image
                _buildImageSection(context, racer),
                // --- Main Content Section (below header image) ---
                Padding(
                  padding: const EdgeInsets.all(kDefaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 16,
                      ), // Space between image section and summary box
                      // Active Races, Total Races, Earnings Summary Box
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF8B6AD2), Color(0xFF211E83)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ), // Dark blue/purple background
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildSummaryColumn(
                              "Active Races",
                              racer.activeRaces.toString(),
                              context,
                            ), // Dynamic from racer model
                            _buildSummaryColumn(
                              "Total Races",
                              racer.totalRaces.toString(),
                              context,
                            ), // Dynamic from racer model
                            _buildSummaryColumn(
                              "Earnings",
                              racer.earnings,
                              context,
                            ), // Dynamic from racer model
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Racer Details Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Name",
                                style: context.bodySmall?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                racer.name, // Dynamic from racer model
                                style: context.titleMedium?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Team Name",
                                style: context.bodySmall?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                racer.teamName, // Dynamic from racer model
                                style: context.titleMedium?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Vehicle Number",
                                style: context.bodySmall?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                racer.vehicleNumber, // Dynamic from racer model
                                style: context.titleMedium?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Car Model",
                                style: context.bodySmall?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                racer.vehicleModel, // Dynamic from racer model
                                style: context.titleMedium?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Contact Number",
                                style: context.bodySmall?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                racer.contactNumber, // Dynamic from racer model
                                style: context.titleMedium?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Active Events",
                                style: context.bodySmall?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                racer
                                    .currentEvent, // Using currentEvent from model for "Active Events"
                                style: context.titleMedium?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF13386B),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                      ),
                      SizedBox(height: 21),
                      // Active Deals Section (List of DealItem Cards)
                      Text(
                        "Active Deals",
                        style: context.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      racerDealItems.isEmpty
                          ? Center(
                            child: Text(
                              "No active deals for this racer.",
                              style: context.bodyMedium?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          )
                          : ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: racerDealItems.length,
                            itemBuilder: (context, index) {
                              final deal = racerDealItems[index];
                              return _buildDealItemCard(deal, context, racer);
                            },
                          ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryColumn(String title, String value, BuildContext context) {
    return Column(
      children: [
        Text(title, style: context.titleSmall?.copyWith(color: Colors.white)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // Helper widget to build an individual DealItem Card (matching Deals screen and Sponsor Detail screen)
  Widget _buildDealItemCard(DealItem deal, BuildContext context, Racer racer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16), // Spacing between deal cards
      padding: EdgeInsets.all(kDefaultPadding),
      decoration: BoxDecoration(
        color: const Color(0xFF13386B), // Same card background as other cards
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                deal.title, // e.g., "John Meave X DC Autos"
                style: context.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: deal.statusColor, // Dynamic status color
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  deal.statusText, // Dynamic status text
                  style: context.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            deal.raceType, // e.g., "Summer Race"
            style: context.bodyMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Deal Value",
                    style: context.bodyMedium?.copyWith(color: Colors.white),
                  ),
                  Text(
                    deal.dealValue, // Dynamic deal value
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              // Commission is optional for racer deals based on screenshot, checking if empty
              deal.commission.isNotEmpty
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Commission",
                        style: context.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        deal.commission, // Dynamic commission
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  )
                  : const SizedBox.shrink(), // Hide if no commission
            ],
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Renewal",
                    style: context.bodyMedium?.copyWith(color: Colors.white),
                  ),
                  Text(
                    deal.renewalDate, // Dynamic renewal date
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Event",
                    style: context.bodyMedium?.copyWith(color: Colors.white),
                  ),
                  Text(
                    racer.currentEvent, // Dynamic renewal date
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),
        
          if (deal.parts.isNotEmpty)
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children:
                  deal.parts
                      .map((part) => _buildDealPartChip(part, context))
                      .toList(),
            ),
        ],
      ),
    );
  }

 Widget _buildImageSection(BuildContext context, Racer racer) {
  final imageUtil = ImagePickerUtil();

  final profileImageUrl = imageUtil.getUrlForUserUploadedImage(
    racer.racerImageUrl ?? '',
  );
  final vehicleImageUrl = imageUtil.getUrlForUserUploadedImage(
    racer.vehicleImageUrl ?? '',
  );

  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Stack(
      children: [
        // Vehicle Image as background
        Container(
          height: 140,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
            image: DecorationImage(
              image: (racer.vehicleImageUrl != null &&
                      racer.vehicleImageUrl!.isNotEmpty)
                  ? NetworkImage(vehicleImageUrl)
                  : const AssetImage("assets/images/vehicle_placeholder.png")
                      as ImageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Racer profile image in a circle, overlaid at top-left
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
              color: const Color(0xFF252D38),
              image: DecorationImage(
                image: (racer.racerImageUrl != null &&
                        racer.racerImageUrl!.isNotEmpty)
                    ? NetworkImage(profileImageUrl)
                    : const AssetImage("assets/images/profile_placeholder.png")
                        as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}


}
