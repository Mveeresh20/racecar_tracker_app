import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting if needed, though renewalDate is String here
import 'package:racecar_tracker/Presentation/Widgets/assist_text_theme.dart';
import 'package:racecar_tracker/Presentation/Widgets/bottom_icons.dart'; // Assuming this exists
import 'package:racecar_tracker/Utils/Constants/app_constants.dart'; // For kDefaultPadding, kScaffoldBackgroundColor
import 'package:racecar_tracker/Utils/Constants/images.dart'; // For Images.profile, Images.homeScreen
import 'package:racecar_tracker/Utils/theme_extensions.dart'; // For context.bodyMedium etc.
import 'package:racecar_tracker/models/sponsor.dart'; // Import Sponsor model
import 'package:racecar_tracker/models/deal_item.dart'; // Import the new DealItem model

class SponsorDetailScreen extends StatelessWidget {
  final Sponsor sponsor;
  final List<DealItem>
  sponsorDealItems;
   // List of deals specifically for this sponsor

  const SponsorDetailScreen({
    Key? key,
    required this.sponsor,
    required this.sponsorDealItems, // Pass relevant deals
  }) : super(key: key);

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
                        "Sponsor Details",
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

            SizedBox(height: 40),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sponsor Initials, Name, and Type
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(
                            0xFF252D38,
                          ), // Dark grey background
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          sponsor.initials,
                          style: const TextStyle(
                            color: Color(0xFFFFCC29), // Yellow initials
                            fontWeight: FontWeight.w700,
                            fontSize: 32,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sponsor.name,
                            style: context.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            sponsor.industryType??"N/A", // Hardcoded as per screenshot. Consider adding to Sponsor model if dynamic.
                            style: context.labelMedium?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Active Deals, Total Deals, Commission Summary Box
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSummaryColumn(
                          "Active Deals",
                          sponsor.activeDeals.toString(),
                          context,
                        ), // Dynamic from sponsor model
                        _buildSummaryColumn(
                          "Total Deals",
                          "12",
                          context,
                        ), // Placeholder as per screenshot
                        _buildSummaryColumn(
                          "Commission",
                          "20%",
                          context,
                        ), // Placeholder as per screenshot
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Contact Details Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Contact Person",
                            style: context.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            "John Maeve", // Hardcoded as per screenshot. Consider adding to Sponsor model.
                            style: context.titleMedium?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Contact Email",
                            style: context.bodySmall?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            sponsor.email, // Dynamic from sponsor model
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
                            "Contact number",
                            style: context.bodySmall?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "GT 12000", // Hardcoded as per screenshot. Consider adding to Sponsor model.
                            style: context.titleMedium?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Last Deal",
                            style: context.bodySmall?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "\$1,200,000", // Hardcoded as per screenshot. Consider adding to Sponsor model.
                            style: context.titleMedium?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  const SizedBox(height: 20),

                  // Active Deals Section (List of DealItem Cards)
                  Text(
                    "Active Deals",
                    style: context.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16
                    ),
                  ),

                  SizedBox(height: 12),

                  sponsorDealItems.isEmpty
                      ? Center(
                        child: Text(
                          "No active deals for this sponsor.",
                          style: context.bodyMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      )
                      : ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap:
                            true, // Important for nesting ListView in SingleChildScrollView
                        physics:
                            const NeverScrollableScrollPhysics(), // Important to prevent nested scrolling
                        itemCount: sponsorDealItems.length,
                        itemBuilder: (context, index) {
                          final deal = sponsorDealItems[index];
                          return _buildDealItemCard(deal, context);
                        },
                      ),
                ],
              ),
            ),
          
          ],
        ),
      ),
    );
  }

  // Helper widget to build the summary columns (Active Deals, Total Deals, Commission)
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

  // Helper widget to build an individual DealItem Card (matching Deals screen)
  Widget _buildDealItemCard(DealItem deal, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16), // Spacing between deal cards
      padding: const EdgeInsets.all(kDefaultPadding),
      decoration: BoxDecoration(
        color: const Color(
          0xFF13386B,
        ), // Same card background as SponsorCardItem/Deal card
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
                deal.title, // e.g., "DC Autos X Sarah White"
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
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
                  style: context.labelMedium?.copyWith(
                    color: Colors.white, // Text is black on status background
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
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.end, // Align to end for Commission
                children: [
                  Text(
                    "Commission",
                    style: context.bodyMedium?.copyWith(color: Colors.white),
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
              ),
            ],
          ),
          const SizedBox(height: 12),
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

          // Parts/Categories for the deal
          // Wrap(
          //   spacing: 8.0,
          //   runSpacing: 4.0,
          //   children:
          //       deal.parts
          //           .map((part) => _buildDealPartChip(part, context))
          //           .toList(), // Dynamic parts
          // ),

          // Deal Action Buttons
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     _buildDealActionButton(
          //       Icons.remove_red_eye_outlined,
          //       "View Deal",
          //       () {
          //         print("View Deal for ${deal.title}");
          //         // Implement navigation to a specific Deal Details screen if needed
          //       },
          //       context,
          //     ),
          //     _buildDealActionButton(Icons.payments, "Log Payment", () {
          //       print("Log Payment for ${deal.title}");
          //       // Implement payment logging logic
          //     }, context),
          //     _buildDealActionButton(Icons.edit, "Edit", () {
          //       print("Edit Deal for ${deal.title}");
          //       // Implement deal editing logic
          //     }, context),
          //   ],
          // ),
        ],
      ),
    );
  }
}
