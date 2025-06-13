import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:racecar_tracker/Presentation/Widgets/assist_text_theme.dart';
import 'package:racecar_tracker/Presentation/Widgets/bottom_icons.dart';
import 'package:racecar_tracker/Utils/Constants/app_constants.dart';
import 'package:racecar_tracker/Utils/Constants/images.dart';
import 'package:racecar_tracker/Utils/theme_extensions.dart';
import 'package:racecar_tracker/models/sponsor.dart';
import 'package:racecar_tracker/models/deal_item.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:racecar_tracker/Services/image_picker_util.dart';

class SponsorDetailScreen extends StatelessWidget {
  final Sponsor sponsor;
  final List<DealItem> sponsorDealItems;
  final DealItem? dealItem;

  const SponsorDetailScreen({
    Key? key,
    required this.sponsor,
    required this.sponsorDealItems,
    this.dealItem,
  }) : super(key: key);

  Widget _buildDealPartChip(String text, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFF1B2953),
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
                  // Sponsor Initials/Logo, Name, and Type
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0xFF252D38),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child:
                            sponsor.logoUrl != null &&
                                    sponsor.logoUrl!.isNotEmpty
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                    imageUrl: ImagePickerUtil()
                                        .getUrlForUserUploadedImage(
                                          sponsor.logoUrl!,
                                        ),
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    placeholder:
                                        (context, url) => const Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Color(0xFFFFCC29),
                                                ),
                                          ),
                                        ),
                                    errorWidget:
                                        (context, url, error) => Text(
                                          sponsor.initials,
                                          style: const TextStyle(
                                            color: Color(0xFFFFCC29),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 32,
                                          ),
                                        ),
                                  ),
                                )
                                : Text(
                                  sponsor.initials,
                                  style: const TextStyle(
                                    color: Color(0xFFFFCC29),
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
                            sponsor.industryType ?? "N/A",
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
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSummaryColumn(
                          "Active Deals",
                          sponsor.activeDeals.toString(),
                          context,
                        ),
                        _buildSummaryColumn(
                          "Total Deals",
                          sponsorDealItems.length.toString(),
                          context,
                        ),
                        _buildSummaryColumn(
                          "Commission",
                          dealItem?.commission ?? "N/A",
                          context,
                        ),
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
                            sponsor.name,
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
                            sponsor.contactNumber ?? "",
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
                            dealItem != null
                                ? dealItem!.dealValue
                                : sponsor.lastDealAmount ?? "No deals yet",
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
                      fontSize: 16,
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
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
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

  Widget _buildDealItemCard(DealItem deal, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16), // Spacing between deal cards
      padding: const EdgeInsets.all(kDefaultPadding),
      decoration: BoxDecoration(
        color: const Color(0xFF13386B),
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
                crossAxisAlignment: CrossAxisAlignment.end,
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
        ],
      ),
    );
  }
}
